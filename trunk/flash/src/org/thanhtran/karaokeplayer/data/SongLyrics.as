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
package org.thanhtran.karaokeplayer.data {

	/**
	 * @author Thanh Tran
	 */
	public class SongLyrics {
		public var width: Number = 800;
		public var height: Number = 200;
		public var numLines: uint = 2;
		public var lyricLines: Array = new Array();
		
		public var basicLyricStyle: LyricStyle;
		public var maleLyricStyle: LyricStyle;
		public var femaleLyricStyle: LyricStyle;
		public var syncLyricStyle: LyricStyle;
		
		public function SongLyrics () {
			//create default styles
			basicLyricStyle = LyricStyle.DEFAULT_BASIC_STYLE;
			maleLyricStyle = LyricStyle.DEFAULT_MALE_STYLE;
			femaleLyricStyle = LyricStyle.DEFAULT_FEMALE_STYLE;
			syncLyricStyle = LyricStyle.DEFAULT_SYNC_STYLE;
		}
		
		public function addLine(line: LineInfo): void {
			line.songLyrics = this;
			lyricLines.push(line);
		}
	}
}
