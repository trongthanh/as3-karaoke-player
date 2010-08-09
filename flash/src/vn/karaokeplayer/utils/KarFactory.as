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
package vn.karaokeplayer.utils {
	import vn.karaokeplayer.audio.IAudioPlayer;
	import vn.karaokeplayer.lyrics.IBlock;
	import vn.karaokeplayer.lyrics.ILine;
	import vn.karaokeplayer.lyrics.ILyricsPlayer;
	import vn.karaokeplayer.parsers.ILyricsParser;

	/**
	 * @author Thanh Tran
	 */
	public class KarFactory implements IKarFactory {
		private var lyricParserClass: Class;		private var lyricPlayerClass: Class;		private var textLineClass: Class;		private var textBlockClass: Class;
		private var audioPlayerClass: Class;
		
		
		public function KarFactory( lyricParserClass: Class,
									lyricPlayerClass: Class,
									textLineClass: Class,
									textBlockClass: Class,
									audioPlayerClass: Class	) 
		{
			this.lyricParserClass = lyricParserClass;
			this.lyricPlayerClass = lyricPlayerClass;
			this.textLineClass = textLineClass;
			this.textBlockClass = textBlockClass;
			this.audioPlayerClass = audioPlayerClass;
		}

		public function createLyricsParser(): ILyricsParser {
			return new lyricParserClass();
		}
		
		public function createLyricsPlayer(w: Number, h: Number, align: String = "bottom"): ILyricsPlayer {
			return new lyricPlayerClass(this, w, h, align);
		}

		public function createTextLine(): ILine {
			return new textLineClass(this);
		}

		public function createTextBlock(): IBlock {
			return new textBlockClass;
		}

		public function createAudioPlayer(): IAudioPlayer {
			return new audioPlayerClass();
		}
	}
}
