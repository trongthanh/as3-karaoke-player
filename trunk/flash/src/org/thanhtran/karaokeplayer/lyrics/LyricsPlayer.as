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
package org.thanhtran.karaokeplayer.lyrics {
	import org.thanhtran.karaokeplayer.data.LineInfo;
	import org.thanhtran.karaokeplayer.data.SongLyrics;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	public class LyricsPlayer extends Sprite {
		public var data: SongLyrics;
		
		private var _w: Number; //screen width
		private var _h: Number; // screen height
		private var _lines: Array;
		private var _len: int;
		private var _pos: Number;
		private var _l1: TextLine;
		private var _idx1: int;
		private var _l2: TextLine;
		private var _idx2: int;
		
		public function LyricsPlayer(w: Number, h: Number) {
			_w = w;
			_h = h;
		}
		
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
					//align left
				} else {
					//align right
					textLine.y = textLine.height + 5;
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
			//remove line
			if(contains(textLine)) {
				removeChild(textLine);
			}
			
			if(textLine == _l1) {
				_idx1 += 2;
				if(_idx1 < _lines.length - 1) {
					_l1 = _lines[_idx1];
					addChild(_l1);					
				}
				
			} else {
				_idx2 += 2;
				if(_idx2 < _lines.length - 1) {
					_l2 = _lines[_idx2];
					addChild(_l2);					
				}
			}
		}

		public function get position(): Number {
			return _pos;
		}
		
		public function set position(position: Number): void {
			_pos = position;
			if(_pos > _l1.startTime && !_l1.playing) {
				_l1.play();
			}
			if(_pos > _l2.startTime && !_l2.playing) {
				_l2.play();
			}	
		}
	}
}
