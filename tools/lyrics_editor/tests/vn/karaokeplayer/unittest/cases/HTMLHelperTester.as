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
			var htmlstr: String = '<A HREF="event:11111" TARGET="">{00:11.111}</A>when I first <A HREF="event:22222" TARGET="">{00:22.222}</A>saw you<BR/>';
			var result: Object = HTMLHelper.searchTimeMarkLink(htmlstr, 22222);
			
			//trace(result);			
			Assert.assertNotNull(result);
			Assert.assertEquals("match front group",'<A HREF="event:11111" TARGET="">{00:11.111}</A>when I first ', result[1]);
			Assert.assertEquals("match rear group",'saw you<BR/>', result[2]);
			
			
			//trial 2
			result = HTMLHelper.searchTimeMarkLink(htmlstr, 11111);
			Assert.assertNotNull(result);
			Assert.assertEquals("match front group",'', result[1]);
			Assert.assertEquals("match rear group",'when I first <A HREF="event:22222" TARGET="">{00:22.222}</A>saw you<BR/>', result[2]);
			
			//trial 3 - not found, null expected
			result = HTMLHelper.searchTimeMarkLink(htmlstr, 12345);
			Assert.assertNull(result);	
		}
		
		[Test(description="test HTMLHelper.replaceTimeMarkLink()")]
		public function testReplaceTimeMarkLink(): void {
			//trial 1
			var htmlstr: String = '<A HREF="event:11111" TARGET="">{00:11.111}</A>when I first <A HREF="event:22222" TARGET="">{00:22.222}</A>saw you<BR/>';
			var result: String = '<A HREF="event:11111" TARGET="">{00:11.111}</A>when I first <A HREF="event:33333" TARGET="">{00:33.333}</A>saw you<BR/>';
			//trace(result);			
			Assert.assertEquals("replace 22222",result, HTMLHelper.replaceTimeMarkLink(htmlstr, 33333, 22222));
			
			//trial 2
			result = '<A HREF="event:12345" TARGET="">{00:12.345}</A>when I first <A HREF="event:22222" TARGET="">{00:22.222}</A>saw you<BR/>';
			Assert.assertEquals("replace 11111",result, HTMLHelper.replaceTimeMarkLink(htmlstr, 12345, 11111));
			
			//trial 3 - not found, null expected
			Assert.assertNull("replace not found", HTMLHelper.replaceTimeMarkLink(htmlstr, 12345, 44444));	
		}
		
		[Test(description="test HTMLHelper.stripHTML()")]
		public function testStripHTML(): void {
			//trial 1
			var htmlstr: String = '<a href="event:11111"><font color="#FF0000">{00:11.111}</font></a>when I first <a href="event:22222"><font color="#FF0000">{00:22.222}</font></a>saw you<br/>';
			var result: String = '{00:11.111}when I first {00:22.222}saw you';
			//trace(result);			
			Assert.assertEquals("strip html",result, HTMLHelper.stripHTML(htmlstr));
				
		}
		
		[Test(description="test HTMLHelper.unescapeHTMLEntities")]
		public function testUnescapeHTMLEntities(): void {
			//trial 1
			var str: String = '&quot;But you ain&apos;t seen &lt;nothing&gt; like me yet. There ain&apos;t nothing that I wouldn&apos;t do. Go to the ends of the earth for you&quot;';
			var result: String = '"But you ain\'t seen <nothing> like me yet. There ain\'t nothing that I wouldn\'t do. Go to the ends of the earth for you"';
			//trace(result);			
			Assert.assertEquals("unescape html entities",result, HTMLHelper.unescapeHTMLEntities(str));
				
		}
	}
}
