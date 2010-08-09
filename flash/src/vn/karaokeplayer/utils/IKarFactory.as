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
	import vn.karaokeplayer.lyrics.ILine;
	import vn.karaokeplayer.lyrics.IBlock;
	import vn.karaokeplayer.lyrics.ILyricsPlayer;
	import vn.karaokeplayer.parsers.ILyricsParser;

	/**
	 * A factory to encapsulate and separate objects creation
	 * @author Thanh Tran
	 */
	public interface IKarFactory {
		
		function createLyricsParser(): ILyricsParser;
		function createLyricsPlayer(w: Number, h: Number, align: String = "bottom"): ILyricsPlayer;
		function createTextLine(): ILine;
		function createTextBlock(): IBlock;
		function createAudioPlayer(): IAudioPlayer; 
		
	}
}
