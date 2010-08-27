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
	import flash.display.DisplayObject;
	import vn.karaokeplayer.IKarPlayer;
	import fl.controls.Button;

	import thanhtran.stats.StatsButton;

	import vn.karaokeplayer.KarPlayer;
	import vn.karaokeplayer.data.KarPlayerOptions;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.Font;

	/**
	 * Simple demo of this engine. <br/>
	 * Built with Flex SDK 3.5. See ant/build.bat for more instruction <br/>
	 * See trunk/examples/sample_player for a complete example with GUI and controls   
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#CCCCCC", frameRate="31", width="600", height="400")]
	public class Demo extends Sprite {
		public var stats: StatsButton;
		public var playButton: Button;
		public var karplayer: IKarPlayer;
		
		[Embed(source = '/../assets/images/simplygreen.jpg')]
		public var BGClass: Class;
		
		
		[Embed(systemFont='Verdana'
		,fontFamily  = 'VerdanaRegularVN'
		,fontName  ='VerdanaRegularVN'
		,fontStyle   ='normal' // normal|italic
		,fontWeight  ='normal' // normal|bold
		,unicodeRange = 'U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E,U+00C0-U+00C3,U+00C8-U+00CA,U+00CC-U+00CD,U+00D0,U+00D2-U+00D5,U+00D9-U+00DA,U+00DD,U+00E0-U+00E3,U+00E8-U+00EA,U+00EC-U+00ED,U+00F2-U+00F5,U+00F9-U+00FA,U+00FD,U+0102-U+0103,U+0110-U+0111,U+0128-U+0129,U+0168-U+0169,U+01A0-U+01B0,U+1EA0-U+1EF9,U+02C6-U+0323'
		,mimeType='application/x-font'
		//,embedAsCFF='false'
		)]
		public static const fontClass:Class;
		
		public function Demo():void {
			Font.registerFont(fontClass);
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var bg: Bitmap = new BGClass();
			addChild(bg);
			
			//prepare KarPlayer options
			var options: KarPlayerOptions = new KarPlayerOptions();
			options.width = 600;
			options.height = 400;
			
			//instanciate the player 
			karplayer = new KarPlayer(options);
			karplayer.loadSong("xml/song1.xml");
			karplayer.ready.add(karPlayerReadyHandler);
			karplayer.audioCompleted.add(audioCompletedHandler);
			addChild(DisplayObject(karplayer));
						
			playButton = new Button();
			playButton.label = "Play";
			playButton.x = stage.stageWidth - playButton.width;
			playButton.addEventListener(MouseEvent.CLICK, playButtonClickHandler);
			addChild(playButton);
			
			//
			//testTextBlock();
			//testTextLine();
			
			stats = new StatsButton(true);
			addChild(stats);
		}

		private function audioCompletedHandler(): void {
			playButton.visible = true;
		}

		private function playButtonClickHandler(event: MouseEvent): void {
			playButton.visible = false;
			karplayer.play();	
		}

		private function karPlayerReadyHandler(): void {
			playButton.visible = true;			
		}
	}
}