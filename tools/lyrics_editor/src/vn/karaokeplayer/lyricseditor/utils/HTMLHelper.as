package vn.karaokeplayer.lyricseditor.utils {
	import vn.karaokeplayer.utils.StringUtil;
	import vn.karaokeplayer.utils.TimeUtil;

	/**
	 * @author Thanh Tran
	 */
	public class HTMLHelper {
		
		public static const HTML_TAG: RegExp = /<\/?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)\/?>/g;
		public static const HTML_NEWLINE: RegExp = /(<br>|<br\/>|<\/p>)/ig;
		public static const TIMEMARK_COLOR: String = "#0033FF";  
		
		/**
		 * Inserts a time mark link into a HTML string.
		 * @param htmlstr		HTML string to be processed  
		 * @param caretIndex	caret index of text field
		 * @param timeValue 	value of the time mark
		 */
		public static function insertTimeMarkLink(htmlstr: String, caretIndex: int, timeValue: uint): String {
			var htmlIndex: int = HTMLHelper.calculateHtmlPosition(htmlstr, caretIndex);
			var newStr: String = htmlstr.substring(0, htmlIndex) + 
								 HTMLHelper.generateTimeMarkLink(timeValue, true) +
								 htmlstr.slice(htmlIndex);
			return newStr;
		}

		/**
		 * Generates a time mark HTML link
		 *  
		 */
		public static function generateTimeMarkLink(timeValue: uint, withFontTag: Boolean = true, color: Number = NaN): String {
			var str: String = '<A HREF="event:' + timeValue + '" TARGET="">{' + TimeUtil.msToClockString(timeValue, true) + '}</A>';
			if(withFontTag) {
				var colorstr: String = TIMEMARK_COLOR;
				if(!isNaN(color)) colorstr = color.toString(16);
				str = '<FONT FACE="DigitRegular" SIZE="16" COLOR="' +TIMEMARK_COLOR +'" LETTERSPACING="0" KERNING="0">' + str + '</FONT>';
			}
			
			return str;
		}
		
		/**
		 * @param htmlstr	HTML string to search for
		 * @param newTime	new time value
		 * @param oldTime	old time to replace in the string, font tag is ignored
		 * @return new time mark link, null if oldTime is not found 
		 */
		public static function replaceTimeMarkLink(htmlstr: String, newTime: uint, oldTime: uint, color: Number = NaN): String {
			var result: Object = searchTimeMarkLink(htmlstr, oldTime);
			if(result) {
				var newTimeMark: String = generateTimeMarkLink(newTime, false, color);
				return result[1] + newTimeMark + result[2];
			} else {
				return null;	
			}
		}
		
		/**
		 * @param htmlstr	HTML string to search for
		 * @param timeValue	time value ofthe time mark to be removed
		 * @return string with time marke removed, null if time value is not found 
		 */
		public static function removeTimeMarkLink(htmlstr: String, timeValue: uint): String {
			var result: Array = searchTimeMarkLink(htmlstr, timeValue);
			if(result) {
				//trace("removing time mark: " + timeValue);
				return result[1] + result[2];
			} else {
				return null; 
			}
			
		}
		
		/**
		 * @return an object with 3 properties: [0] full matched string, [1] the string part before the time mark, [2] the string part after the time mark;<br/> null if time mark not found 
		 */
		public static function searchTimeMarkLink(htmlstr: String, timeValue: uint): Array {
			//var pattern: String = '([\\w\\W]*)<FONT FACE="DigitRegular" [\\w\\W]*?><A HREF="event:' + String(timeValue) + '"[\\w\\W]*?>[\\w\\W]*?</A></FONT>([\\w\\W]*)';
			//trace('pattern: ' + (pattern));
			//var reg: RegExp = new RegExp(pattern, "i");
			//var result: Object = reg.exec(htmlstr);
			var timeMark: String = generateTimeMarkLink(timeValue, false);
			trace('timeMark: ' + (timeMark));
			var result: Array = htmlstr.split(timeMark);
			trace('result: ' + (result));
			result.unshift(htmlstr);
			if(result.length == 3) return result;
			else return null;
		}

		/**
		 * Calculates the correct index of character in HTML <br/>
		 * This function is from: http://www.flexer.info/2008/03/26/find-cursor-position-in-a-htmltext-object-richtexteditor-textarea-textfield-update/  
		 */
		public static function calculateHtmlPosition(htmlstr: String, pos: int): int {
			// we return -1 (not found) if the position is bad
			if (pos <= -1) return -1;
 
			// characters that appears when a tag starts
			var openTags: Array = ["<","&"];
			// characters that appears when a tag ends
			var closeTags: Array = [">",";"];
			// the tag should be replaced with
			// ex: &amp; is & and has 1 as length but normal 
			// tags have 0 length
			var tagReplaceLength: Array = [0,1];
			// flag to know when we are inside a tag
			var isInsideTag: Boolean = false;
			var cnt: int = 0;
			// the id of the tag opening found
			var tagId: int = -1;
			var tagContent: String = "";
 
			for (var i: int = 0;i < htmlstr.length;i++) {
				// if the counter passes the position specified
				// means that we reach the text position
				if (cnt >= pos) break;
				// current char	
				var currentChar: String = htmlstr.charAt(i);
				// checking if the current char is in the open tag array
				for (var j: int = 0;j < openTags.length;j++) {
					if (currentChar == openTags[j]) {
						// set flag
						isInsideTag = true;
						// store the tag open id
						tagId = j;
					}
				}
				if (!isInsideTag) {
					// increment the counter
					cnt++;
				} else {
					// store the tag content
					// needed afterwards to find new lines
					tagContent += currentChar;
				}
				if (currentChar == closeTags[tagId]) {
					// we ad the replace length 
					if (tagId > -1) cnt += tagReplaceLength[tagId];
					// if we encounter the </P> tag we increment the counter
					// because of new line character
					if (tagContent.toLowerCase() == "</p>" ||
						tagContent.toLowerCase() == "<br>" ||
						tagContent.toLowerCase() == "<br/>") 
						cnt++;
					// set flag 
					isInsideTag = false;
					// reset tag content
					tagContent = "";
				}
			}
			// return de position in html text
			return i;
		}
		
		public static function stripHTML(htmlstr: String): String {
			var s: String = htmlstr.replace(HTML_NEWLINE, "\n");
			s = s.replace(HTML_TAG,"");
			
			return s;
		}
		
		public static function validate(htmlstr: String): String {
			//var timeReg: RegExp = /{(\d{2}:)?\d{2}:\d{2}.\d{2,3}}/g;
			//var result: Object = plainstr;
			var s: String = removeErrorMarks(htmlstr);
			s = validateStartLine(s, stripHTML(s));
			s = validateTimeSequence(s, stripHTML(s));
			s = validateLastTimeMark(s, stripHTML(s));
			
			return s;
		}
		
		private static function validateStartLine(htmlstr: String, plainstr: String): String {
			var lineReg: RegExp = /^({(?:\d{2}:)?\d{2}:\d{2}.\d{2,3}})?[\w\W]*?$/gm;
			var lastIndex: int = 0;
			var result: Object = lineReg.exec(plainstr);
			var errIndex: Array = [];
			
			while(result != null) {
				//trace('result[1]: ' + (result[1]));
				if(!result[1]) {
					//time mark at line start missing
					//insertHTMLText(htmlstr, lineReg.lastIndex, '<font color="#FF0000">{!}</font>');
					errIndex.push(lastIndex + 1); // +1 to start of next line
				}
				lastIndex = lineReg.lastIndex;
				result = lineReg.exec(plainstr);
			}
			
			var s: String = htmlstr;
			for (var i : int = 0; i < errIndex.length; i++) {
				//(i*3) to compensate new newly added charaters {!}
				s = insertHTMLText(s, errIndex[i] + (i*3), '<font color="#FF0000">{!}</font>');	
			}
			
			return s;
		}
		
		private static function validateTimeSequence(htmlstr: String, plainstr: String): String {
			var timeReg: RegExp = /{((?:\d{2}:)?\d{2}:\d{2}.\d{2,3})}/g;
			var lastTime: uint = 0;
			var curTime: uint = 0;
			var result: Object = timeReg.exec(plainstr);
			var errIndex: Array = [];
			var s: String = htmlstr;
			
			while(result != null) {
				//trace('result[1]: ' + (result[1]));
				curTime = TimeUtil.clockStringToMs(result[1]);
				if(curTime < lastTime) {				 
					errIndex.push(timeReg.lastIndex - 11); //-11 to move back to start of time mark
//					s = replaceTimeMarkLink(s, curTime, curTime, 0xFF0000); 
				}
				lastTime = curTime;
				result = timeReg.exec(plainstr);
			}
			
			for (var i : int = 0; i < errIndex.length; i++) {
				//(i*3) to compensate new newly added charaters {!}
				s = insertHTMLText(s, errIndex[i] + (i*3), '<font color="#FF0000">{!}</font>');	
			}
			
			return s;
		}
		
		private static function validateLastTimeMark(htmlstr: String, plainstr: String): String {
//			trace('htmlstr: ' + (htmlstr));
			var lastReg: RegExp = /{((?:\d{2}:)?\d{2}:\d{2}.\d{2,3})}\s*$/;
			var result: Object = lastReg.exec(plainstr);
			var s: String = htmlstr;
			if(!result) {
				/*
				var lastCharReg: RegExp = /\S\s*?$/;
				var test: Object = lastCharReg.exec(plainstr);
				var index: int = plainstr.length;
				trace('plainstr.length: ' + (plainstr.length));
				if(test) {
					index = plainstr.length - test[0].length;
					trace('test[0]: ' + (test[0]));
					trace('test[0].length: ' + (test[0].length));
					trace('lastCharReg.lastIndex: ' + (lastCharReg.lastIndex));
					trace('index: ' + (index)); 
				}*/
				var index: int = s.lastIndexOf("</P>");
//				trace('index: ' + (index));
				
				s = s.substring(0, index) + 
					'<font color="#FF0000">{!}</font>' +			 
					s.slice(index); 
			}
			
			return s;
		}
		
		private static function removeErrorMarks(htmlstr: String): String {
			return htmlstr.replace(/{!}/ig, '');
		}

		public static function insertHTMLText(htmlstr: String, caretIndex: int, insertText: String): String {
			var htmlIndex: int = HTMLHelper.calculateHtmlPosition(htmlstr, caretIndex);
			var s: String = htmlstr.substring(0, htmlIndex) + 
								 insertText +
								 htmlstr.slice(htmlIndex);
			return s;
		}
	}
}