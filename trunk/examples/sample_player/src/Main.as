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
package {
	import com.bit101.components.ComboBox;
	import com.bit101.components.Style;
	import flash.events.Event;
	import net.hires.debug.Stats;
	import vn.karaokeplayer.guiplayer.FontLib;
	import vn.karaokeplayer.guiplayer.SampleGUIPlayer;

	import flash.display.Bitmap;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	public class Main extends Sprite {
		public var stats: Stats;
		[Embed(source = '/../assets/images/bg-sapa-vietnam.jpg')]
		public var BGClass: Class;
		public var combobox: ComboBox;

		
		public var player: SampleGUIPlayer; 
		
		public function Main() {
			addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}
		
		private function addToStageHandler(event: Event): void {
			removeEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
			
			var bg: Bitmap = new BGClass();
			bg.smoothing = true;
			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;
			addChild(bg);
			
			stats = new Stats();
			addChild(stats);
						
			player = new SampleGUIPlayer();
			addChild(player);
			
			//change minimalcomp style
			Style.fontName = FontLib.FONT_NAME;
			Style.fontSize = 13;
			Style.LABEL_TEXT = 0x000000;
			
			combobox = new ComboBox();
			combobox.defaultLabel = "-- Chọn bài hát --";
			combobox.alternateRows = true;
			//combobox.addItem({label: , data: ""});
			combobox.width = 220;
			//get data from flashvars:
			var songList: String = loaderInfo.parameters["songList"];
			
			if(!songList) {
				songList = "Hạnh Phúc Bất Tận,xml/hanhphucbattan.xml;Cô Bé Mùa Đông,xml/cobemuadong.xml"
				songList += ";Con Đường Tình Yêu,xml/conduongtinhyeu.xml;Love Story,xml/lovestory.xml";
				songList += ";Love To Be Loved By You,xml/lovetobelovedbyyou.xml";
			}
			var songs: Array = songList.split(";");
			
			for (var i : int = 0; i < songs.length; i++) {
				var songInfo: Array = String(songs[i]).split(",");
				combobox.addItem({label: songInfo[0], data: songInfo[1]});
			}
			
			combobox.x = stage.stageWidth - combobox.width;
			combobox.addEventListener(Event.SELECT, comboboxChangeHandler);
			addChild(combobox);
		}

		private function comboboxChangeHandler(event: Event): void {
			var selectedItem: String = combobox.selectedItem.data;
			if(selectedItem) {
				player.load(selectedItem);
			}
		}
	}
}
