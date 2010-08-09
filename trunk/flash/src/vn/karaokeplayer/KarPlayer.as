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
	import flash.display.DisplayObject;
	import org.osflash.signals.ISignal;
	import vn.karaokeplayer.parsers.ILyricsParser;
	import vn.karaokeplayer.audio.IAudioPlayer;
	import vn.karaokeplayer.lyrics.ILyricsPlayer;
	import vn.karaokeplayer.lyrics.TextBlock;
	import vn.karaokeplayer.lyrics.TextLine;
	import vn.karaokeplayer.utils.KarFactory;
	import vn.karaokeplayer.utils.IKarFactory;
	import vn.karaokeplayer.audio.AudioPlayer;
	import vn.karaokeplayer.data.KarPlayerError;
	import vn.karaokeplayer.data.KarPlayerOptions;
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.data.SongLyrics;
	import vn.karaokeplayer.lyrics.LyricsPlayer;
	import vn.karaokeplayer.utils.AssetLoader;
	import vn.karaokeplayer.utils.EnterFrameManager;
	import vn.karaokeplayer.parsers.TimedTextParser;
	import vn.karaokeplayer.utils.Version;

	import com.gskinner.motion.GTweener;

	import org.osflash.signals.Signal;

	import flash.display.Sprite;
	import flash.utils.getTimer;

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
		public var playProgress: Signal;
		/**
		 * dispatch loading progress
		 * arguments (percent: Number, byteLoaded: uint, byteTotal: uint)
		 */
		public var loadProgress: Signal;
		/**
		 * dispatch when audio loading is completed
		 */
		public var loadCompleted: Signal;
		/**
		 * dispatch when audio completes playing
		 */
		public var audioCompleted: Signal;
		
		private var _factory: IKarFactory;
		private var _tickingManager: EnterFrameManager = EnterFrameManager.instance;
		private var _parser: ILyricsParser;
		private var _songReady: Boolean;
		
		private var _lyricPlayer: ILyricsPlayer;
		private var _beatPlayer: IAudioPlayer;
		
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
			
			createFactory();
			init();
		}

		/**
		 * Temporarily create all class references here.
		 */
		private function createFactory(): void {
			_factory = new KarFactory(TimedTextParser, LyricsPlayer, TextLine, TextBlock, AudioPlayer);
		}

		karplayer_internal function prepareDebug(): void {
			
		}
		
		private function init(): void {
			var lyricScreenW: Number = _options.width - (_options.paddingLeft + _options.paddingRight);
			var lyricScreenH: Number = _options.height - (_options.paddingTop + _options.paddingBottom);
			_lyricPlayer = _factory.createLyricsPlayer(lyricScreenW, lyricScreenH);
			_lyricPlayer.x = _options.paddingLeft;
			_lyricPlayer.y = _options.paddingRight;
			_lyricPlayer.alpha = 0;
			_beatPlayer = _factory.createAudioPlayer();
			_beatPlayer.ready.add(audioReadyHandler);
			_beatPlayer.loadProgress.add(audioLoadingProgressHandler);
			loadCompleted = Signal(_beatPlayer.loadCompleted);
			addChild(DisplayObject(_lyricPlayer));
			
			ready = new Signal();
			playProgress = new Signal(Number, Number);
			loadProgress = new Signal(Number, Number, Number);
			audioCompleted = Signal(_beatPlayer.audioCompleted);
			audioCompleted.add(stop);
		}

		/**
		 * load song data from URL or object SongInfo<br/>
		 * Note: currently assuming that beat audio is loaded with SongInfo 
		 * @param urlOrSongInfo	url of song lyrics XML or SongInfo 
		 */
		public function loadSong(urlOrSongInfo: Object): void {
			if(playing) {
				// hide lyric player to avoid flickering:
				_lyricPlayer.alpha = 0;
				_lyricPlayer.cleanUp();
				audioCompleted.dispatch(); //dispatching this event also call the stop function 
			}
			if(urlOrSongInfo is SongInfo) {
				//TODO: load beatsound if beatsound is not loaded at this flow
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
			trace("KarPlayer - xml Loaded: " + xmlLoader.url);
			_parser = _factory.createLyricsParser();
			var xml: XML = new XML(xmlLoader.data);
			acceptSongInfo(_parser.parseXML(xml));
			xmlLoader.dispose();
			//trace('_songInfo.beatURL: ' + (_songInfo.beatURL));
			//trace('_songInfo.title: ' + (_songInfo.title));
			//continue to load audio:
			//var audioLoader: AssetLoader = new AssetLoader();
			//audioLoader.progress.add(audioLoadingProgressHandler);
			//audioLoader.completed.add(audioLoadHandler);
			//audioLoader.load(_songInfo.beatURL);
			beatPlayer.open(_songInfo.beatURL);
		}

		private function audioLoadingProgressHandler(bytesLoaded: uint, bytesTotal: uint): void {
			loadProgress.dispatch(bytesLoaded / bytesTotal, bytesLoaded, bytesTotal);	
		}
		
		private function audioReadyHandler(): void {
			//we don't need to init beat player if we open the sound with URL 
			//_songInfo.beatSound = beatPlayer;
			//_beatPlayer.init(_songInfo.beatSound);
			_lyricPlayer.init(_songInfo.lyrics);
			_songReady = true;
			trace("KarPlayer - audio ready: " + _songInfo.beatURL);
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
		
		/**
		 * pause 
		 */
		public function pause(): void {
			_tickingManager.enterFrame.remove(enterFrameHandler);
			_position = _beatPlayer.position;	
			_beatPlayer.pause();
		}

		/**
		 * Plays the audio and lyric without recording
		 */
		public function play(): void {
			GTweener.removeTweens(_lyricPlayer);
			GTweener.to(_lyricPlayer, 1, {alpha:1});
			_beatPlayer.play(_position);
			_startTime = getTimer() - _position;
			_tickingManager.enterFrame.add(enterFrameHandler);
		}
		
		/**
		 * Seeks to a position (in milliseconds)
		 */
		public function seek(pos: Number): void {
			if(_beatPlayer.seek(pos)) {
				_position = pos;
				_startTime = getTimer() - _position;
				_lyricPlayer.position = pos;	
			}
		}
		
		/**
		 * Stops the player
		 */
		public function stop(): void {
			_tickingManager.enterFrame.remove(enterFrameHandler);
			GTweener.to(_lyricPlayer, 0.2, {alpha:0} /*, {onComplete: lyricFadeCompleteHandler}*/);
			_position = 0;
			_beatPlayer.stop();
		}
		/*
		private function lyricFadeCompleteHandler(tween: GTween): void {
//			_lyricPlayer.position = 0;
		}
		 */

		private function enterFrameHandler(): void {
			//getTimer() is more precise than get position of audio  
			var elapsedTime: uint = _beatPlayer.position; /*getTimer() - _startTime - 50;*/
			_lyricPlayer.position = elapsedTime;
			
			playProgress.dispatch(_beatPlayer.position, _beatPlayer.length);
			//_lyricPlayer.position = _beatPlayer.position + 50;
			 
			//var diff: Number = (elapsedTime - _beatPlayer.position);
//			_diffArray.push(diff);
//			var sum: Number = 0;
//			for (var i : int = 0; i < _diffArray.length; i++) {
//				sum += _diffArray[i];
//			}
//			var avg: Number = sum / _diffArray.length;
			//trace('timer: ' + (elapsedTime) + ' .pos: ' + (_beatPlayer.position) + " diff: " + diff);
		}

		karplayer_internal function debug(): void {
			
		}
		
		public function get songReady(): Boolean {
			return _songReady;
		}
		
		public function get songInfo(): SongInfo {
			return _songInfo;
		}
		
		/**
		 * Width of this player. This can be used for positioning and layout.
		 * This property is overriden so it only measures the logical visible part of the player.
		 * It is read-only. 
		 */
		override public function get width(): Number {
			return _options.width;
		}

		override public function set width(value: Number): void {
			throw new KarPlayerError(KarPlayerError.ILLEGAL_OPERATION,"width is read only");
		}

		/**
		 * Height of this player. This can be used for positioning and layout.
		 * This property is overriden so it only measures the logical visible part of the player.
		 * It is read-only. 
		 */
		override public function get height(): Number {
			return _options.height;
		}
		
		override public function set height(value: Number): void {
			throw new KarPlayerError(KarPlayerError.ILLEGAL_OPERATION,"height is read only");
		}
		
		public function get beatPlayer(): IAudioPlayer {
			return _beatPlayer;
		}
		
		public function get lyricPlayer(): ILyricsPlayer {
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
