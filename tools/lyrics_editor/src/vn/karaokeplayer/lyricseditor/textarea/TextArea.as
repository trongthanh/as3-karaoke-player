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
package vn.karaokeplayer.lyricseditor.textarea {
	import vn.karaokeplayer.lyricseditor.controls.TimeInput;
	import vn.karaokeplayer.lyricseditor.utils.HTMLHelper;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	/**
	 * @author Thanh Tran
	 */
	public class TextArea extends Sprite {
		[Embed(systemFont='Verdana'
		,fontFamily  = 'VerdanaRegularVN'
		,fontName  ='VerdanaRegularVN'
		,fontStyle   ='normal' // normal|italic
		,fontWeight  ='normal' // normal|bold
		,unicodeRange = 'U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E,U+00C0-U+00C3,U+00C8-U+00CA,U+00CC-U+00CD,U+00D0,U+00D2-U+00D5,U+00D9-U+00DA,U+00DD,U+00E0-U+00E3,U+00E8-U+00EA,U+00EC-U+00ED,U+00F2-U+00F5,U+00F9-U+00FA,U+00FD,U+0102-U+0103,U+0110-U+0111,U+0128-U+0129,U+0168-U+0169,U+01A0-U+01B0,U+1EA0-U+1EF9,U+02C6-U+0323'
		,mimeType='application/x-font'
		//,embedAsCFF='false'
		)]
		public static const FONT_CLASS:Class;
		public static const FONT_NAME: String = "VerdanaRegularVN";
		
		
		private var _tf: TextField;
		private var _htmlstr: String;
		private var _timeInput: TimeInput;
		private var _css: XML = <![CDATA[
		a {	color: #0000FF;	}
		a:link { text-decoration: none; }
		a:hover { text-decoration: underline; }
		.synced { color: #FF0000; }
		]]>;
		
		private var _timePoints: Array;
		private var _insertIndex: int;
		private var _replaceTimeValue: uint;
		
		
		public function TextArea() {
			Font.registerFont(FONT_CLASS);
			init();
		}

		private function init(): void {
			_tf = new TextField();
			//TODO: more customization for text field
			_tf.width = 600;
			_tf.height = 400;
			_tf.multiline = true;
			_tf.wordWrap = true;
			_tf.embedFonts = true;
			_tf.defaultTextFormat = new TextFormat(FONT_NAME, 16);
			_tf.addEventListener(TextEvent.LINK, textLinkHandler);
			_tf.addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
			_tf.addEventListener(Event.CHANGE, textChangeHandler);
			
			var styles: StyleSheet = new StyleSheet();
			styles.parseCSS(_css.toString());
			
			//_txt.styleSheet = styles;
			_tf.type = TextFieldType.INPUT;
			
			_timeInput = new TimeInput();
			_timeInput.visible = false;
			_timeInput.valueCommitted.add(timeInputCommittedHandler);
			
			addChild(_tf);
			addChild(_timeInput);
		}

		private function textChangeHandler(event : Event) : void {
			//search for broken time mark
			//(({\d\d:\d\d.\d\d\d)[^}])|([^{](\d\d:\d\d.\d\d\d)})
			_htmlstr = _tf.htmlText;
			trace('changed _htmlstr: ' + (_htmlstr));
		}

		private function timeInputCommittedHandler(timeValue: uint): void {
			if(_insertIndex >= 0) {
				var insertedTimeMark: Object = HTMLHelper.searchTimeMarkLink(_htmlstr, timeValue)
				if(insertedTimeMark) {
					//this time value is already set
					trace("time mark existed");
				} else {
					_htmlstr = HTMLHelper.insertTimeMarkLink(_htmlstr, _insertIndex, timeValue);	
				}
				
			} else {
				_htmlstr = HTMLHelper.replaceTimeMarkLink(_htmlstr, timeValue, _replaceTimeValue);
			}
					   
			_tf.htmlText = _htmlstr;
			_tf.setTextFormat(new TextFormat(FONT_NAME, 16));
			_timeInput.visible = false;
		}

		public function set htmlText(value: String): void {
			_htmlstr = value;
			_tf.htmlText = _htmlstr;
			_tf.setTextFormat(new TextFormat(FONT_NAME, 16)); 
		}
		
		public function get htmlText(): String {
			return _tf.htmlText;
		}

		private function textInputHandler(event: TextEvent): void {
			//trace(event.text);
			if(event.text == "") {
				//user delete something
				
			}
		}

		private function textLinkHandler(event: TextEvent): void {
			_insertIndex = -1;
			_replaceTimeValue = int(event.text); 
			showTimeInput(_replaceTimeValue);
			
			var caretIndex: int = _tf.caretIndex; 
			//move caret out of the time mark link:
			var lastOpenBracket: int = _tf.text.substring(0, caretIndex).lastIndexOf("{");
			
			_tf.setSelection(lastOpenBracket, lastOpenBracket);
		}

		public function get textField(): TextField {
			return _tf;
		}
		
		public function insertTimeMark(caretIndex: int = -1, timeValue: int = -1): void {
			_insertIndex = (caretIndex >= 0)? caretIndex: _tf.caretIndex;
			trace('_insertIndex: ' + (_insertIndex));
			
			showTimeInput(timeValue, true);
		}
		
		private function showTimeInput(timeValue: int = -1, isInsert: Boolean = false): void {
			var x: Number = 0;
			var y: Number = 0;
			if(isInsert) {
				var caretPos: int = _tf.caretIndex;
				//check for new line character or end of string:
				while(_tf.text.charCodeAt(caretPos) == 13 || isNaN(_tf.text.charCodeAt(caretPos))) {
					caretPos -= 1;
				}
				
				var bounds: Rectangle = _tf.getCharBoundaries(caretPos);
				
				if(bounds) {
					x = bounds.x;
					y = bounds.y;
				}
					
			} else {
				x = mouseX; 
				y = mouseY;
			}
			_timeInput.timeValue = (timeValue < 0) ? 0 : timeValue;
			
			//TODO: check for boundary;
			_timeInput.x = x + 10;			_timeInput.y = y + 10;
			_timeInput.visible = true;	
		}
		
		
	}
}
