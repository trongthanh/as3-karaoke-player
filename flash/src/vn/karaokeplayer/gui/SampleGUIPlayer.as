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
package vn.karaokeplayer.gui {
	import flash.display.StageDisplayState;
	import vn.karaokeplayer.data.LyricStyle;
	import flash.text.Font;
	import org.osflash.signals.Signal;
	import com.realeyes.osmfplayer.controls.ControlBar;
	import vn.karaokeplayer.data.KarPlayerOptions;
	import vn.karaokeplayer.KarPlayer;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	public class SampleGUIPlayer extends Sprite {
		public static const WIDTH: uint = 600;
		public static const HEIGHT: uint = 400;
		
		[Embed(systemFont='Arial'
		,fontFamily  = 'ArialRegularVN'
		,fontName  ='ArialRegularVN'
		,fontStyle   ='normal' // normal|italic
		,fontWeight  ='normal' // normal|bold
		,unicodeRange = 'U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E,U+00C0-U+00C3,U+00C8-U+00CA,U+00CC-U+00CD,U+00D0,U+00D2-U+00D5,U+00D9-U+00DA,U+00DD,U+00E0-U+00E3,U+00E8-U+00EA,U+00EC-U+00ED,U+00F2-U+00F5,U+00F9-U+00FA,U+00FD,U+0102-U+0103,U+0110-U+0111,U+0128-U+0129,U+0168-U+0169,U+01A0-U+01B0,U+1EA0-U+1EF9,U+02C6-U+0323',
		mimeType='application/x-font'
		//,embedAsCFF='false'
		)]
		public static const fontClass:Class;
		
		public var karPlayer:KarPlayer;
		public var controlBar: ControlBar;
		
		public function SampleGUIPlayer() {
			Font.registerFont(fontClass);
			initControlBar();
			
			initKarPlayer();
		}

		private function initKarPlayer(): void {
			var karOptions: KarPlayerOptions = new KarPlayerOptions();
			karOptions.width = WIDTH;
			karOptions.height = HEIGHT - controlBar.height;
			karOptions.basicLyricStyle = LyricStyle.DEFAULT_BASIC_STYLE;
			karOptions.basicLyricStyle.font = "ArialRegularVN";
			karOptions.basicLyricStyle.embedFonts = true;
			
			karPlayer = new KarPlayer(karOptions);
			addChild(karPlayer);
			
			karPlayer.ready.add(playerReadyHandler);
			karPlayer.progress.add(playProgressHandler);
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
			controlBar.muted.add(controlBarUpdateHandler);
			controlBar.fullScreen.add(controlBarUpdateHandler);
			controlBar.playPause_mc.selected = true;
			controlBar.progress_mc.seeked.add(seekHandler);
			addChild(controlBar);
		}

		private function seekHandler(percent: Number): void {
			var pos: Number = percent * karPlayer.length;
			karPlayer.seek(pos);
		}

		private function playProgressHandler(pos: Number, len: Number): void {
			controlBar.currentTime = int(pos / 1000);
			//trace('pos/ len: ' + (pos/ len));
			controlBar.setCurrentBarPercent(pos / len);
		}

		private function controlBarUpdateHandler(event: Signal, toggleOn: Boolean = false): void {
			switch(event){
				case controlBar.played:
					karPlayer.play();
					break;
				case controlBar.paused:
					karPlayer.pause();
					break;
				case controlBar.fullScreen:
					if(toggleOn) {
						stage.displayState = StageDisplayState.FULL_SCREEN;
					} else {
						stage.displayState = StageDisplayState.NORMAL;
					}
				
				default:
			}
			
		}

		private function playerReadyHandler(): void {
			//controlBar.progress_mc.isLive = true;
			controlBar.setLoadBarPercent(1);
			controlBar.duration = int(karPlayer.length / 1000);
		}

		public function load(songURL: String): void {
			karPlayer.loadSong(songURL);
		}
	}
}
