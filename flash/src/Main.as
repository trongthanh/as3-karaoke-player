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

		
		public var player: SampleGUIPlayer; 
		
		public function Main() {
			
			var bg: Bitmap = new BGClass();
			addChild(bg);
			
			player = new SampleGUIPlayer();
			addChild(player);
			
			player.load("xml/song3.xml");
			
			stats = new Stats();
			addChild(stats);
		}

		
	}
}
