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
package vn.karaokeplayer.parsers {
	import vn.karaokeplayer.utils.TimeUtil;
	import vn.karaokeplayer.utils.KarPlayerVersion;
	
	import vn.karaokeplayer.data.BlockInfo;
	import vn.karaokeplayer.data.KarPlayerError;
	import vn.karaokeplayer.data.LineInfo;
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.data.SongLyrics;
	import vn.karaokeplayer.karplayer_internal;
	
	use namespace karplayer_internal;
	/**
	 * This parser parses the default timed-text based lyrics XML file
	 * @author Thanh Tran
	 */
	public class TimedTextParser implements ILyricsParser {
		public static const VERSION: String = KarPlayerVersion.VERSION;
		
		public var tt: Namespace = new Namespace("http://www.w3.org/ns/ttml");
		public var tts: Namespace = new Namespace("http://www.w3.org/ns/ttml#styling");
		public var ttm: Namespace = new Namespace("http://www.w3.org/ns/ttml#metadata");
		public var kar:Namespace = new Namespace("http://code.google.com/p/as3-karaoke-player");
		
		private static const STYLES: Array = ["b", "m", "f"];
		
		/**
		 * parse the TimedText XML data into SongInfo
		 * @param xml	TimedText xml data
		 */
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
			
			songInfo.songXML = xml;
			
			return songInfo;
		}
		
		/**
		 * parse head part of song XML
		 * @param	head
		 * @param	songInfo
		 */
		karplayer_internal function parseSongHead(head: XML, songInfo: SongInfo): void {
			parseMetadata(head.metadata[0], songInfo);
			//TODO: to parse custom styling
		}
		
		/**
		 * parse metadata part of song XML
		 * @param metadata	metadata part of the XML
		 * @param songInfo	value object to put data to
		 */
		karplayer_internal function parseMetadata(metadata: XML, songInfo: SongInfo): void {
			songInfo.title = metadata.ttm::title.toString();
			songInfo.description = metadata.ttm::desc.toString();
			songInfo.copyright = metadata.ttm::copyright.toString();
			//get extra metadata:
			songInfo.id = (metadata.kar::id[0]) ? metadata.kar::id.toString() : metadata.tt::id.toString();
			songInfo.composer = (metadata.kar::composer[0]) ? metadata.kar::composer.toString() : metadata.tt::composer.toString();			songInfo.styleof = (metadata.kar::styleof[0]) ? metadata.kar::styleof.toString() : metadata.tt::styleof.toString();
			songInfo.genre = (metadata.kar::genre[0]) ? metadata.kar::genre.toString() : metadata.tt::genre.toString();
			songInfo.mood = (metadata.kar::mood[0]) ? metadata.kar::mood.toString() : metadata.tt::mood.toString();
			songInfo.beatURL = (metadata.kar::audio[0]) ? metadata.kar::audio.toString() : metadata.tt::audio.toString();
			songInfo.extra = getExtraMetadata(metadata);
		}

		/**
		 * 
		 *
		 */
		karplayer_internal function parseSongLyrics(body: XML, songInfo: SongInfo): void {
			var divList: XMLList = body.div;
			var divLen: int = divList.length();
			if (divLen == 0) {
				//throw new KarPlayerError(KarPlayerError.INVALID_XML, "<div> tags are missing from <body>: " + body.toXMLString());
				//accept empty lyrics file
				trace("[KarPlayer] Warning: <div> tags are missing from <body>: " + body.toXMLString());
				songInfo.lyrics = new SongLyrics();
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
					//throw new KarPlayerError(KarPlayerError.INVALID_XML, "<p> tags are missing from this <div> block: " + div.toXMLString());
					trace("[KarPlayer] Warning: <p> tags are missing from this <div> block: " + div.toXMLString());
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
								throw new KarPlayerError(KarPlayerError.INVALID_XML,"both <div> and first <p> don't have begin property: " + div.toXMLString());
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

			//TODO: move these time string parser to TimeUtil
			// first check for clock format or partial clock format
			var theTime:Number = TimeUtil.clockStringToMs(timeStr);
			
			if(theTime) return theTime;			


			// next check for offset time
			theTime = TimeUtil.timeOffsetToMs(timeStr);
			
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
		
		karplayer_internal function getExtraMetadata(metadata: XML): Object {
			var data: Object = {};
			var i : XML;
			var extraList: XMLList = metadata.tt::extra;
			//get data from default namespace
			for each (i in extraList) {
				data[i.@id[0]] = i.toString();
			}
			//get data from kar namespace (will overwrite default)
			extraList = metadata.kar::extra;
			for each (i in extraList) {
				data[i.@id[0]] = i.toString();
			}
			
			//trace('data: ' + (data));
			return data;
		}
	}
}
