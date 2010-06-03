package org.thanhtran.karaokeplayer.unittest.cases {
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.engine.TextBlock;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.thanhtran.karaokeplayer.data.LyricBitInfo;
	import org.thanhtran.karaokeplayer.data.LyricBlockInfo;
	import org.thanhtran.karaokeplayer.data.LyricStyle;
	import org.thanhtran.karaokeplayer.data.SongInfo;
	import org.thanhtran.karaokeplayer.data.SongLyrics;
	import org.thanhtran.karaokeplayer.utils.StringUtil;
	import org.thanhtran.karaokeplayer.utils.TimedTextParser;

	public class XMLParsingTester {
		public var xmlPath: String = "xml/song1_unittest.xml";

		[Embed(source = "/../bin/xml/song1_unittest.xml", mimeType="application/octet-stream")]
		public var SongXML: Class;
		//
		default xml namespace = new Namespace("","http://www.w3.org/ns/ttml");
		
		private var songInfo: SongInfo;
		private var xml:XML;
		
		[Before]
		public function setUp(): void {
			songInfo = new SongInfo();
			xml = new XML(new SongXML());
		}
		
		[Test(async, order=1, description="Test Load XML")]
		public function loadXML(): void {
			trace('xmlPath: ' + (xmlPath));
			var loader: URLLoader = new URLLoader();
			var asyncHandler: Function = Async.asyncHandler(this, loadCompleteHandler, 1000, null, timeoutHandler);
			loader.addEventListener(Event.COMPLETE, asyncHandler);
			loader.load(new URLRequest(xmlPath));
			
		}

		private function timeoutHandler(): void {
			Assert.fail("Load failed");
		}

		private function loadCompleteHandler(event: Event, passData: Object) : void {
			var loader: URLLoader = URLLoader(event.target);
			
			var xml: XML = new XML(loader.data);
			if (xml) {
				Assert.assertTrue("Load XML success", true);
			} else {
				Assert.fail("Load XML failed");
			}
			
		}
		
		[Test(order=2, description="Test get song header")]
		public function getSongHeader(): void {
			
			TimedTextParser.parseSongHead(xml.head[0], songInfo);
			
			Assert.assertEquals("Verifying title", "Hạnh Phúc Bất Tận", songInfo.title);
			Assert.assertEquals("Verifying desc", "Composed by: Nguyễn Đức Thuận<br/>Singers: Hồ Ngọc Hà ft. V.Music Band", songInfo.description);
			Assert.assertEquals("Verifying desc", "Copyright (C) 2010 Thanh Tran - trongthanh@gmail.com", songInfo.copyright);
			Assert.assertEquals("Verifying audio", "mp3/hanh_phuc_bat_tan.mp3", songInfo.audio);
		}
		
		/**
		 * 
		 */
		[Test(order=3, description="Test parse song lyrics")]
		public function getSongLyrics(): void {
			
			TimedTextParser.parseSongLyrics(xml.body[0], songInfo);
			
			var songLyrics: SongLyrics = songInfo.lyrics;
			try {
				var blocks: Array = songLyrics.blockArray;
				//check block length
				Assert.assertEquals(21, blocks.length);
				//test block 1 (female)
				var block1: LyricBlockInfo = blocks[0];
				Assert.assertEquals(LyricStyle.FEMALE, block1.lyricStyle);
				
				var bits: Array = block1.lyricBits;
					
				Assert.assertEquals(21260, block1.startTime);
				
				Assert.assertEquals("* * *", LyricBitInfo(bits[0]).text);
				Assert.assertEquals(2520, LyricBitInfo(bits[0]).duration);
				
				Assert.assertEquals("Thắp nến đêm nay", LyricBitInfo(bits[1]).text);
				Assert.assertEquals(1720, LyricBitInfo(bits[1]).duration);
				
				//test block 2 (female)
				var block2: LyricBlockInfo = blocks[1];
				Assert.assertEquals(LyricStyle.FEMALE, block2.lyricStyle);
				
				bits = block2.lyricBits;
				
				Assert.assertEquals(25780, block2.startTime);
				
				Assert.assertEquals("ấm áp trong tay", LyricBitInfo(bits[0]).text);
				Assert.assertEquals(1720, LyricBitInfo(bits[0]).duration);
				
				//test block 10 (male)
				
				var block10: LyricBlockInfo = blocks[9];
				Assert.assertEquals(LyricStyle.MALE, block10.lyricStyle);
				
				bits = block10.lyricBits;
				
				Assert.assertEquals(47060, block10.startTime);
				
				Assert.assertEquals("để", LyricBitInfo(bits[0]).text);
				Assert.assertEquals(280, LyricBitInfo(bits[0]).duration);
				
				Assert.assertEquals("rồi", LyricBitInfo(bits[1]).text);
				Assert.assertEquals(440, LyricBitInfo(bits[1]).duration);
				
				Assert.assertEquals("khoảnh", LyricBitInfo(bits[2]).text);
				Assert.assertEquals(440, LyricBitInfo(bits[2]).duration);
				
				Assert.assertEquals("khắc", LyricBitInfo(bits[2]).text);
				Assert.assertEquals(720, LyricBitInfo(bits[2]).duration);
				
				//test block 17 (both/basic) 
				/*
				 * <div style="b">
					<p begin="00:03:39.350">từng</p>
					<p begin="00:03:39.630">giây</p>
					<p begin="00:03:40.030">phút</p>
				</div>
				 */
				
				var block17: LyricBlockInfo = blocks[16];
				Assert.assertEquals(LyricStyle.BASIC, block17.lyricStyle);
				
				bits = block17.lyricBits;
				
				Assert.assertEquals(219350, block17.startTime);
				
				Assert.assertEquals("từng", LyricBitInfo(bits[0]).text);
				Assert.assertEquals(280, LyricBitInfo(bits[0]).duration);
				
				Assert.assertEquals("giây", LyricBitInfo(bits[1]).text);
				Assert.assertEquals(400, LyricBitInfo(bits[1]).duration);
				
				Assert.assertEquals("phút", LyricBitInfo(bits[2]).text);
				Assert.assertEquals(1160, LyricBitInfo(bits[2]).duration);
				
				//test block 21 (female, last) 
				/*
				 * <div style="f">
					<p begin="00:04:20.710">phút</p>
					<p begin="00:04:21.070">giây</p>
					<p begin="00:04:21.470">này</p>
					<p begin="00:04:24.350">thuộc</p>
					<p begin="00:04:24.830">về</p>
					<p begin="00:04:25.270">nhau</p>
					<p begin="00:04:26.000">./.</p>
				</div>
				 */
				var block21: LyricBlockInfo = blocks[20];
				Assert.assertEquals(LyricStyle.FEMALE, block21.lyricStyle);
				
				bits = block21.lyricBits;
				
				Assert.assertEquals(260710, block21.startTime);
				
				Assert.assertEquals("phút", LyricBitInfo(bits[0]).text);
				Assert.assertEquals(360, LyricBitInfo(bits[0]).duration);
				
				Assert.assertEquals("giây", LyricBitInfo(bits[1]).text);
				Assert.assertEquals(400, LyricBitInfo(bits[1]).duration);
				
				Assert.assertEquals("này", LyricBitInfo(bits[2]).text);
				Assert.assertEquals(2880, LyricBitInfo(bits[2]).duration);
				
				Assert.assertEquals("thuộc", LyricBitInfo(bits[3]).text);
				Assert.assertEquals(450, LyricBitInfo(bits[3]).duration);
				
				Assert.assertEquals("về", LyricBitInfo(bits[4]).text);
				Assert.assertEquals(440, LyricBitInfo(bits[4]).duration);
				
				Assert.assertEquals("nhau", LyricBitInfo(bits[5]).text);
				Assert.assertEquals(730, LyricBitInfo(bits[5]).duration);
				
				Assert.assertEquals("./.", LyricBitInfo(bits[6]).text);
				Assert.assertEquals(0, LyricBitInfo(bits[6]).duration);
				
				
			} catch (err:Error){
				Assert.fail("songLyrics parse failed: \n" + StringUtil.truncate(err.getStackTrace(), 1000));
			}
			
			
			
			
			
			
			
			
		}
		
	}
		
}