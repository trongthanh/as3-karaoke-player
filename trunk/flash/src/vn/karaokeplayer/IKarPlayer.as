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
package vn.karaokeplayer {
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.lyrics.ILyricsPlayer;
	import vn.karaokeplayer.audio.IAudioPlayer;
	import org.osflash.signals.ISignal;

	/**
	 * Interface for KarPlayer
	 * @author Thanh Tran
	 */
	public interface IKarPlayer {
		
		/**
		 * Loads song data from URL or object SongInfo<br/>
		 * Note: currently assuming that beat audio is loaded with SongInfo 
		 * @param urlOrSongInfo	url of song lyrics XML or SongInfo 
		 */
		function loadSong(urlOrSongInfo: Object): void;

		/**
		 * Pauses the karaoke 
		 */
		function pause(): void;

		/**
		 * Plays the karaoke
		 */
		function play(startTime: Number = NaN): void;
		
		/**
		 * Seeks to a position (in milliseconds)
		 */
		function seek(pos: Number): void;
		
		/**
		 * Stops the player
		 */
		function stop(): void;
		
		/**
		 * Whether song is ready to play
		 */
		function get songReady(): Boolean;
		
		/**
		 * SongInfo object which is parsed from the lyrics XML
		 */
		function get songInfo(): SongInfo;
		
		/**
		 * Width of this player. This can be used for positioning and layout.
		 * This property is overriden so it only measures the logical visible part of the player.
		 * It is read-only. 
		 */
		function get width(): Number;

		/**
		 * Height of this player. This can be used for positioning and layout.
		 * This property is overriden so it only measures the logical visible part of the player.
		 * It is read-only. 
		 */
		function get height(): Number;
		
		function get x(): Number;
		function set x(value: Number): void;
		function get y(): Number;
		function set y(value: Number): void;
		
		function get beatPlayer(): IAudioPlayer;
		function get lyricPlayer(): ILyricsPlayer;
		
		/**
		 * Current position of play head (in milliseconds)
		 */
		function get position(): Number;
		
		/**
		 * Audio length (in milliseconds)
		 */
		function get length(): Number;
		
		/**
		 * Is player playing
		 */
		function get playing(): Boolean;
		
		/**
		 * Is player pausing
		 */
		function get pausing(): Boolean;
		
		/**
		 * Dispatches when data and sound are ready
		 */
		function get ready(): ISignal;
		
		/**
		 * Dispatches playing progress<br/>
		 * arguments (position: Number, length: Number)  
		 */
		function get playProgress(): ISignal;
		
		/**
		 * Dispatches loading progress<br/>
		 * arguments (percent: Number, byteLoaded: uint, byteTotal: uint)
		 */
		function get loadProgress(): ISignal;
		
		/**
		 * Dispatches when audio (mp3) loading is completed
		 */
		function get loadCompleted(): ISignal;
		
		/**
		 * Dispatches when audio completes playing
		 */
		function get audioCompleted(): ISignal;
	}
}
