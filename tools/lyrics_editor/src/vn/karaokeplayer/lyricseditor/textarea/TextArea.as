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
	import flash.text.StyleSheet;
	import flash.events.TextEvent;
	import flash.text.TextFormat;
	import flash.text.TextFieldType;
	import flash.text.TextField;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	public class TextArea extends Sprite {
		private var _txt: TextField;
		private var _css: XML = <![CDATA[
		a {	color: #0000FF;	}
		a:link { text-decoration: none; }
		a:hover { text-decoration: underline; }
		.synced { color: #FF0000; }
		]]>;
		
		public function TextArea() {
			init();
		}

		private function init(): void {
			_txt = new TextField();
			_txt.width = 600;
			_txt.height = 400;
			_txt.multiline = true;
			_txt.wordWrap = true;
			_txt.type = TextFieldType.INPUT;
			_txt.defaultTextFormat = new TextFormat("_sans", 12);
			_txt.addEventListener(TextEvent.LINK, textLinkHandler);
			_txt.addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
			
			var styles: StyleSheet = new StyleSheet();
			styles.parseCSS(_css.toString());
			
			_txt.styleSheet = styles;
			
			addChild(_txt);
		}

		public function set htmlText(value: String): void {
			_txt.htmlText = value; 
		}
		
		public function get htmlText(): String {
			return _txt.htmlText;
		}

		private function textInputHandler(event: TextEvent): void {
			
		}

		private function textLinkHandler(event: TextEvent): void {
			trace("link called: " + event.text);
		}

		public function get textField(): TextField {
			return _txt;
		}
	}
}
