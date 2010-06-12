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
package thanhtran.karaokeplayer.lyrics {
	import thanhtran.karaokeplayer.Version;
	import thanhtran.karaokeplayer.data.LyricStyle;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Linear;

	import org.osflash.signals.Signal;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * TODO: use object pool to optimize memmory and performance
	 * The smallest block of texts which share the same speed
	 * @author Thanh Tran
	 */
	public class TextBlock extends Sprite {
		public static const VERSION: String = Version.VERSION;
		
		public var next: TextBlock;
		public var textColor: uint = 0x8AD420;
		public var strokeColor: uint = 0xFFFFFF;
		public var syncTextColor: uint = 0xFF9600;
		public var syncStrokeColor: uint = 0xFFFFFF;
		public var font: String = "Verdana";
		public var size: Number = 30;
		public var embedFonts: Boolean = false;
		/* milliseconds */
		public var duration: uint = 0;
		
		private var _text: String = "";
		private var _normalText: TextField;
		private var _syncText: TextField;
		private var _mask: Shape;
		
		public var completed: Signal;
		
		private var _spaceWidth: Number = 0;

		public function TextBlock() {
			completed = new Signal(TextBlock);
		}

		public function get text(): String { 
			return _text; 
		}

		public function set text(value: String): void {
			dispose();
			_text = value;		
			
			render();
		}
		
		public function setStyle(normalStyle: LyricStyle, syncStyle: LyricStyle): void {
			textColor = uint(normalStyle.color);
			strokeColor = uint(normalStyle.strokeColor);
			syncTextColor = uint(syncStyle.color);
			syncStrokeColor = uint(syncStyle.strokeColor);
			font = normalStyle.font;
			size = normalStyle.size;
			embedFonts = normalStyle.embedFonts;
			if(_text) {
				//force dispose and re-render
				text = _text;
			}
		}

		public function render(): void {
			//normal text
			var normalFormat: TextFormat = new TextFormat(font, size, textColor);
			//trace( "font : " + font );
			//trace( "embedFonts : " + embedFonts );
			_normalText = new TextField();
			_normalText.mouseEnabled = false;
			_normalText.autoSize = "left";
			_normalText.embedFonts = embedFonts;
			
			_normalText.defaultTextFormat = normalFormat;
			_normalText.text = text;
			_normalText.setTextFormat(normalFormat);
			//stroke:
			var strokeSize: Number = size / 10;
			var normalGlowFilter: GlowFilter = new GlowFilter(strokeColor, 1, strokeSize, strokeSize, 20, 2);
			_normalText.filters = [normalGlowFilter];
			//if (strokeFilters) {
				//_normalText.filters = strokeFilters;
			//} else {
				//trace("should be here once");
				//var normalGlowFilter: GlowFilter = new GlowFilter(strokeColor, 1, strokeSize, strokeSize, 20, 2);
				//strokeFilters = [normalGlowFilter];
				//_normalText.filters = strokeFilters;
			//}
			
			
			//sync text
			var syncFormat: TextFormat = new TextFormat(font, size, syncTextColor);
			_syncText = new TextField();
			_syncText.mouseEnabled = false;
			_syncText.autoSize = "left";
			_syncText.embedFonts = embedFonts;
			_syncText.defaultTextFormat = syncFormat;
			_syncText.text = text;
			_syncText.setTextFormat(syncFormat);
			//stroke:
			if (syncStrokeColor != strokeColor) {
				var syncGlowFilter: GlowFilter = new GlowFilter(syncStrokeColor, 1, strokeSize, strokeSize, 20, 2);
				_syncText.filters = [syncGlowFilter];
			}
			
			//mask
			_mask = new Shape();
			_mask.graphics.beginFill(0, 1);
			_mask.graphics.drawRect(0, 0, _syncText.width, _syncText.height);
			_mask.x = -_syncText.width;
			_syncText.mask = _mask;
			
			//TODO: consider move this to a global util to avoid creating too many objects
			//calculate blank space
			var temptf: TextField = new TextField();
			temptf.defaultTextFormat = normalFormat;
			temptf.text = " ";
			_spaceWidth = temptf.textWidth;
//			trace('spaceWidth: ' + (_spaceWidth)); 
			
			this.addChild(_normalText);
			this.addChild(_syncText);		
			this.addChild(_mask);	
		}
		/**
		 * TODO: consider split the words and animate them equally in time (instead of text length right now) 
		 */
		public function play(): void {
			reset();
			GTweener.to(_mask, duration * 0.001, {x: _syncText.x }, {ease: Linear.easeNone, onComplete: textCompleteHandler });
		}

		private function textCompleteHandler(tween: GTween): void {
			completed.dispatch(this);
		}

		override public function get width(): Number { 
			if (_normalText) return _normalText.width + _spaceWidth - 4; //automatically add extra space for big font
			else return super.width; 
		}

		override public function set width(value: Number): void {
			trace("width of this TextBit object is read only");
		}

		override public function get height(): Number { 
			if (_normalText) return _normalText.height;
			else return super.height; 
		}

		override public function set height(value: Number): void {
			trace("height of this TextBit object is read only");
		}
		
		public function reset(): void {
			_mask.x = -_syncText.width;
			GTweener.removeTweens(_mask);
		}

		public function dispose(): void {
			if (_normalText) {
				if (_normalText.parent) _normalText.parent.removeChild(_normalText);
				_normalText = null;
			}
			if (_syncText) {
				if ( _syncText.parent) _syncText.parent.removeChild(_syncText);
				_syncText = null;
			}
			_text = ""; 
		}
	}
}