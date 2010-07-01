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
package vn.karaokeplayer.utils {
	import vn.karaokeplayer.Version;
	import vn.karaokeplayer.data.BlockInfo;
	import vn.karaokeplayer.data.KarPlayerError;
	import vn.karaokeplayer.data.LineInfo;
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.data.SongLyrics;
	import vn.karaokeplayer.karplayer_internal;
	
	use namespace karplayer_internal;
	/**
	 * @author Thanh Tran
	 */
	public class TimedTextParser {
		public static const VERSION: String = Version.VERSION;
		
		public var tt: Namespace = new Namespace("http://www.w3.org/ns/ttml");
		public var tts: Namespace = new Namespace("http://www.w3.org/ns/ttml#styling");
		public var ttm: Namespace = new Namespace("http://www.w3.org/ns/ttml#metadata");
		
		private static const STYLES: Array = ["b", "m", "f"];
		
		public function parseXML(xml: XML): SongInfo {
			if(xml) {
				//support later version of TimedText
				tt = xml.namespace();
				if(!tt.uri) throw new KarPlayerError(KarPlayerError.INVALID_XML, "XML must have default namespace");
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
		 * 
		 * @param	head
		 * @param	songInfo
		 */
		karplayer_internal function parseSongHead(head: XML, songInfo: SongInfo): void {
			songInfo.title = head.metadata.ttm::title[0];
			songInfo.description = head.metadata.ttm::desc[0];
			songInfo.copyright = head.metadata.ttm::copyright[0];
			songInfo.beatURL = head.metadata.audio;
		}
		
		/**
		 * 
		 *
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
			var lineBegin: Number;
			var blockBegin: Number;
			var lineDur: uint;
			var end: Number;
			
			var songLyrics: SongLyrics = new SongLyrics();
			//TODO: parse other info of SongLyrics
			
			//process div blocks
			for (var i : int = 0; i < divLen; i++) {
				div = divList[i];
				lyricLine = new LineInfo();
				//trace( "div.@style[0] : " + div.@style[0] );
				lyricLine.styleName = String(getValueFromSet(div.@style.toString(), STYLES));
				//trace( "lyricLine.lyricStyle : " + lyricLine.lyricStyle );
				
				//TODO: get start time of line by div.@begin
				if (!lyricLine.begin) {
					lyricLine.begin = parseTimeAttribute(div, "begin", false);
				}
				
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
						lineBegin = parseTimeAttribute(p, "begin", false);
						//get start time of block from first p (if not, get start time from div.@begin
						if (j == 0) {
							if(lineBegin) {
								lyricLine.begin = lineBegin;	
							} else if(isNaN(lyricLine.begin)) {
								throw new KarPlayerError(KarPlayerError.INVALID_XML,"<div> and first <p> don't have begin property: " + div.toXMLString());
							}
							blockBegin = lyricLine.begin;
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
							lyricBlock.duration = end - lineBegin;
						}
						lyricBlock.begin = blockBegin;
						blockBegin += lyricBlock.duration; 
						//trace( "lyricBlock: " + lyricBlock );
						lineDur += lyricBlock.duration; 
						//trace( "lyricBit.duration : " + lyricBit.duration );
						lyricLine.lyricBlocks.push(lyricBlock);
						
					} //end p loop
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
