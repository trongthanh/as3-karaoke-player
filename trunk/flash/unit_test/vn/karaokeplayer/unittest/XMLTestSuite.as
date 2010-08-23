package vn.karaokeplayer.unittest {
	import vn.karaokeplayer.unittest.cases.StringUtilTester;
	import vn.karaokeplayer.unittest.cases.XMLParsingTester;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]	
	public class XMLTestSuite {
		public var xmlParsingTester: XMLParsingTester;
		public var stringUtilTester: StringUtilTester;
	}
	
}