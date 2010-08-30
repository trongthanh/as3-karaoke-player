package vn.karaokeplayer.unittest.cases {
	import org.flexunit.Assert;
	import vn.karaokeplayer.lyricseditor.utils.HTMLHelper;

	/**
	 * @author Thanh Tran
	 */
	public class HTMLHelperTester {
		
		[Test(description="test HTMLHelper.searchTimeMarkLink()")]
		public function testsearchTimeMarkLink(): void {
			//trial 1
			var htmlstr: String = '<a href="event:11111">{00:11.111}</a>when I first <a href="event:22222">{00:22.222}</a>saw you<br/>';
			var result: Object = HTMLHelper.searchTimeMarkLink(htmlstr, 22222);
			
			//trace(result);			
			Assert.assertNotNull(result);
			Assert.assertEquals("match front group",'<a href="event:11111">{00:11.111}</a>when I first ', result[1]);
			Assert.assertEquals("match rear group",'saw you<br/>', result[2]);
			
			
			//trial 2
			result = HTMLHelper.searchTimeMarkLink(htmlstr, 11111);
			Assert.assertNotNull(result);
			Assert.assertEquals("match front group",'', result[1]);
			Assert.assertEquals("match rear group",'when I first <a href="event:22222">{00:22.222}</a>saw you<br/>', result[2]);
			
			//trial 3 - not found, null expected
			result = HTMLHelper.searchTimeMarkLink(htmlstr, 12345);
			Assert.assertNull(result);	
		}
		
		[Test(description="test HTMLHelper.replaceTimeMarkLink()")]
		public function testReplaceTimeMarkLink(): void {
			//trial 1
			var htmlstr: String = '<a href="event:11111"><font color="#FF0000">{00:11.111}</font></a>when I first <a href="event:22222"><font color="#FF0000">{00:22.222}</font></a>saw you<br/>';
			var result: String = '<a href="event:11111"><font color="#FF0000">{00:11.111}</font></a>when I first <a href="event:33333"><font color="#FF0000">{00:33.333}</font></a>saw you<br/>';
			//trace(result);			
			Assert.assertEquals("replace 22222",result, HTMLHelper.replaceTimeMarkLink(htmlstr, 33333, 22222));
			
			//trial 2
			result = '<a href="event:12345"><font color="#FF0000">{00:12.345}</font></a>when I first <a href="event:22222"><font color="#FF0000">{00:22.222}</font></a>saw you<br/>';
			Assert.assertEquals("replace 11111",result, HTMLHelper.replaceTimeMarkLink(htmlstr, 12345, 11111));
			
			//trial 3 - not found, null expected
			Assert.assertNull("replace not found", HTMLHelper.replaceTimeMarkLink(htmlstr, 12345, 44444));	
		}
	}
}
