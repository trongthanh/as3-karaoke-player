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
	import thanhtran.stats.StatsButton;

	import vn.karaokeplayer.data.BlockInfo;
	import vn.karaokeplayer.data.LineInfo;
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.data.SongLyrics;
	import vn.karaokeplayer.lyrics.LyricsPlayer;
	import vn.karaokeplayer.lyrics.TextBlock;
	import vn.karaokeplayer.lyrics.TextLine;
	import vn.karaokeplayer.utils.EnterFrameManager;
	import vn.karaokeplayer.utils.TimedTextParser;

	import com.bit101.components.PushButton;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.text.Font;
	import flash.utils.getTimer;

	/**
	 * To test different components of KarPlayer  
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#CCCCCC", frameRate="31", width="600", height="400")]
	public class Demo extends Sprite {
		public var stats: StatsButton;
		public var playButton: PushButton;
		private var block:TextBlock;
		private var line: TextLine;
		
		[Embed(source = '/../assets/images/simplygreen.jpg')]
		public var BGClass: Class;
		
		[Embed(source = "/../bin/xml/song1.xml", mimeType="application/octet-stream")]
//		[Embed(source = "/../bin/xml/song2.xml", mimeType="application/octet-stream")]
		public var SongXML: Class;
		[Embed(source = "/../bin/audio/hanh_phuc_bat_tan.mp3")]
//		[Embed(source = "/../bin/audio/co_be_mua_dong.mp3")]
		public var SongAudio: Class
		
		[Embed(systemFont='Verdana'
		,fontFamily  = 'VerdanaRegularVN'
		,fontName  ='VerdanaRegularVN'
		,fontStyle   ='normal' // normal|italic
		,fontWeight  ='normal' // normal|bold
		,unicodeRange = 'U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E,U+00C0-U+00C3,U+00C8-U+00CA,U+00CC-U+00CD,U+00D0,U+00D2-U+00D5,U+00D9-U+00DA,U+00DD,U+00E0-U+00E3,U+00E8-U+00EA,U+00EC-U+00ED,U+00F2-U+00F5,U+00F9-U+00FA,U+00FD,U+0102-U+0103,U+0110-U+0111,U+0128-U+0129,U+0168-U+0169,U+01A0-U+01B0,U+1EA0-U+1EF9,U+02C6-U+0323'
		,mimeType='application/x-font'
		,embedAsCFF='false'
		)]
		public static const fontClass:Class;
		
		public var sound: Sound;
		public var lyricPlayer: LyricsPlayer;
		public var startTime: int;
		public var enterFrameManager: EnterFrameManager;
		
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
			
			playButton = new PushButton();
			playButton.label = "Start";
			playButton.x = stage.stageWidth - playButton.width;
			playButton.addEventListener(MouseEvent.CLICK, playButtonClickHandler);
			addChild(playButton);
			enterFrameManager = new EnterFrameManager();
			
			//testTextBlock();
			//testTextLine();
			testLyricPlayer();
			
			testControlBar();
			
			stats = new StatsButton(true);
			addChild(stats);
		}

		private function testControlBar(): void {
			
		}

		private function testLyricPlayer(): void {
			var xml: XML = new XML(new SongXML());
			sound = new SongAudio();
			var lyricParser: TimedTextParser = new TimedTextParser();
			var songInfo: SongInfo = lyricParser.parseXML(xml);
			lyricPlayer = new LyricsPlayer(500, 360);
			lyricPlayer.y = 20;
			lyricPlayer.x = 50;
			trace("karPlayer version: " + LyricsPlayer.VERSION);
			var lyrics: SongLyrics = songInfo.lyrics;
			lyrics.basicLyricStyle.font = "VerdanaRegularVN";
			lyrics.basicLyricStyle.embedFonts = true;
			lyrics.maleLyricStyle.font = "VerdanaRegularVN";
			lyrics.maleLyricStyle.embedFonts = true;
			lyrics.femaleLyricStyle.font = "VerdanaRegularVN";
			lyrics.femaleLyricStyle.embedFonts = true;
			lyricPlayer.init(songInfo.lyrics);
			addChild(lyricPlayer);
			
			
		}

		private function playButtonClickHandler(event: MouseEvent): void {
			//bit.play();
			//textBlock.play();
			enterFrameManager.enterFrame.add(enterFrameHandler);
			startTime = getTimer();
			var channel: SoundChannel = sound.play(0,1,new SoundTransform(0.5));
			playButton.visible = false;
		}

		private function enterFrameHandler(): void {
			var pos: int = getTimer() - startTime;
			
			lyricPlayer.position = pos;
			//test text block seekable:
			//block.position = pos;
			//test text line seekable:
			//line.position = pos;
		}

		/*
		 * test text bit:
		 */
		public function testTextBlock(): void {
			var blockInfo: BlockInfo = new BlockInfo();
			blockInfo.text ="Tran Trong Thanh"; 
			blockInfo.begin = 0;
			blockInfo.duration = 5000;
			
			block = new TextBlock();
			block.init(blockInfo);
			block.completed.add(blockCompleteHandler);
			addChild(block);
		}

		private function blockCompleteHandler(block: TextBlock): void {
			trace("block complete");
		}

		public function testTextLine(): void {
			var lb: LineInfo = new LineInfo();
			var mockupSongLyric: SongLyrics = new SongLyrics();
			lb.songLyrics = mockupSongLyric; 
			 
			var lbit1: BlockInfo = new BlockInfo();
			lbit1.text = "*";
			lbit1.duration = 2520;
			
			lb.lyricBlocks.push(lbit1);
			
			var lbit2: BlockInfo = new BlockInfo();
			lbit2.text = "Thắp nến đêm nay";
			lbit2.duration = 2000;
			
			lb.lyricBlocks.push(lbit2);
			
			var lbit3: BlockInfo = new BlockInfo();
			lbit3.text = "ấm áp trong tay";
			lbit3.duration = 1720;
			
			lb.lyricBlocks.push(lbit3);
			
			line = new TextLine();
			line.init(lb);
			line.completed.add(textLineCompleteHandler);
			
			addChild(line);
		}

		private function textLineCompleteHandler(tl: TextLine): void {
			trace("text line complete");
		}
	}
}