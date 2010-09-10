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
	import fl.controls.UIScrollBar;
	import vn.karaokeplayer.lyricseditor.controls.TimeInput;
	import vn.karaokeplayer.lyricseditor.utils.FontLib;
	import vn.karaokeplayer.lyricseditor.utils.HTMLHelper;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	/**
	 * @author Thanh Tran
	 */
	public class TextArea extends Sprite {
		private var _scroll: UIScrollBar;		
		private var _tf: TextField;
		private var _fm: TextFormat;
		private var _htmlstr: String;
		private var _timeInput: TimeInput;
		private var _css: XML = <![CDATA[
		a {	color: #0000FF;	}
		a:link { text-decoration: none; }
		a:hover { text-decoration: underline; }
		.synced { color: #FF0000; }
		]]>;
		
		private var _insertIndex: int;
		private var _lastCaretIndex: int;
		private var _replaceTimeValue: uint;
		
		
		public function TextArea() {
			init();
		}

		private function init(): void {
			_fm = new TextFormat(FontLib.FONT_NAME, 14);
			
			_tf = new TextField();
			//TODO: more customization for text field
			_tf.width = 600;
			_tf.height = 400;
			_tf.multiline = true;
			_tf.wordWrap = true;
			_tf.embedFonts = true;
			_tf.antiAliasType = AntiAliasType.ADVANCED;
//			_tf.textColor = 0xFFFFFF; IMPORTANT
			_tf.defaultTextFormat = _fm;
			_tf.addEventListener(TextEvent.LINK, textLinkHandler);
			_tf.addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
			_tf.addEventListener(Event.CHANGE, textChangeHandler);
			_tf.addEventListener(KeyboardEvent.KEY_UP, textKeyUpHandler);
			
			var styles: StyleSheet = new StyleSheet();
			styles.parseCSS(_css.toString());
			
			//_txt.styleSheet = styles;
			_tf.type = TextFieldType.INPUT;
			
			_timeInput = new TimeInput();
			_timeInput.visible = false;
			_timeInput.committed.add(timeInputCommittedHandler);			_timeInput.canceled.add(timeInputCancelHandler);
			
			_scroll = new UIScrollBar();
			
			_scroll.x = _tf.width;
			//_scroll.y = _tf.y;
			_scroll.height = _tf.height;
			_scroll.scrollTarget = _tf;
			
			addChild(_tf);
			addChild(_scroll);
			addChild(_timeInput);
		}

		private function textKeyUpHandler(event: KeyboardEvent): void {
			//trace("key up:" + event.keyCode);
			//left: 37, up 38, right 39, down 40
			var inTimeMark: Boolean = checkCaretInTimeMark();
			switch(event.keyCode){
				case 37:
				case 40:
					//left or down:
					if(inTimeMark) {
						moveCaretOutOfTimeMark();
						trace("move caret to left of time mark");
					}
					break;
				case 38:
				case 39:
					//right or up
					if(inTimeMark) {
						moveCaretOutOfTimeMark(true);
						trace("move caret to left of time mark");
					}
					break;
				default:
					//not an arrow button
			}
			
		}

		private function textChangeHandler(event : Event) : void {
			//search for broken time mark
			//(({\d\d:\d\d.\d\d\d)[^}])|([^{](\d\d:\d\d.\d\d\d)})
			_htmlstr = _tf.htmlText;
//			trace('changed _htmlstr: ' + (_htmlstr));
			
		}

		private function timeInputCancelHandler(timeValue: uint): void {
			if(_insertIndex >= 0) {
				//inserting new time mark
				//just hide the time input
			} else {
				//remove editing time mark
				_htmlstr = HTMLHelper.removeTimeMarkLink(_htmlstr, timeValue);
			}
			
			if(_htmlstr) _tf.htmlText = _htmlstr;
			else trace("cannot remove time mark " + timeValue);
			_tf.setTextFormat(_fm);
			
			/*
			if(_insertIndex >= 0) {
				setCaretIndex(_insertIndex);
			} else {
				setCaretIndex(_lastCaretIndex);
			}*/

			_timeInput.visible = false;
		}
		private function timeInputCommittedHandler(timeValue: uint): void {
			var insertedTimeMark: Object = HTMLHelper.searchTimeMarkLink(_htmlstr, timeValue)
			
			if(_insertIndex >= 0) {
				if(insertedTimeMark) {
					//this time value is already set
					trace("time mark existed");
					return;
				}
				_htmlstr = HTMLHelper.insertTimeMarkLink(_htmlstr, _insertIndex, timeValue);
					
			} else {
				if(insertedTimeMark && timeValue != _replaceTimeValue) {
					//this value duplicate one of another time mark
					trace("time mark existed");
					return;	
				}
				_htmlstr = HTMLHelper.replaceTimeMarkLink(_htmlstr, timeValue, _replaceTimeValue);
			}
					   
			if(_htmlstr) _tf.htmlText = _htmlstr;
			else trace("cannot insert/replace time mark " + timeValue);
			_tf.setTextFormat(_fm);
			
			/* won't set caret to avoid scroll being updated
			if(_insertIndex >= 0) {
				setCaretIndex(_insertIndex);
			} else {
				setCaretIndex(_lastCaretIndex);
				moveCaretOutOfTimeMark();
			}*/
			
			_timeInput.visible = false;
		}

		public function set htmlText(value: String): void {
			_htmlstr = value;
			_tf.htmlText = _htmlstr;
			//recapture html text from text field to retain HTML format
			//_htmlstr = _tf.htmlText;
			_tf.setTextFormat(_fm);
			_scroll.update();
		}

		public function get htmlText(): String {
			return _tf.htmlText;
		}

		private function textInputHandler(event: TextEvent): void {
			//trace(event.text);
			//trace(event.text.charCodeAt(0));
			if(event.text == "") {
				//user delete something
				trace("full text : " + _tf.text);
			}
		}

		private function textLinkHandler(event: TextEvent): void {
			_insertIndex = -1;
			_replaceTimeValue = int(event.text); 
			showTimeInput(_replaceTimeValue);
			
			moveCaretOutOfTimeMark();	
		}

		public function get textField(): TextField {
			return _tf;
		}
		
		public function insertTimeMark(timeValue: int = -1, caretIndex: int = -1): void {
			_insertIndex = (caretIndex >= 0)? caretIndex: _tf.caretIndex;
			trace('_insertIndex: ' + (_insertIndex));
			
			showTimeInput(timeValue, true);
		}
		
		private function moveCaretOutOfTimeMark(rightof: Boolean = false): void {
			var caretIndex: int = _tf.caretIndex;
			if(rightof) {
				//move caret out of the time mark link to the right:
				var firstCloseBracket: int = _tf.text.slice(caretIndex).indexOf("}");
				//remember to count the length before caret 
				firstCloseBracket += caretIndex + 1;
				
				setCaretIndex(firstCloseBracket);
			} else {
				//move caret out of the time mark link to the left:
				var lastOpenBracket: int = _tf.text.substring(0, caretIndex).lastIndexOf("{");
				
				setCaretIndex(lastOpenBracket);	
			}
		}
		
		private function setCaretIndex(index: int): void {
			if(index < 0) {
				index = 0;
			} else if (index >= _tf.length) {
				index = _tf.length - 1;
			}
			stage.focus = _tf;
			_tf.setSelection(index, index);
		}

		private function checkCaretInTimeMark(): Boolean {
			var str: String = _tf.text;
			var caretIndex: int =  _tf.caretIndex;
			var subStr: String = str.slice(caretIndex);
			var openBracketIdx: int = subStr.indexOf("{");
			var closeBracketIdx: int = subStr.indexOf("}");
			
			if(closeBracketIdx == -1) {
				//no bracket found, caret not inside and time mark
				return false;
			} else if (closeBracketIdx >= 0 && (closeBracketIdx < openBracketIdx || openBracketIdx == -1)) {
				//in case: the first braket after caret is close bracket -> caret between brackets  
				return true;
			} else {
				return false;	
			}
			
		}
		
		private function showTimeInput(timeValue: int = -1, isInsert: Boolean = false): void {
			var x: Number = 0;
			var y: Number = 0;
			_lastCaretIndex = _tf.caretIndex;  
			if(isInsert) {
				var caretPos: int = _lastCaretIndex;
				//check for new line character or end of string:
				while(_tf.text.charCodeAt(caretPos) == 13 || isNaN(_tf.text.charCodeAt(caretPos))) {
					caretPos -= 1;
				}
				
				var bounds: Rectangle = _tf.getCharBoundaries(caretPos);
				
				//check if text field is scrolled
				trace("_tf.scrollV: " + _tf.scrollV);
				var scrollV: int = _tf.scrollV;
				var subtractY: Number = _tf.getLineMetrics(scrollV).height * (scrollV - 1);
				trace('subtractY: ' + (subtractY));
				
				if(bounds) {
					x = bounds.x;
					y = bounds.y - subtractY;
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

		override public function set width(value: Number): void {
			_tf.width = value - _scroll.width;
			_scroll.x = _tf.width;
		}

		override public function set height(value: Number): void {
			_tf.height = value;
			_scroll.height = value;
		}
	}
}
