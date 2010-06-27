package vn.karaokeplayer.unittest.cases {
	import vn.karaokeplayer.utils.Timer;
	

	/**
	 * @author Thanh Tran
	 */
	public class TimerUtilTester {
		private var timer: Timer; 
		
		[Before]
		public function setUp(): void {
			timer = new Timer()	
		}
		
		[Test(async, description="Test complete event of timer")]
		public function testTimerComplete(): void {
			
			
		}
		
		
		[After]
		public function tearDown(): void {
			
		}
		
	}
}
