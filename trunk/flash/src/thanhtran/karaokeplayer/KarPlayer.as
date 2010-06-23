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
package thanhtran.karaokeplayer {
	import com.gskinner.motion.GTween;
	import flash.utils.getTimer;
	import com.gskinner.motion.GTweener;
	import thanhtran.karaokeplayer.data.SongLyrics;
	import flash.media.Sound;
	import thanhtran.karaokeplayer.utils.TimedTextParser;
	import org.osflash.signals.Signal;
	import thanhtran.karaokeplayer.data.SongInfo;
	import thanhtran.karaokeplayer.utils.AssetLoader;
	import thanhtran.karaokeplayer.data.KarPlayerOptions;
	import thanhtran.karaokeplayer.audio.BeatPlayer;
	import thanhtran.karaokeplayer.lyrics.LyricsPlayer;
	import thanhtran.karaokeplayer.utils.EnterFrameManager;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	public class KarPlayer extends Sprite {
		public static const VERSION: String = Version.VERSION;
		
		/**
		 * dispatch when data and sound are ready
		 */
		public var ready: Signal;
		/**
		 * dispatch playing progress
		 * arguments (position: Number, length: Number)  
		 */
		public var progress: Signal;
		/**
		 * dispatch loading progress
		 * arguments (percent: Number, byteLoaded: uint, byteTotal: uint)
		 */
		public var loading: Signal;
		
		public var audioCompleted: Signal;
		
		private var _tickingManager: EnterFrameManager = EnterFrameManager.instance;
		private var _parser: TimedTextParser;
		private var _songReady: Boolean;
		
		private var _lyricPlayer: LyricsPlayer;
		private var _beatPlayer: BeatPlayer;
		
		private var _options: KarPlayerOptions;
		private var _songInfo: SongInfo;
		
		///testing
		private var _startTime: uint;
		private var _position: Number = 0;
		//private var _diffArray: Array = [];

		public function KarPlayer (options: KarPlayerOptions = null) {
			trace("[AS3 Karaoke Player " + VERSION + "]");
			if(!options) options = new KarPlayerOptions();
			_options = options;
			init();	
		}
		
		private function init(): void {
			var lyricScreenW: Number = _options.width - (_options.paddingLeft + _options.paddingRight);
			var lyricScreenH: Number = _options.height - (_options.paddingTop + _options.paddingBottom);
			_lyricPlayer = new LyricsPlayer(lyricScreenW, lyricScreenH);
			_lyricPlayer.x = _options.paddingLeft;
			_lyricPlayer.y = _options.paddingRight;
			_lyricPlayer.alpha = 0;
			_beatPlayer = new BeatPlayer();
			addChild(_lyricPlayer);
			
			ready = new Signal();
			progress = new Signal(Number, Number);
			loading = new Signal(Number, Number, Number);
			audioCompleted = _beatPlayer.audioCompleted;
			audioCompleted.add(stop);
		}

		public function loadSong(urlOrSongInfo: Object): void {
			if(urlOrSongInfo is SongInfo) {
				acceptSongInfo(urlOrSongInfo as SongInfo);
				_lyricPlayer.init(_songInfo.lyrics);
				_beatPlayer.init(_songInfo.beatSound);
				_songReady = true;
				ready.dispatch();
			} else {
				var xmlLoader: AssetLoader = new AssetLoader();
				xmlLoader.completed.add(xmlLoadHandler);
				xmlLoader.load(String(urlOrSongInfo));		
			}
			
		}

		private function xmlLoadHandler(xmlLoader: AssetLoader): void {
			trace("xml Loaded: " + xmlLoader.url);
			_parser = new TimedTextParser();
			var xml: XML = new XML(xmlLoader.data);
			acceptSongInfo(_parser.parseXML(xml));
			xmlLoader.dispose();
			//trace('_songInfo.beatURL: ' + (_songInfo.beatURL));
			//trace('_songInfo.title: ' + (_songInfo.title));
			//continue to load audio:
			var audioLoader: AssetLoader = new AssetLoader();
			audioLoader.progress.add(audioLoadingProgressHandler);
			audioLoader.completed.add(audioLoadHandler);
			audioLoader.load(_songInfo.beatURL);
		}

		private function audioLoadingProgressHandler(audioLoader: AssetLoader, percent: Number, bytesLoaded: uint, bytesTotal: uint): void {
			loading.dispatch(percent, bytesLoaded, bytesTotal);	
		}

		private function audioLoadHandler(audioLoader: AssetLoader): void {
			trace("audio loaded: " + audioLoader.url);
			_songInfo.beatSound = Sound(audioLoader.data);
			_lyricPlayer.init(_songInfo.lyrics);
			_beatPlayer.init(_songInfo.beatSound);
			_songReady = true;
			ready.dispatch();
		}
		
		private function acceptSongInfo(song: SongInfo): void {
			//set default styles of this player 
			var songLyrics: SongLyrics = song.lyrics;
			if(_options.basicLyricStyle) songLyrics.basicLyricStyle = _options.basicLyricStyle;
			if(_options.maleLyricStyle) songLyrics.maleLyricStyle = _options.maleLyricStyle;
			if(_options.femaleLyricStyle) songLyrics.femaleLyricStyle = _options.femaleLyricStyle;
			if(_options.syncLyricStyle) songLyrics.syncLyricStyle = _options.syncLyricStyle;
			//copy all basic styles to other styles:
			songLyrics.maleLyricStyle.copyBasicStyles(songLyrics.basicLyricStyle);
			songLyrics.femaleLyricStyle.copyBasicStyles(songLyrics.basicLyricStyle);
			songLyrics.syncLyricStyle.copyBasicStyles(songLyrics.basicLyricStyle);
			
			_songInfo = song;
		}
		
		public function pause(): void {
			_tickingManager.enterFrame.remove(enterFrameHandler);
			_position = _beatPlayer.position;	
			_beatPlayer.pause();
		}

		/**
		 * Play the audio and lyric without recording
		 */
		public function play(): void {
			GTweener.to(_lyricPlayer, 1, {alpha:1});
			_beatPlayer.play(_position);
			_startTime = getTimer() - _position;
			_tickingManager.enterFrame.add(enterFrameHandler);
		}
		
		public function stop(): void {
			_tickingManager.enterFrame.remove(enterFrameHandler);
			GTweener.to(_lyricPlayer, 0.2, {alpha:0}, {onComplete: lyricFadeCompleteHandler});
			_position = 0;
			_beatPlayer.stop();
		}
		
		private function lyricFadeCompleteHandler(tween: GTween): void {
			_lyricPlayer.position = 0;
		}

		private function enterFrameHandler(): void {
			//getTimer() is more precise than get position of audio  
			var elapsedTime: uint = getTimer() - _startTime;
			_lyricPlayer.position = elapsedTime;
			
			progress.dispatch(_beatPlayer.position, _beatPlayer.length);
			//_lyricPlayer.position = _beatPlayer.position + 50;
			 
			//var diff: Number = (elapsedTime - _beatPlayer.position) - 50;
//			_diffArray.push(diff);
//			var sum: Number = 0;
//			for (var i : int = 0; i < _diffArray.length; i++) {
//				sum += _diffArray[i];
//			}
//			var avg: Number = sum / _diffArray.length;
			//trace('timer: ' + (elapsedTime) + ' .pos: ' + (_beatPlayer.position) + " diff: " + diff);
		}

		/**
		 * Play beat audio, lyrics and record at the same time 
		 */
		public function record(): void {
		}
		
		public function get songReady(): Boolean {
			return _songReady;
		}
		
		public function get songInfo(): SongInfo {
			return _songInfo;
		}

		override public function get width(): Number {
			return _options.width;
		}

		override public function get height(): Number {
			return _options.height;
		}
		
		public function get beatPlayer(): BeatPlayer {
			return _beatPlayer;
		}
		
		public function get lyricPlayer(): LyricsPlayer {
			return _lyricPlayer;
		}
		
		public function get position(): Number {
			return _beatPlayer.position;
		}
		
		public function get length(): Number {
			return _beatPlayer.length;
		}
		
		public function get playing(): Boolean { return _beatPlayer.playing; }
		public function get pausing(): Boolean { return _beatPlayer.pausing; }
	}
}
