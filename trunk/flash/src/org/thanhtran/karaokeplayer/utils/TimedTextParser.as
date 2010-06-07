/**
 * Copyright 2010 Thanh Tran - trongthanh@gmail.com
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.thanhtran.karaokeplayer.utils {
	import org.thanhtran.karaokeplayer.data.BlockInfo;
	import org.thanhtran.karaokeplayer.data.LineInfo;
	import org.thanhtran.karaokeplayer.data.SongInfo;
	import org.thanhtran.karaokeplayer.data.SongLyrics;
	import org.thanhtran.karaokeplayer.KarPlayerError;
	import org.thanhtran.karaokeplayer.karplayer_internal;
	
	use namespace karplayer_internal;
	/**
	 * @author Thanh Tran
	 */
	public class TimedTextParser {
		
		include "../version.as";
		
		public var tt: Namespace = new Namespace("http://www.w3.org/ns/ttml");
		public var tts: Namespace = new Namespace("http://www.w3.org/ns/ttml#styling");
		public var ttm: Namespace = new Namespace("http://www.w3.org/ns/ttml#metadata");
		
		private static const STYLES: Array = ["b", "m", "f"];
		
		
		public function parseXML(xml: XML): SongInfo {
			if(xml) {
				//support later version of TimedText
				tt = xml.namespace();
				tts = new Namespace(tt.uri + "#styling");
				ttm = new Namespace(tt.uri + "#metadata");
			}
			
			default xml namespace = tt;
			
			if (xml.localName() != "tt") {
				throw new KarPlayerError(KarPlayerError.INVALID_XML, "root node is not tt");
			}
			
			var songInfo: SongInfo = new SongInfo();
			if (xml.head[0]) {
				parseSongHead(xml.head[0], songInfo);
			} else {
				throw new KarPlayerError(KarPlayerError.INVALID_XML, "<head> tag is missing from this xml");
			}
			
			if (xml.body[0]) {
				parseSongLyrics(xml.body[0], songInfo);
			} else {
				throw new KarPlayerError(KarPlayerError.INVALID_XML, "<body> tag is missing from this xml");
			}
			
			return songInfo;
		}
		
		/**
		 * <metadata>
			<ttm:title><![CDATA[Hạnh Phúc Bất Tận]]></ttm:title>
			<ttm:desc><![CDATA[Composed by: Nguyễn Đức Thuận<br/>Singers: Hồ Ngọc Hà ft. V.Music Band]]></ttm:desc>
			<ttm:copyright>Copyright (C) 2010 Thanh Tran - trongthanh@gmail.com</ttm:copyright>
			<audio>mp3/hanh_phuc_bat_tan.mp3</audio>
		</metadata>
		 * @param	head
		 * @param	songInfo
		 */
		karplayer_internal function parseSongHead(head: XML, songInfo: SongInfo): void {
			songInfo.title = head.metadata.ttm::title[0];
			songInfo.description = head.metadata.ttm::desc[0];
			songInfo.copyright = head.metadata.ttm::copyright[0];
			songInfo.audio = head.metadata.audio;
		}
		
		/**
		 * 
		 * <body><div style="f">
			<p begin="00:00:21.260">* * *</p> <!-- this first version will only support sequential begin -->
			<p begin="00:00:23.780">Thắp nến đêm nay</p>
		</div>
		<div style="f">
			<p begin="00:00:25.780">ấm áp trong tay</p>
		</div>
		<div style="f">
			<p begin="00:00:27.500">của người</p>
			<p begin="00:00:27.860">yêu dấu</p>
		</div>
		<div style="f">
			<p begin="00:00:29.540">xiết bao ngọt ngào</p>
		</div>
		</body>
		 */
		karplayer_internal function parseSongLyrics(body: XML, songInfo: SongInfo): void {
			var divList: XMLList = body.div;
			var divLen: int = divList.length();
			if (divLen == 0) {
				throw new KarPlayerError(KarPlayerError.INVALID_XML, "<div> tags are missing from <body>: " + body.toXMLString());
			}
			var pList: XMLList;
			var div: XML;
			var p: XML;
			var lyricLine: LineInfo;
			var lyricBlock: BlockInfo;
			var pLen: int;
			var begin: Number;
			var lineDur: uint;
			var end: Number;
			var dur: uint;
			
			var songLyrics: SongLyrics = new SongLyrics();
			//TODO: parse other info of SongLyrics
			
			//process div blocks
			for (var i : int = 0; i < divLen; i++) {
				div = divList[i];
				lyricLine = new LineInfo();
				//trace( "div.@style[0] : " + div.@style[0] );
				lyricLine.styleName = String(getValueFromSet(div.@style.toString(), STYLES));
				//trace( "lyricLine.lyricStyle : " + lyricLine.lyricStyle );
				
				//TODO: get start time of block by div.@begin
				
				pList = div.p;
				pLen = pList.length();
				lineDur = 0;
				if (pLen == 0) {
					throw new KarPlayerError(KarPlayerError.INVALID_XML, "<p> tags are missing from this <div> block: " + div.toXMLString());
				} else {
					//process p
					for (var j:int = 0; j < pLen; j++) {
						p = pList[j];
						lyricBlock = new BlockInfo();
						//get text
						lyricBlock.text = p.toString();
						//trace( "lyricBit.text : " + lyricBlock.text );
						begin = parseTimeAttribute(p, "begin", true);
						//get start time of block from first p (if not, get start time from div.@begin
						if (j == 0) {
							lyricLine.startTime = begin;
						}
						
						lyricBlock.duration = (p.@dur[0] != undefined)? uint(p.@dur[0]): 0;
						
						//try next p
						var nextP: XML = pList[j + 1];
						var beginRequired: Boolean = (lyricBlock.duration == 0)? true : false;
						if (!nextP && beginRequired) {
							//try first p of next div
							var nextDiv: XML = divList[i + 1];
							if (nextDiv) {
								nextP = nextDiv.p[0];
								if (!nextP.@begin[0]) {
									//try next div
									nextP = nextDiv;
								}
							} else {
								throw new KarPlayerError(KarPlayerError.INVALID_XML, "Final <p> doesn't have duration");
							}
							
						}
						
						end = parseTimeAttribute(nextP, "begin", beginRequired);
						if (!isNaN(end)) {
							lyricBlock.duration = end - begin;
						}
						//trace( "lyricBlock: " + lyricBlock );
						lineDur += lyricBlock.duration; 
						//trace( "lyricBit.duration : " + lyricBit.duration );
						lyricLine.lyricBlocks.push(lyricBlock);
						
					} //end p loop
				}
				if (!lyricLine.startTime) {
					lyricLine.startTime = parseTimeAttribute(div, "begin", true);
				}
				lyricLine.duration = lineDur; 
				songLyrics.addLine(lyricLine);
				
			} //end div loop
			
			songInfo.lyrics = songLyrics;
		}
		
		/**
		 * Modified from FLVPlayBackCaptioning's TimedTextManager
		 * @param	parentNode
		 * @param	attr
		 * @param	req
		 * @return
		 */
		karplayer_internal function parseTimeAttribute(parentNode:XML, attr:String, req:Boolean): Number {
			if (!parentNode || parentNode["@" + attr].length() < 1) {
				if (req) {
					throw new KarPlayerError(KarPlayerError.INVALID_XML, "Missing required attribute " + attr + " in node: " + parentNode);
				}
				return NaN;
			}
			var timeStr:String = parentNode["@" + attr].toString();
			//trace( "timeStr : " + timeStr );

			// first check for clock format or partial clock format
			var theTime:Number;
			var multiplier:Number;
			var results:Object = /^((\d+):)?(\d+):((\d+)(.\d+)?)$/.exec(timeStr);
			if (results != null) {
				theTime = 0;
				theTime += (uint(results[2]) * 3600 * 1000);
				theTime += (uint(results[3]) * 60 * 1000);
				theTime += uint((Number(results[4]) * 1000));
				return theTime;
			}

			// next check for offset time
			results = /^(\d+(.\d+)?)(h|m|s|ms)?$/.exec(timeStr);
			if (results != null) {
				switch (results[3]) {
				case "h": multiplier = 3600 * 1000; break;
				case "m": multiplier = 60 * 1000; break;
				case "s":	multiplier = 1000; break;
				case "ms":
				default:
					multiplier = 1;
					break;
				}
				theTime = Number(results[1]) * multiplier;
				return theTime;
			}

			// as a last ditch we treat a bare number as milliseconds
			theTime = uint(timeStr);
			if (isNaN(theTime) || theTime < 0) {
				if (req) {
					throw new KarPlayerError(KarPlayerError.INVALID_XML, "Illegal time value " + timeStr + " for required attribute " + attr);
				}
				return NaN;
			}
			return theTime;
		}
		
		
		/**
		 * get value from set of predefined value.<br/>
		 * for e.g: style must match one of "b", "m" or "f"
		 * @param	value
		 * @param	set
		 * @return	value if value is in set; else return default value (first one) 
		 */
		karplayer_internal function getValueFromSet(value: Object , valueSet: Array): Object {
			if (valueSet.indexOf(value) != -1) {
				return value;
			} else {
				return valueSet[0];
			}
		}
	}
}
