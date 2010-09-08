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
	import vn.karaokeplayer.data.ISongLyrics;
	import vn.karaokeplayer.data.LineInfo;
	import vn.karaokeplayer.data.SongLyrics;
	import vn.karaokeplayer.utils.IKarFactory;
	import vn.karaokeplayer.utils.KarPlayerVersion;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	public class LyricsPlayer extends Sprite implements ILyricsPlayer {
		public static const VERSION: String = KarPlayerVersion.VERSION;
		
		private var _factory: IKarFactory;
		private var data: SongLyrics;
		private var _lyricsCompleted: Signal;
		
		private var _w: Number; //screen width
		private var _h: Number; // screen height
		private var _align: String;		
		private var _lines: Array;
		private var _len: int;
		private var _pos: Number;
		private var _l1: ILine;
		//private var _idx1: int;
		private var _l2: ILine;
		//private var _idx2: int;
		
		public function LyricsPlayer(factory: IKarFactory, w: Number, h: Number, align: String = "bottom") {
			_factory = factory;
			_w = w;
			_h = h;				
			_align = align;
			_lyricsCompleted = new Signal(SongLyrics);
			
			//comment me 
//			debug();
		}

		public function debug(): void {
			graphics.lineStyle(1, 0x00FF00, 0.8);
			graphics.drawRect(0, 0, _w, _h);				
		}

		/**
		 * TODO: optimization: create exactly number of lines 
		 * @param	lyrics
		 */
		public function init(lyrics: ISongLyrics): void {
			data = SongLyrics(lyrics);	
			_lines = new Array();
			_len = data.lyricLines.length;
			var textLine: ILine;
			var lineInfo: LineInfo;
			for (var i : int = 0; i < _len; i++) {
				lineInfo = data.lyricLines[i];
				textLine = _factory.createTextLine();
				textLine.init(lineInfo);
				//textLine.completed.add(lineCompleteHandler);
				//textLine.index = i;
				//position all lines
				if(i % 2 == 0) {
					textLine.y = _h - (textLine.height * 2);
					//align left
				} else {
					textLine.y = _h - (textLine.height);
					//align right
					textLine.x = _w - textLine.width; 
				}
				
				_lines.push(textLine);
			}
			
			//_pos = 0;
			//_idx1 = 0;
			//_l1 = _lines[_idx1];
			//_idx2 = 1;
			//_l2 = _lines[_idx2];
			//addChild(_l1);
			//addChild(_l2);
			position = 0;
		}
		
		/*
		private function lineCompleteHandler(textLine: TextLine): void {
			if(_pos == 0) return;
			var nextLine: TextLine;
			if(textLine == _l1) {
				_idx1 += 2;
				if(_idx1 < _lines.length) {
					_l1 = _lines[_idx1];
					addChild(_l1);
					_l1.alpha = 0;
					nextLine = _l1;							
				}
				
			} else {
				_idx2 += 2;
				if(_idx2 < _lines.length) {
					_l2 = _lines[_idx2];
					addChild(_l2);
					_l2.alpha = 0;
					nextLine = _l2;
				} 
			}
			//only fade current line if there's next line to show
			//TODO: implement a simple animator, to completely remove 3rd party tweener
			if (nextLine) GTweener.to(textLine, 0.1, { alpha:0 }, { data: { last: textLine, next: nextLine }, onComplete: lineFadeOutCompleteHandler } );
			
			if (_lines.indexOf(textLine) == _len -1) {
				//all lines have been played:
				lyricsCompleted.dispatch(data);
			}
		}
		 */
		/*
		public function lineFadeOutCompleteHandler(tween: GTween): void {
			var lastLine: ILine = ILine(tween.data.last);
			var nextLine: ILine = ILine(tween.data.next);
			
			//remove line
			removeIfContains(lastLine);
			//fade in next line
			GTweener.to(nextLine, 0.1, {alpha:1});
			
		}
		*/
		
		public function get position(): Number {
			return _pos;
		}
		
		/**
		 * TODO: add entrance and exit fading effect for text line (part of its timeline)
		 */
		public function set position(position: Number): void {
			_pos = position;
			var i: int;
			var line: TextLine;
			//determine current lines:
			if(_l1 && _l1.begin < _pos && _l1.end > _pos) {
				_l1.position = _pos;	
			} else {
				/*if(_l1 && _l1.end < _pos && contains(_l1)) {
					trace("remove _l1");
					removeChild(_l1);
				}*/
				//search for first line:
				for(i=0; i < _len; i += 2) {
					line = _lines[i];
					if(line.end > _pos) {
						break;
					}
				}
				if(_l1 != line) {
					removeIfContains(_l1);
					_l1 = line;
					add(_l1);
				}
				_l1.position = _pos;
			}
			
			if(_l2 && _l2.begin < _pos && _l2.end > _pos) {
				_l2.position = _pos;	
			} else {
				/*
				if(_l2 && _l2.end < _pos && contains(_l2)) {
					trace("remove _l2");
					removeChild(_l2);
				}*/
				//search for second line:
				for(i=1; i < _len; i += 2) {
					line = _lines[i];
					if(line.end > _pos) {
						break;
					}
				}
				if(_l2 != line) {
					removeIfContains(_l2);
					_l2 = line;
					add(_l2);
				}
				_l2.position = _pos;
				
			}

		}
		
		/**
		 * Test release memory
		 */
		public function cleanUp(): void {
			trace("lyric player clean up");
			for (var i : int = 0; i < _len; i++) {
				_lines[i].dispose();
			}
			//if (contains(_l1)) removeChild(_l1);
			removeIfContains(_l1);
			//if (contains(_l2)) removeChild(_l2);
			removeIfContains(_l2);
			_lines = null;
		}
		
		private function removeIfContains(line: ILine): void {
			var l: DisplayObject = line as DisplayObject;
			if(l && contains(l)) {
				removeChild(l);
			}			
		}
		
		private function add(line: ILine): void {
			addChild(DisplayObject(line));
		}
		
		public function get lyricsCompleted(): ISignal {
			return _lyricsCompleted;
		}
	}
}
