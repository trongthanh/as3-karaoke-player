package vn.karaokeplayer.unittest.cases {
	import vn.karaokeplayer.utils.TimeUtil;
	import org.flexunit.Assert;

	/**
	 * @author Thanh Tran
	 */
	public class TimeUtilTester {
		
		[Test(description="test TimeUtil.fillZeroes()")]
		public function testFillZerroes(): void {
			var input1: String = "1";
			var input2: String = "23";
			var input3: String = "456";
			
			Assert.assertEquals("len = 2", "01", TimeUtil.fillZeroes(input1, 2));
			Assert.assertEquals("len = 3", "023", TimeUtil.fillZeroes(input2, 3) );
			Assert.assertEquals("len = 3, no fill", "456", TimeUtil.fillZeroes(input3, 3));
		}
		
		
		[Test(description="test TimeUtil.msToClockString()")]
		public function testMsToClockString(): void {
			//trial 1
			var h: uint = 0;
			var m: uint = 59;
			var s: uint = 7;
			var ms: uint = 33;
			var timestamp: uint = (h * 3600 + m * 60 + s) * 1000 + ms; 
			var expectedStr: String = "00:59:07.033";
			
			Assert.assertEquals("trial 1", expectedStr, TimeUtil.msToClockString(timestamp));
			
			//trial 2
			h = 4;
			m = 6;
			s = 13;
			ms = 0;
			timestamp = (h * 3600 + m * 60 + s) * 1000 + ms; 
			expectedStr = "04:06:13.000";
			
			Assert.assertEquals("trial 2", expectedStr, TimeUtil.msToClockString(timestamp));
			
			//trial 3 - skip hour
			h = 0;
			m = 6;
			s = 13;
			ms = 0;
			timestamp = (h * 3600 + m * 60 + s) * 1000 + ms; 
			expectedStr = "06:13.000";
			
			Assert.assertEquals("trial 3 - skip hour", expectedStr, TimeUtil.msToClockString(timestamp, true));
			
		}
		
		[Test(description="test TimeUtil.clockStringToMs()")]
		public function testClockStringToMs(): void {
			//trial 1
			var input1: String = "00:12:34.567";
			var expected1: Number = (12 * 60 + 34) * 1000 + 567;
			
			Assert.assertEquals("00:12:34.567", expected1, TimeUtil.clockStringToMs(input1));			
			
			//trial 2
			var input2: String = "11:11:11.111";
			var expected2: Number = (11 * 3600 + 11 * 60 + 11) * 1000 + 111;
			
			Assert.assertEquals("11:11:11.111", expected2, TimeUtil.clockStringToMs(input2));
			
			//trial 3 - no hour
			var input3: String = "33:33.333";
			var expected3: Number = (33 * 60 + 33) * 1000 + 333;
			
			Assert.assertEquals("33:33.333", expected3, TimeUtil.clockStringToMs(input3));
			
		}
		
		[Test(description="test TimeUtil.timeOffsetToMs()")]
		public function testTimeOffsetToMs(): void {
			//trial 1 - hour
			var input1: String = "1.5h";
			var expected1: Number = 1.5 * 3600 * 1000;
			
			Assert.assertEquals("1.5h", expected1, TimeUtil.timeOffsetToMs(input1));			
			
			//trial 2 - minute
			var input2: String = "54.32m";
			var expected2: Number = 54.32 * 60 * 1000;
			
			Assert.assertEquals("54.32m", expected2, TimeUtil.timeOffsetToMs(input2));
			
			//trial 3 - seconds
			var input3: String = "99.99s";
			var expected3: Number = 99.99 * 1000;
			
			Assert.assertEquals("99.99s", expected3, TimeUtil.timeOffsetToMs(input3));
			
			//trial 4 - milliseconds
			var input4: String = "123456ms";
			var expected4: Number = 123456;
			
			Assert.assertEquals("123456ms", expected4, TimeUtil.timeOffsetToMs(input4));
			
			//trial 5 - bare number string
			var input5: String = "123456";
			var expected5: Number = 123456;
			
			Assert.assertEquals("123456", expected5, TimeUtil.timeOffsetToMs(input5));
			
		}
	}
}
