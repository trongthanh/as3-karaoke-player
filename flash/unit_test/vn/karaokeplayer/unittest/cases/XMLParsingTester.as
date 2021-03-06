package vn.karaokeplayer.unittest.cases {
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import vn.karaokeplayer.data.KarPlayerError;
	import vn.karaokeplayer.data.BlockInfo;
	import vn.karaokeplayer.data.LineInfo;
	import vn.karaokeplayer.data.LyricStyle;
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.data.SongLyrics;
	import vn.karaokeplayer.karplayer_internal;
	import vn.karaokeplayer.parsers.TimedTextParser;

	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	use namespace karplayer_internal;
	public class XMLParsingTester {
		public var xmlPath: String = "xml/song1_unittest.xml";

		[Embed(source = "/../bin/xml/song1_unittest.xml", mimeType="application/octet-stream")]
		public var SongXML: Class;
		//
		default xml namespace = new Namespace("","http://www.w3.org/ns/ttml");
		
		private var songInfo: SongInfo;
		private var xml:XML;
		private var parser: TimedTextParser;
		
		[Before]
		public function setUp(): void {
			songInfo = new SongInfo();
			xml = new XML(new SongXML());
			parser = new TimedTextParser();
		}
		
		[After]
		public function tearDown(): void {
			songInfo = null;
			xml = null;
			parser = null;
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
		
		[Test(order=2, description="Test parse song header, extra metadata has namespace")]
		public function testParseSongHeader(): void {
			
			parser.parseSongHead(xml.head[0], songInfo);
			
			Assert.assertEquals("Verifying title", "Hạnh Phúc Bất Tận", songInfo.title);
			Assert.assertEquals("Verifying desc", "Composed by: Nguyễn Đức Thuận<br/>Singers: Hồ Ngọc Hà ft. V.Music Band", songInfo.description);
			Assert.assertEquals("Verifying desc", "Copyright (C) 2010 Thanh Tran - trongthanh@gmail.com", songInfo.copyright);
			Assert.assertEquals("Verifying audio", "mp3/hanh_phuc_bat_tan.mp3", songInfo.beatURL);
			Assert.assertEquals("Veryfying id", "0001", songInfo.id);			Assert.assertEquals("Veryfying composer", "Nguyễn Đức Thuận", songInfo.composer);
			Assert.assertEquals("Veryfying styleof", "Hồ Ngọc Hà ft. V.Music Band", songInfo.styleof);			Assert.assertEquals("Veryfying genre", "pop", songInfo.genre);			Assert.assertEquals("Veryfying mood", "love", songInfo.mood);
		}
		
		[Test(order=2, description="Test parse song metadata, extra metadata has no namespace")]
		public function testParseMetadataNoNamespace(): void {
			var metadataXML: XML = 
			<metadata xml:lang="vi"
			    xmlns="http://www.w3.org/ns/ttml"
			    xmlns:tts="http://www.w3.org/ns/ttml#styling"
			    xmlns:ttm="http://www.w3.org/ns/ttml#metadata"
			    xmlns:kar="http://code.google.com/p/as3-karaoke-player">
			<ttm:title><![CDATA[Hạnh Phúc Bất Tận]]></ttm:title>
			<ttm:desc><![CDATA[Composed by: Nguyễn Đức Thuận<br/>Singers: Hồ Ngọc Hà ft. V.Music Band]]></ttm:desc>
			<ttm:copyright>Copyright (C) 2010 Thanh Tran - trongthanh@gmail.com</ttm:copyright>
			<id>0002</id>
			<composer>Nguyễn Đức Thuận</composer>
			<styleof>Hồ Ngọc Hà ft. V.Music Band</styleof>
			<mood>love</mood>
			<genre>pop</genre>
			<audio>mp3/hanh_phuc_bat_tan.mp3</audio>
			</metadata>;
			
			parser.parseMetadata(metadataXML, songInfo);
			
			Assert.assertEquals("Verifying title", "Hạnh Phúc Bất Tận", songInfo.title);
			Assert.assertEquals("Verifying desc", "Composed by: Nguyễn Đức Thuận<br/>Singers: Hồ Ngọc Hà ft. V.Music Band", songInfo.description);
			Assert.assertEquals("Verifying desc", "Copyright (C) 2010 Thanh Tran - trongthanh@gmail.com", songInfo.copyright);
			Assert.assertEquals("Verifying audio", "mp3/hanh_phuc_bat_tan.mp3", songInfo.beatURL);
			Assert.assertEquals("Veryfying id", "0002", songInfo.id);
			Assert.assertEquals("Veryfying composer", "Nguyễn Đức Thuận", songInfo.composer);
			Assert.assertEquals("Veryfying styleof", "Hồ Ngọc Hà ft. V.Music Band",  songInfo.styleof);
			Assert.assertEquals("Veryfying genre", "pop", songInfo.genre);
			Assert.assertEquals("Veryfying mood", "love", songInfo.mood);
		}
		
		[Test(order=2, description="Test parse song metadata, metadata with namespace overwrite no namespace")]
		public function testParseMetadataNamespaceOverwrite(): void {
			var metadataXML: XML = 
			<metadata xml:lang="vi"
			    xmlns="http://www.w3.org/ns/ttml"
			    xmlns:tts="http://www.w3.org/ns/ttml#styling"
			    xmlns:ttm="http://www.w3.org/ns/ttml#metadata"
			    xmlns:kar="http://code.google.com/p/as3-karaoke-player">
			<ttm:title><![CDATA[Hạnh Phúc Bất Tận]]></ttm:title>
			<ttm:desc><![CDATA[Composed by: Nguyễn Đức Thuận<br/>Singers: Hồ Ngọc Hà ft. V.Music Band]]></ttm:desc>
			<ttm:copyright>Copyright (C) 2010 Thanh Tran - trongthanh@gmail.com</ttm:copyright>
			<kar:id>0003</kar:id>
			<kar:composer>Nguyễn Đức Thuận</kar:composer>
			<kar:styleof>Hồ Ngọc Hà ft. V.Music Band</kar:styleof>
			<kar:genre>pop</kar:genre>
			<kar:mood>love</kar:mood>
			<kar:audio>mp3/hanh_phuc_bat_tan.mp3</kar:audio>
			<id>0003_overwritten</id>
			<composer>Nguyễn Đức Thuận_overwritten</composer>
			<styleof>Hồ Ngọc Hà ft. V.Music Band_overwritten</styleof>
			<mood>love_overwritten</mood>
			<genre>pop_overwritten</genre>
			<audio>mp3/hanh_phuc_bat_tan.mp3_overwritten</audio>
			</metadata>;
			
			parser.parseMetadata(metadataXML, songInfo);
			
			Assert.assertEquals("Verifying title", "Hạnh Phúc Bất Tận", songInfo.title);
			Assert.assertEquals("Verifying desc", "Composed by: Nguyễn Đức Thuận<br/>Singers: Hồ Ngọc Hà ft. V.Music Band", songInfo.description);
			Assert.assertEquals("Verifying desc", "Copyright (C) 2010 Thanh Tran - trongthanh@gmail.com", songInfo.copyright);
			Assert.assertEquals("Verifying audio", "mp3/hanh_phuc_bat_tan.mp3", songInfo.beatURL);
			Assert.assertEquals("Veryfying id", "0003", songInfo.id);
			Assert.assertEquals("Veryfying composer", "Nguyễn Đức Thuận", songInfo.composer);
			Assert.assertEquals("Veryfying styleof", "Hồ Ngọc Hà ft. V.Music Band", songInfo.styleof);
			Assert.assertEquals("Veryfying genre", "pop", songInfo.genre);
			Assert.assertEquals("Veryfying mood", "love", songInfo.mood);
		}
		
		[Test(order=3, description="Test getValueFromSet function")]
		public function testGetValueFromSet(): void {
			var set: Array = ["b", "m", "f"];
			
			//test value within set
			var validVal: Object = parser.getValueFromSet("f", set);
			Assert.assertEquals("Test valid value", "f", validVal);
			
			//test value outside set
			var outVal: Object = parser.getValueFromSet("z", set);
			Assert.assertEquals("Test invalid value, return default", "b", outVal);
		}
		
		[Test(order=4, description="Test parseTimeAttribute function")]
		public function testParseTimeAttribute(): void {
			var ms: Number;
			// test clock 1
			ms = parser.parseTimeAttribute( <div dur='00:00:00.456' /> , "dur", true);
			Assert.assertEquals("Test clock ms", 456, ms);
			
			// test clock 1' (missing hour)
			ms = parser.parseTimeAttribute( <div dur='00:00.789' /> , "dur", true);
			Assert.assertEquals("Test clock ms", 789, ms);
			
			// test clock 1'' (missing hour, minute)
			//FAILED, won't allow this case
			//ms = parser.parseTimeAttribute( <div dur='01.234' /> , "dur", true);
			//Assert.assertEquals("Test clock ms", 1234, ms);
			
			
			// test clock 2
			ms = parser.parseTimeAttribute( <div begin='00:00:03.456' /> , "begin", true);
			Assert.assertEquals("Test clock s.ms", 3456, ms);
			
			// test clock 3
			ms = parser.parseTimeAttribute( <div end='00:02:03.456' /> , "end", true);
			Assert.assertEquals("Test clock m:s.ms", 123456, ms);
			
			// test clock 1
			ms = parser.parseTimeAttribute( <p begin='01:02:03.456' /> , "begin", true);
			Assert.assertEquals("Test clock h:m:s.ms", 3723456, ms);
			
			//test hour value
			ms = parser.parseTimeAttribute( <p dur='0.01h' /> , "dur", true);
			Assert.assertEquals("Test hour value", 36000, ms);
			
			//test minute value
			ms = parser.parseTimeAttribute( <p dur='1.5m' /> , "dur", true);
			Assert.assertEquals("Test minute value", 90000, ms);
			
			//test second value
			ms = parser.parseTimeAttribute( <p dur='3.45s' /> , "dur", true);
			Assert.assertEquals("Test second value", 3450, ms);
			
			//test millisec value
			ms = parser.parseTimeAttribute( <p dur='9876ms' /> , "dur", true);
			Assert.assertEquals("Test millisec value", 9876, ms);
			
			//test default millisec value
			ms = parser.parseTimeAttribute( <p dur='5432' /> , "dur", true);
			Assert.assertEquals("Test default millisec value", 5432, ms);
			
			//test no required value
			ms = parser.parseTimeAttribute( <p begin='5432' /> , "dur", false);
			Assert.assertTrue("Test default millisec value", isNaN(ms));
			
			//test required value
			try {
				ms = parser.parseTimeAttribute( <p /> , "dur", true);
				Assert.fail("test failed if reach here");
			} catch (err: KarPlayerError){
				Assert.assertEquals("Test required value", KarPlayerError.INVALID_XML, err.code);
			}
			
		}
		
		/**
		 * TODO: test time logic:
		 * - next begin must not sooner than previous begin
		 * - line start + line duration must not exceed next line start  
		 */
		[Test(order=5, description="Test parse song lyrics")]
		public function testParseSongLyrics(): void {
			
			parser.parseSongLyrics(xml.body[0], songInfo);
			
			var songLyrics: SongLyrics = songInfo.lyrics;
			//try {
				var lines: Array = songLyrics.lyricLines;
				//check line length
				Assert.assertEquals(21, lines.length);
				//test line 1 (female)
				var line1: LineInfo = lines[0];
				Assert.assertEquals(LyricStyle.FEMALE, line1.styleName);
				
				var blocks: Array = line1.lyricBlocks;
					
				Assert.assertEquals(21260, line1.begin);
				
				Assert.assertEquals("* * *", BlockInfo(blocks[0]).text);
				Assert.assertEquals(2520, BlockInfo(blocks[0]).duration);
				
				Assert.assertEquals("Thắp nến đêm nay", BlockInfo(blocks[1]).text);
				//Assert.assertEquals(2000, BlockInfo(blocks[1]).duration);
				//dur at the last p should overwrite any begin
				Assert.assertEquals(1200, BlockInfo(blocks[1]).duration);
				
				Assert.assertEquals(3720, line1.duration);
				
				//test line 2 (female)
				var line2: LineInfo = lines[1];
				Assert.assertEquals(LyricStyle.FEMALE, line2.styleName);
				
				blocks = line2.lyricBlocks;
				
				Assert.assertEquals(25780, line2.begin);
				
				Assert.assertEquals("ấm áp trong tay", BlockInfo(blocks[0]).text);
				Assert.assertEquals(1720, BlockInfo(blocks[0]).duration);
				
				Assert.assertEquals(1720, line2.duration);
				
				//test line 10 (male)
				
				var line10: LineInfo = lines[9];
				Assert.assertEquals(LyricStyle.MALE, line10.styleName);
				
				blocks = line10.lyricBlocks;
				
				Assert.assertEquals(47060, line10.begin);
				
				Assert.assertEquals("để", BlockInfo(blocks[0]).text);
				Assert.assertEquals(280, BlockInfo(blocks[0]).duration);
				
				Assert.assertEquals("rồi", BlockInfo(blocks[1]).text);
				Assert.assertEquals(440, BlockInfo(blocks[1]).duration);
				
				Assert.assertEquals("khoảnh", BlockInfo(blocks[2]).text);
				Assert.assertEquals(440, BlockInfo(blocks[2]).duration);
				
				Assert.assertEquals("khắc", BlockInfo(blocks[3]).text);
				Assert.assertEquals(720, BlockInfo(blocks[3]).duration);
				
				Assert.assertEquals(1880, line10.duration);
				
				//test line 17 (both/basic) 
				/*
				 * <div style="b">
					<p begin="00:03:39.350">từng</p>
					<p begin="00:03:39.630">giây</p>
					<p begin="00:03:40.030">phút</p>
				</div>
				 */
				
				var line17: LineInfo = lines[16];
				Assert.assertEquals(LyricStyle.BASIC, line17.styleName);
				
				blocks = line17.lyricBlocks;
				
				Assert.assertEquals(219350, line17.begin);
				
				Assert.assertEquals("từng", BlockInfo(blocks[0]).text);
				Assert.assertEquals(280, BlockInfo(blocks[0]).duration);
				
				Assert.assertEquals("giây", BlockInfo(blocks[1]).text);
				Assert.assertEquals(400, BlockInfo(blocks[1]).duration);
				
				Assert.assertEquals("phút", BlockInfo(blocks[2]).text);
				Assert.assertEquals(1160, BlockInfo(blocks[2]).duration);
				
				Assert.assertEquals(1840, line17.duration);
				
				//test line 21 (female, last) 
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
				var line21: LineInfo = lines[20];
				Assert.assertEquals(LyricStyle.FEMALE, line21.styleName);
				
				blocks = line21.lyricBlocks;
				
				Assert.assertEquals(260710, line21.begin);
				
				Assert.assertEquals("phút", BlockInfo(blocks[0]).text);
				Assert.assertEquals(360, BlockInfo(blocks[0]).duration);
				
				Assert.assertEquals("giây", BlockInfo(blocks[1]).text);
				Assert.assertEquals(400, BlockInfo(blocks[1]).duration);
				
				Assert.assertEquals("này", BlockInfo(blocks[2]).text);
				Assert.assertEquals(2880, BlockInfo(blocks[2]).duration);
				
				Assert.assertEquals("thuộc", BlockInfo(blocks[3]).text);
				Assert.assertEquals(480, BlockInfo(blocks[3]).duration);
				
				Assert.assertEquals("về", BlockInfo(blocks[4]).text);
				Assert.assertEquals(440, BlockInfo(blocks[4]).duration);
				
				Assert.assertEquals("nhau", BlockInfo(blocks[5]).text);
				Assert.assertEquals(2000, BlockInfo(blocks[5]).duration);
				
				//discourage use of ./.
				//Assert.assertEquals("./.", BlockInfo(blocks[6]).text);
				//Assert.assertEquals(0, BlockInfo(blocks[6]).duration);
				
				Assert.assertEquals(6560, line21.duration);
			//} catch (err:Error){
				//Assert.fail("songLyrics parse failed: \n" + StringUtil.truncate(err.getStackTrace(), 1000));
			//}
		}
		
		[Test(order=6, description="Test the new begin time in each block")]
		public function testParseBlockBeginTime(): void {
			
			parser.parseSongLyrics(xml.body[0], songInfo);
			
			var songLyrics: SongLyrics = songInfo.lyrics;
			
			for (var i : int = 0; i < songLyrics.lyricLines.length; i++) {
				var line: LineInfo = songLyrics.lyricLines[0];
				var begin: Number = line.begin;
				for (var j : int = 0; j < line.lyricBlocks.length; j++) {
					Assert.assertEquals(begin,line.lyricBlocks[j].begin);
					begin += line.lyricBlocks[j].duration;
				}
				
			}	
		}
		
		[Test(order=7, description="Test get extra metadata ")]
		public function testGetExtraMetadata(): void {
			var songInfo: SongInfo = parser.parseXML(xml);
			
			Assert.assertEquals("Checking extra data 1", "extra item 1", songInfo.getExtra("extraItem1"));			Assert.assertEquals("Checking extra data 2 (overwrite)", "extra item 2", songInfo.getExtra("extraItem2"));			Assert.assertEquals("Checking extra data 3 (default namespace)", "extra item 3", songInfo.getExtra("extraItem3"));
			
		}
	}
		
}