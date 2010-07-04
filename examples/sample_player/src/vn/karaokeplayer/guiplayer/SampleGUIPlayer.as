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
package vn.karaokeplayer.guiplayer {
	import vn.karaokeplayer.KarPlayer;
	import vn.karaokeplayer.data.KarPlayerOptions;
	import vn.karaokeplayer.data.LyricStyle;

	import com.gskinner.motion.GTweener;
	import com.realeyes.osmfplayer.controls.ControlBar;

	import org.osflash.signals.Signal;

	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	/**
	 * @author Thanh Tran
	 */
	public class SampleGUIPlayer extends Sprite {
		public static const WIDTH: uint = 600;
		public static const HEIGHT: uint = 400;
		
		
		
		public var karPlayer:KarPlayer;
		public var controlBar: ControlBar;
		public var titleText: TextField;
		
		private var _vol: Number;
		private var _mute: Boolean;
		private var _lastPos: Number = 0;
		
		public function SampleGUIPlayer() {
			addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}

		private function addToStageHandler(event: Event): void {
			removeEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
			createVersionContextMenu();
			initTitleText();
			initControlBar();
			initKarPlayer();
			addChild(karPlayer);
			addChild(controlBar);
			addChild(titleText);
		}
		
		private function createVersionContextMenu():void{
			var contextMenu: ContextMenu;
			if (parent.contextMenu) contextMenu = stage.contextMenu;
			else contextMenu = new ContextMenu();
			contextMenu.hideBuiltInItems();
			//version info
			var copyMenuItem: ContextMenuItem = new ContextMenuItem("AS3 Karaoke Player " + KarPlayer.VERSION,false);
			copyMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyRightMenuSelectHandler);
			contextMenu.customItems.push(copyMenuItem);
			
			parent.contextMenu = contextMenu;
		}

		private function copyRightMenuSelectHandler(event: ContextMenuEvent): void {
			navigateToURL(new URLRequest("http://code.google.com/p/as3-karaoke-player/"), "_blank");
		}

		private function initTitleText(): void {
			titleText = new TextField();
			titleText.autoSize = "left";
			titleText.multiline = true;
			titleText.embedFonts = true;
			titleText.selectable = false;
			var format: TextFormat = new TextFormat(FontLib.FONT_NAME, 30, 0xFF0000);
			titleText.defaultTextFormat = format;
			var strokeEffect: GlowFilter = new GlowFilter(0xFFFFFF, 1, 2, 2, 128, 2);
			titleText.filters = [strokeEffect];
		}

		private function initKarPlayer(): void {
			var karOptions: KarPlayerOptions = new KarPlayerOptions();
			karOptions.width = WIDTH;
			karOptions.height = HEIGHT - controlBar.height;
			karOptions.basicLyricStyle = LyricStyle.DEFAULT_BASIC_STYLE;
			karOptions.basicLyricStyle.font = "ArialRegularVN";
			karOptions.basicLyricStyle.embedFonts = true;
			
			karPlayer = new KarPlayer(karOptions);

			karPlayer.ready.add(playerReadyHandler);
			karPlayer.playProgress.add(playProgressHandler);
			karPlayer.loadProgress.add(loadProgressHandler);
			karPlayer.audioCompleted.add(audioCompleteHandler);
		}

		private function loadProgressHandler(percent: Number, bytesLoaded: uint, bytesTotal: uint ): void {
			controlBar.setLoadBarPercent(percent);
			controlBar.duration = int(karPlayer.length * 0.001);
		}

		private function audioCompleteHandler(): void {
			controlBar.playPause_mc.selected = true;
			controlBar.setCurrentBarPercent(0);
			GTweener.to(titleText, 0.5, {alpha: 1});
		}

		/**
		 * TODO: optimize performance
		 */
		private function initControlBar(): void {
			controlBar = new ControlBar();
			controlBar.width = WIDTH;
			controlBar.y = HEIGHT - controlBar.height;
			controlBar.played.add(controlBarUpdateHandler);
			controlBar.paused.add(controlBarUpdateHandler);
			controlBar.stopped.add(controlBarUpdateHandler);
			controlBar.muteToggled.add(controlBarUpdateHandler);
			controlBar.fullScreenToggled.add(controlBarUpdateHandler);
			controlBar.captionToggled.add(controlBarUpdateHandler);
			controlBar.playPause_mc.selected = true;
			controlBar.progress_mc.seeked.add(seekHandler);
			controlBar.volumeSlider_mc.volumeSet.add(volumeSetHandler);
			controlBar.volumeSlider_mc.volume = 0.5;
			volumeSetHandler(0.5);
			controlBar.closedCaption_mc.selected = true;
			
			controlBar.playPause_mc.enabled = false;
			controlBar.mouseChildren = false;
			//enabled hard ware render in FS:
			stage.fullScreenSourceRect = new Rectangle(this.x, this.y, WIDTH, HEIGHT);
		}

		private function volumeSetHandler(vol: Number): void {
			_vol = vol;
			updateVolume();
		}

		private function seekHandler(percent: Number): void {
			var pos: Number = percent * karPlayer.length;
			controlBar.setCurrentBarPercent(percent);
			karPlayer.seek(pos);
		}

		private function playProgressHandler(pos: Number, len: Number): void {
			//only update time text every second to reduce CPU hog
			
			if(Math.abs(pos - _lastPos) > 1000) {
				controlBar.currentTime = pos * 0.001;
				_lastPos = pos;		
			}
			
			//trace('pos/ len: ' + (pos/ len));
			controlBar.setCurrentBarPercent(pos / len);
		}

		private function controlBarUpdateHandler(event: Signal, toggleOn: Boolean = false): void {
			switch(event){
				case controlBar.played:
					karPlayer.play();
					GTweener.to(titleText, 0.5, {alpha: 0});
					break;
				case controlBar.paused:
					karPlayer.pause();
					break;
				case controlBar.fullScreenToggled:
					if(toggleOn) {
						stage.displayState = StageDisplayState.FULL_SCREEN;
					} else {
						stage.displayState = StageDisplayState.NORMAL;
					}
					break;
				case controlBar.muteToggled:
					_mute = toggleOn;
					updateVolume();
					break;
				case controlBar.captionToggled:
					karPlayer.visible = toggleOn;				
					break;
				default:
					break;
			}
			
		}
		
		private function updateVolume(): void {
			if(_mute) {
				SoundMixer.soundTransform = new SoundTransform(0);
			} else {
				SoundMixer.soundTransform = new SoundTransform(_vol);
			}
		}

		private function playerReadyHandler(): void {
			//controlBar.progress_mc.isLive = true;
			controlBar.playPause_mc.enabled = true;
			controlBar.mouseChildren = true;
			
			titleText.alpha = 0;
			setSongTitle(karPlayer.songInfo.title,karPlayer.songInfo.description);
			
			GTweener.to(titleText, 0.5, {alpha: 1});
		}

		public function load(songURL: String): void {
			titleText.text = "";
			karPlayer.loadSong(songURL);
		}
		
		private function setSongTitle(title: String, desc: String): void {
			var html: String = title + '<br/><font size="20" color="#0000CC">' + desc + "</font>";
			titleText.htmlText = html;
			titleText.x = 10;
			titleText.y = HEIGHT - titleText.height - 40;
		}
	}
}
