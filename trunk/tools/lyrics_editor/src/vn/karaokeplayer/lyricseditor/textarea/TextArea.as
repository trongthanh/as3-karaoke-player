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
	import flash.geom.Rectangle;
	import vn.karaokeplayer.lyricseditor.utils.HTMLHelper;
	import vn.karaokeplayer.utils.TimeUtil;
	import vn.karaokeplayer.lyricseditor.controls.TimeInput;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	/**
	 * @author Thanh Tran
	 */
	public class TextArea extends Sprite {
		private var _txt: TextField;
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
			init();
		}

		private function init(): void {
			_txt = new TextField();
			//TODO: more customization for text field
			_txt.width = 600;
			_txt.height = 400;
			_txt.multiline = true;
			_txt.wordWrap = true;
			_txt.defaultTextFormat = new TextFormat("_sans", 16);
			_txt.addEventListener(TextEvent.LINK, textLinkHandler);
			_txt.addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
			
			var styles: StyleSheet = new StyleSheet();
			styles.parseCSS(_css.toString());
			
			//_txt.styleSheet = styles;
			_txt.type = TextFieldType.INPUT;
			
			_timeInput = new TimeInput();
			_timeInput.visible = false;
			_timeInput.valueCommitted.add(timeInputCommittedHandler);
			
			addChild(_txt);
			addChild(_timeInput);
		}

		private function timeInputCommittedHandler(timeValue: uint): void {
			if(_insertIndex >= 0) {
				_htmlstr = HTMLHelper.insertTimeMarkLink(_htmlstr, _insertIndex, timeValue);
			} else {
				_htmlstr = HTMLHelper.replaceTimeMarkLink(_htmlstr, timeValue, _replaceTimeValue);
			}
					   
			_txt.htmlText = _htmlstr;
			_txt.setTextFormat(new TextFormat("_sans", 16));
			_timeInput.visible = false;
		}

		public function set htmlText(value: String): void {
			_htmlstr = value;
			_txt.htmlText = _htmlstr; 
		}
		
		public function get htmlText(): String {
			return _txt.htmlText;
		}

		private function textInputHandler(event: TextEvent): void {
			
		}

		private function textLinkHandler(event: TextEvent): void {
			_insertIndex = -1;
			_replaceTimeValue = int(event.text); 
			showTimeInput(_replaceTimeValue);
		}

		public function get textField(): TextField {
			return _txt;
		}
		
		public function insertTimeMark(caretIndex: int = -1, timeValue: int = -1): void {
			_insertIndex = (caretIndex >= 0)? caretIndex: _txt.caretIndex;
			trace('_insertIndex: ' + (_insertIndex));
			
			//temporarily set to 0 
			
			showTimeInput(timeValue);
		}
		
		private function showTimeInput(timeValue: int = -1): void {
			//var charBounds: Rectangle = _txt.; 
			var x: Number = mouseX; 
			var y: Number = mouseY;
			_timeInput.timeValue = (timeValue < 0) ? 0 : timeValue;
			
			//TODO: check for boundary;
			_timeInput.x = x + 10;			_timeInput.y = y + 10;
			_timeInput.visible = true;	
		}
		
		
	}
}
