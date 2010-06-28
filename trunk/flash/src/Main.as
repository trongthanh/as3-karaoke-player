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
	import flash.events.Event;
	import fl.data.DataProvider;
	import fl.controls.ComboBox;
	import net.hires.debug.Stats;
	import vn.karaokeplayer.gui.SampleGUIPlayer;

	import flash.display.Bitmap;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#000000", frameRate="31", width="600", height="400")]
	public class Main extends Sprite {
		public var stats: Stats;
		[Embed(source = '/../assets/images/simplygreen.jpg')]
		public var BGClass: Class;
		public var combobox: ComboBox;

		
		public var player: SampleGUIPlayer; 
		
		public function Main() {
			
			var bg: Bitmap = new BGClass();
			addChild(bg);
			
			stats = new Stats();
			addChild(stats);
						
			player = new SampleGUIPlayer();
			addChild(player);
			
			combobox = new ComboBox();
			combobox.addItem({label: "-- Chọn bài hát --", data: ""});
			combobox.width = 150;
			//get data from flashvars:
			var songList: String = loaderInfo.parameters["songList"];
			
			if(!songList) {
				songList = "Hạnh Phúc Bất Tận,xml/song1.xml;Cô Bé Mùa Đông,xml/song2.xml"
				songList += ";Con Đường Tình Yêu,xml/song3.xml;Love Story,xml/song4.xml";				songList += ";Love To Be Loved By You,xml/song5.xml";
			}
			var songs: Array = songList.split(";");
			
			for (var i : int = 0; i < songs.length; i++) {
				var songInfo: Array = String(songs[i]).split(",");
				combobox.addItem({label: songInfo[0], data: songInfo[1]});
			}
			
			combobox.x = stage.stageWidth - combobox.width;
			combobox.addEventListener(Event.CHANGE, comboboxChangeHandler);
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
