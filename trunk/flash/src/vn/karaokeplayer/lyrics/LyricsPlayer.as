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
	import vn.karaokeplayer.Version;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import org.osflash.signals.Signal;
	import vn.karaokeplayer.data.LineInfo;
	import vn.karaokeplayer.data.SongLyrics;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	public class LyricsPlayer extends Sprite {
		public static const VERSION: String = Version.VERSION;
		
		public var data: SongLyrics;
		public var lyricsCompleted: Signal;
		
		private var _w: Number; //screen width
		private var _h: Number; // screen height
		private var _align: String;		
		private var _lines: Array;
		private var _len: int;
		private var _pos: Number;
		private var _l1: TextLine;
		private var _idx1: int;
		private var _l2: TextLine;
		private var _idx2: int;
		
		public function LyricsPlayer(w: Number, h: Number, align: String = "bottom") {
			_w = w;
			_h = h;				
			_align = align;
			lyricsCompleted = new Signal(SongLyrics);
			
			//comment me 
//			debug();
		}

		private function debug(): void {
			graphics.lineStyle(1, 0x00FF00, 0.8);
			graphics.drawRect(0, 0, _w, _h);				
		}

		/**
		 * TODO: create exactly number of line 
		 * @param	lyrics
		 */
		public function init(lyrics: SongLyrics): void {
			data = lyrics;	
			_lines = new Array();
			_len = data.lyricLines.length;
			var textLine: TextLine;
			var lineInfo: LineInfo;
			for (var i : int = 0; i < _len; i++) {
				lineInfo = data.lyricLines[i];
				textLine = new TextLine();
				textLine.init(lineInfo);
				textLine.completed.add(lineCompleteHandler);
				textLine.index = i;
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
			
			_pos = 0;
			_idx1 = 0;
			_l1 = _lines[_idx1];
			_idx2 = 1;
			_l2 = _lines[_idx2];
			addChild(_l1);
			addChild(_l2);	
		}

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
			if (nextLine) GTweener.to(textLine, 0.1, { alpha:0 }, { data: { last: textLine, next: nextLine }, onComplete: lineFadeOutCompleteHandler } );
			
			if (_lines.indexOf(textLine) == _len -1) {
				//all lines have been played:
				lyricsCompleted.dispatch(data);
			}
		}
		
		public function lineFadeOutCompleteHandler(tween: GTween): void {
			var lastLine: TextLine = TextLine(tween.data.last);
			var nextLine: TextLine = TextLine(tween.data.next);
			
			//remove line
			if(contains(lastLine)) {
				removeChild(lastLine);
			}
			//fade in next line
			GTweener.to(nextLine, 0.1, {alpha:1});
			
		}

		public function get position(): Number {
			return _pos;
		}
		
		/**
		 * TODO: enble seeking, user can seek to any position
		 */
		public function set position(position: Number): void {
			_pos = position;
			if(_pos == 0) {
				trace("reset position");
				if(contains(_l1)) removeChild(_l1); 				if(contains(_l2)) removeChild(_l2);
				for (var i : int = 0; i < _len; i++) {
					_lines[i].reset();
				}
				_idx1 = 0;
				_l1 = _lines[_idx1];
				_idx2 = 1;
				_l2 = _lines[_idx2];
				_l1.alpha = 1;
				_l2.alpha = 1;
				addChild(_l1);
				addChild(_l2);
				return;
			}
			
			
			if(_pos > _l1.startTime && !_l1.playing && !_l1.complete) {
				_l1.play();
			}
			if(_pos > _l2.startTime && !_l2.playing && !_l2.complete) {
				_l2.play();
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
			if (contains(_l1)) removeChild(_l1);
			if (contains(_l2)) removeChild(_l2);
			_lines = null;
		}
	}
}
