package vn.karaokeplayer.unittest.cases {
	import vn.karaokeplayer.utils.StringUtil;

	import org.flexunit.Assert;

	/**
	 * @author Thanh Tran
	 */
	public class StringUtilTester {
		
		[Test(description="test StringUtil.trim()")]
		public function testTrim(): void {
			var input1: String = "   text1";
			var input2: String = "text2     ";
			var input3: String = "    text3     ";
			
			Assert.assertEquals("trim left", "text1", StringUtil.trim(input1));
			Assert.assertEquals("trim right", "text2", StringUtil.trim(input2));
			Assert.assertEquals("trim both", "text3", StringUtil.trim(input3));
		}
		
		[Test(description="test StringUtil.trimLeft()")]
		public function testTrimLeft(): void {
			var input1: String = "   text1";
			var input2: String = "text2     ";
			var input3: String = "    text3     ";
			
			Assert.assertEquals("trim left", "text1", StringUtil.trimLeft(input1));
			Assert.assertEquals("keep right spaces", "text2     ", StringUtil.trimLeft(input2));
			Assert.assertEquals("keep right spaces", "text3     ", StringUtil.trimLeft(input3));
		}
		
		[Test(description="test StringUtil.trimRight()")]
		public function testTrimRight(): void {
			var input1: String = "   text1";
			var input2: String = "text2     ";
			var input3: String = "    text3     ";
			
			Assert.assertEquals("keep left spaces", "   text1", StringUtil.trimRight(input1));
			Assert.assertEquals("trim right", "text2", StringUtil.trimRight(input2));
			Assert.assertEquals("keep left spaces", "    text3", StringUtil.trimRight(input3));
		}
		
		
		public function testTruncate(): void {
			//TODO: implement test truncate
		}
		
		
		public function testToProperCase(): void {
			//TODO: implement test toProperCase
		}
		
		[Test(description="test StringUtil.replace()")]
		public function testReplace(): void {
			var input1: String = "Today is Monday. Today is monday. Today is monDay. Today is monday. Today is MONDAY.";
			var expected1: String = "Today is Sunday. Today is Sunday. Today is Sunday. Today is Sunday. Today is Sunday."
			
			Assert.assertEquals("replace all occurences", expected1, StringUtil.replace(input1, "Monday", "Sunday", false));
			
			var input2: String = "Today is Monday. Today is monday. Today is monDay. Today is monday. Today is MONDAY.";
			var expected2: String = "Today is Sunday. Today is monday. Today is monDay. Today is monday. Today is MONDAY.";
			
			Assert.assertEquals("replace all occurences", expected2, StringUtil.replace(input2, "Monday", "Sunday", true));
		}
		
		public function testTrimNewLine(): void {
			//TODO: implement test trimNewLine
		}
		
		[Test(description="test StringUtil.removeNewLines()")]
		public function testRemoveNewLines(): void {
			var input1: String = "te\r\nxt1";
			var input2: String = "tex\nt2";
			var input3: String = "tex\rt3";
			
			Assert.assertEquals("trim \\r\\n", "text1", StringUtil.removeNewLines(input1));
			Assert.assertEquals("trim \\n", "text2", StringUtil.removeNewLines(input2));
			Assert.assertEquals("trim \\r", "text3", StringUtil.removeNewLines(input3));
		}
		
		
		
	}
}
