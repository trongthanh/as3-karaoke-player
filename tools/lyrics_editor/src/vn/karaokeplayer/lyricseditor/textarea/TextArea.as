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
	import org.osflash.signals.Signal;
	import vn.karaokeplayer.lyricseditor.managers.ErrorMessageManager;
	import vn.karaokeplayer.lyricseditor.controls.ToolTip;
	import fl.controls.ScrollBarDirection;
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
		private var _vscroll: UIScrollBar;
		private var _hscroll: UIScrollBar;		
		private var _tf: TextField;
		private var _fm: TextFormat;
		private var _htmlstr: String = "";
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
		/** internal width */
		private var _width: Number;
		/** internal height */
		private var _height: Number;
		
		/**
		 * Argument: ok to validate (Boolean);
		 */
		public var validateOK: Signal;
		private var _isValidateOK: Boolean;
		
		public function TextArea() {
			init();
		}

		private function init(): void {
			_width = 600;
			_fm = new TextFormat(FontLib.DEFAULT_FONT_NAME, 14);
			
			_tf = new TextField();
			//TODO: more customization for text field
			_tf.width = 585;
			_tf.height = 385;
			_tf.multiline = true;
			_tf.wordWrap = false;
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
			_timeInput.committed.add(timeInputCommittedHandler);
			_timeInput.canceled.add(timeInputCancelHandler);
			
			_vscroll = new UIScrollBar();
			_vscroll.x = _tf.width;
			_vscroll.height = _tf.height;
			_vscroll.scrollTarget = _tf;
			
			_hscroll = new UIScrollBar();
			_hscroll.direction = ScrollBarDirection.HORIZONTAL;
			_hscroll.y = _tf.height;
			_hscroll.width = _tf.width;
			_hscroll.scrollTarget = _tf;
						
			addChild(_tf);
			addChild(_vscroll);
			addChild(_hscroll);
			addChild(_timeInput);
			
			validateOK = new Signal(Boolean);
			_isValidateOK = false;
			
			ToolTip.attach(_timeInput.cancelButton, "Delete time mark");
			ToolTip.attach(_timeInput.okButton, "Accept time mark");
			ToolTip.attach(_timeInput.resetButton, "Reset time mark value");
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
			//trace('changed _htmlstr: ' + (_htmlstr));
			if(!_isValidateOK && _tf.length > 0) {
				_isValidateOK = true;
				validateOK.dispatch(_isValidateOK);
			} else if (_isValidateOK && _tf.length == 0) {
				_isValidateOK = false;
				validateOK.dispatch(_isValidateOK);
			}
		}

		private function timeInputCancelHandler(timeValue: uint): void {
			if(_insertIndex >= 0) {
				//inserting new time mark
				//just hide the time input
			} else {
				//remove editing time mark
				_htmlstr = HTMLHelper.removeTimeMarkLink(_htmlstr, timeValue);
			}
			
			if(_htmlstr) {
				 _tf.htmlText = _htmlstr;
			} else {
				if(_insertIndex < 0) ErrorMessageManager.showMessage("Internal error: Cannot remove time mark.");
				trace("cannot remove time mark " + timeValue);
			}
			//_tf.setTextFormat(_fm);
			
			/*
			if(_insertIndex >= 0) {
				setCaretIndex(_insertIndex);
			} else {
				setCaretIndex(_lastCaretIndex);
			}*/

			_timeInput.visible = false;
		}
		private function timeInputCommittedHandler(timeValue: uint): void {
			var insertedTimeMark: Array = HTMLHelper.searchTimeMarkLink(_htmlstr, timeValue)
			
			if(_insertIndex >= 0) {
				if(insertedTimeMark) {
					//this time value is already set
					trace("time mark existed");
					ErrorMessageManager.showMessage("Time mark existed");
					return;
				}
				_htmlstr = HTMLHelper.insertTimeMarkLink(_htmlstr, _insertIndex, timeValue);
					
			} else {
				if(insertedTimeMark && timeValue != _replaceTimeValue) {
					//this value duplicate one of another time mark
					ErrorMessageManager.showMessage("Time mark duplicated");
					trace("time mark existed");
					return;	
				}
				_htmlstr = HTMLHelper.replaceTimeMarkLink(_htmlstr, timeValue, _replaceTimeValue);
			}
					   
			if(_htmlstr) {
				 _tf.htmlText = _htmlstr;
			} else {
				ErrorMessageManager.showMessage("Internal error: Cannot insert/replace time mark.");
				trace("cannot insert/replace time mark " + timeValue);
			}
			//_tf.setTextFormat(_fm);
			
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
			if(!value) value = " ";
			_tf.htmlText = value;
			_htmlstr = _tf.htmlText;
			_vscroll.update();
			_hscroll.update();
			if(!_isValidateOK) {
				_isValidateOK = true;
				validateOK.dispatch(_isValidateOK);
			}
		}

		public function get htmlText(): String {
			return _tf.htmlText;
		}
		
		public function set text(value: String): void {
			if(!value) value = " ";
			_tf.text = value;
			_htmlstr = _tf.htmlText;
			_vscroll.update();
			_hscroll.update();
			if(!_isValidateOK) {
				_isValidateOK = true;
				validateOK.dispatch(_isValidateOK);
			}
		}

		public function get text(): String {
			return _tf.text;
		}

		private function textInputHandler(event: TextEvent): void {
			//trace(event.text);
			//trace(event.text.charCodeAt(0));
			if(event.text == "") {
				//user delete something
				//trace("full text : " + _tf.text);
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
		
		/**
		 * @return true if time marks OK, false if there are still errors
		 */
		public function validate(): Boolean {
			ErrorMessageManager.clearMessage();
			_htmlstr = HTMLHelper.validate(_htmlstr);
			_tf.htmlText = _htmlstr;
			if(_htmlstr.indexOf("{!}") == -1) {
				return true;
			} else {
				return false;
			}
		}

		public function insertTimeMark(timeValue: int = -1, caretIndex: int = -1): void {
			_insertIndex = (caretIndex >= 0)? caretIndex: _tf.caretIndex;
			trace('insert time mark: ' + (_insertIndex) + ", time: " + timeValue);
			
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
			ErrorMessageManager.clearMessage();
			var x: Number = 0;
			var y: Number = 0;
			_lastCaretIndex = _tf.caretIndex;  
			if(isInsert) {
				var caretPos: int = _lastCaretIndex;
				//check for new line character or end of string:
				//trace("charcode at " + caretPos + " : " + _tf.text.charCodeAt(caretPos));
				
				var lc: uint= 0;
				
				while(caretPos > 0 && (_tf.text.charCodeAt(caretPos) == 13 || isNaN(_tf.text.charCodeAt(caretPos)))) {
					caretPos -= 1;
					
					lc ++;
					if(lc > 100000) {
						trace("showTimeInput: infinitive loops detected");
						break;
					}
				}
				
				var bounds: Rectangle = _tf.getCharBoundaries(caretPos);
				
				//check if text field is scrolled
				//trace("_tf.scrollV: " + _tf.scrollV);
				var scrollLine: int = _tf.scrollV - 1;
				var subtractY: Number = _tf.getLineMetrics(scrollLine).height * (scrollLine);
				//trace('subtractY: ' + (subtractY));
				
				if(bounds) {
					x = bounds.x - _hscroll.scrollPosition;
					y = bounds.y - subtractY;
				}
					
			} else {
				x = mouseX; 
				y = mouseY;
			}
			_timeInput.timeValue = (timeValue < 0) ? 0 : timeValue;
			
			x += 10;
			y += 10;
			
			if(x + _timeInput.width > this.width) {
				x = this.width - _timeInput.width; 
			}
			if(y + _timeInput.height > this.height) {
				y = this.height - _timeInput.height;
			}
			
			_timeInput.x = x;
			_timeInput.y = y;
			_timeInput.visible = true;	
		}

		override public function set width(value: Number): void {
			if(isNaN(value)) return;
			_width = value;
			_tf.width = value - _vscroll.width;
			_vscroll.x = _tf.width;
			_hscroll.width = _tf.width;
		}

		override public function get width(): Number{
			return _width;
		}

		override public function set height(value: Number): void {
			if(isNaN(value)) return;
			_height = value;
			_tf.height = value - _hscroll.height;
			_vscroll.height = _tf.height;
			_hscroll.y = _tf.height;
		}

		override public function get height(): Number {
			return _tf.height;
		}
	}
}
