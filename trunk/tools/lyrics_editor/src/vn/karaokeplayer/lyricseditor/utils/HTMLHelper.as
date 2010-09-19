package vn.karaokeplayer.lyricseditor.utils {
	import vn.karaokeplayer.utils.TimeUtil;

	/**
	 * @author Thanh Tran
	 */
	public class HTMLHelper {
		
		public static const HTML_TAG: RegExp = /<\/?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)\/?>/g;
		
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
		public static function generateTimeMarkLink(timeValue: uint, withFontTag: Boolean = true): String {
			var str: String = '<A HREF="event:' + timeValue + '" TARGET="">{' + TimeUtil.msToClockString(timeValue, true) + '}</A>';
			if(withFontTag) str = '<FONT FACE="DigitRegular" SIZE="16" COLOR="#FF3300" LETTERSPACING="0" KERNING="0">' + str + '</FONT>';
			
			return str;
		}
		
		/**
		 * @param htmlstr	HTML string to search for
		 * @param newTime	new time value
		 * @param oldTime	old time to replace in the string, font tag is ignored
		 * @return new time mark link, null if oldTime is not found 
		 */
		public static function replaceTimeMarkLink(htmlstr: String, newTime: uint, oldTime: uint ): String {
			var result: Object = searchTimeMarkLink(htmlstr, oldTime);
			if(result) {
				var newTimeMark: String = generateTimeMarkLink(newTime, false);
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
			var str: String = String(htmlstr).replace(HTML_TAG,"");
			
			return str;
		}
		
		public static function validate(htmlstr: String, plainstr: String): String {
			
			
			return null;
		}
	}
}