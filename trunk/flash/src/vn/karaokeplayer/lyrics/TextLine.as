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
package vn.karaokeplayer.lyrics {
	import vn.karaokeplayer.utils.IKarFactory;
	import org.osflash.signals.ISignal;
	import vn.karaokeplayer.data.BlockInfo;
	import vn.karaokeplayer.data.LineInfo;
	import vn.karaokeplayer.data.LyricStyle;
	import vn.karaokeplayer.utils.Version;

	import org.osflash.signals.Signal;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * A line of text
	 * @author Thanh Tran
	 * TODO: pass screen width from LyricPlayer and auto reduce font size if text line width exceed
	 */
	public class TextLine extends Sprite implements ILine {
		public static const VERSION: String = Version.VERSION;
		private var _factory: IKarFactory;	
		private var _completed: Signal;
		private var _blocks: Array;
		// these style are set from SongLyrics
		private var _normalStyle: LyricStyle;
		private var _syncStyle: LyricStyle;
		private var _data: LineInfo;
		/* number of blocks */
		private var _len: uint;
		private var _playing: Boolean;
		private var _complete: Boolean;
		/** milliseconds */
		private var _dur: Number = 0;
		/** milliseconds */
		private var _begin: Number;
		/** milliseconds */
		private var _pos: Number;

		public function TextLine(factory: IKarFactory) {
			_factory = factory;
			_completed = new Signal(TextLine);
		}

		public function init(data: LineInfo): void {
			this._data = data;
			checkStyle();
			_len = data.lyricBlocks.length;
			_begin = data.begin;
			_dur = data.duration;
			
			_blocks = new Array();
			var blockInfo: BlockInfo;
			var block: IBlock;
			var lastX: Number = 0;
			
			for (var i: int = 0;i < _len;i++) {
				blockInfo = data.lyricBlocks[i];
				block = _factory.createTextBlock();
				block.setStyle(_normalStyle, _syncStyle);
				block.init(blockInfo);
				block.completed.add(textBlockCompleteHandler);
				_blocks.push(block);
				if(i > 0) {
					IBlock(_blocks[i - 1]).next = block;
				}
				//render
				block.x = lastX;
				addChild(DisplayObject(block));
				lastX += block.width;
			}
		}

		private function checkStyle(): void {
			_syncStyle = _data.songLyrics.syncLyricStyle;
			switch(_data.styleName) {
				case LyricStyle.MALE:
					_normalStyle = _data.songLyrics.maleLyricStyle;
					break;
				case LyricStyle.FEMALE:
					_normalStyle = _data.songLyrics.femaleLyricStyle;
					break;
				case LyricStyle.BASIC:
				default:
					_normalStyle = _data.songLyrics.basicLyricStyle;
			}
		}

		private function textBlockCompleteHandler(tb: IBlock): void {
			//			trace('text bit ' + tb.text + ' complete, next:  ' + (tb.next));
			if(tb.next) {
				//tb.next.play();
			} else {
				_playing = false;
				_complete = true;
				_completed.dispatch(this);
			}
		}

		public function reset(): void {
			for (var i: int = 0;i < _len;i++) {
				_blocks[i].reset();
			}
		}

		public function dispose(): void {
			for (var i: int = 0;i < _len;i++) {
				_blocks[i].dispose();
				removeChild(_blocks[i]);
			}
			_blocks = null;
			_playing = false;
			_complete = true;
		}

		public function get playing(): Boolean {
			return _playing;
		}

		public function get complete(): Boolean {
			return _complete;
		}

		override public function get width(): Number { 
			if (_blocks && _blocks.length) {
				var lastBlock: IBlock = _blocks[_blocks.length - 1];
				return (lastBlock.x + lastBlock.noSpaceWidth);
			} else {
				return super.width; 
			}
		}

		override public function set width(value: Number): void {
			//super.width = value;
			trace("this component has read-only width");
		}

		override public function toString(): String {
			var str: String = "Line {";
			for (var i: int = 0;i < _len;i++) {
				str += _blocks[i].text;
			}
			return str + "}";
		}

		public function get position(): Number {
			return _pos;
		}

		public function set position(value: Number): void {
			_pos = value;
			for (var i: int = 0;i < _len;i++) {
				_blocks[i].position = _pos;
			}
		}

		public function get begin(): Number {
			return _begin;
		}

		public function get duration(): Number {
			return _dur;
		}

		public function get end(): Number {
			return _begin + _dur;
		}

		/* complete event, param: TextLine */
		public function get completed(): ISignal {
			return _completed;
		}
	}
}