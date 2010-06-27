package vn.karaokeplayer.unittest.cases {
	import org.flexunit.Assert;
	import flash.utils.getTimer;
	import org.flexunit.async.AsyncHandler;
	//import flash.utils.Timer;
	import vn.karaokeplayer.utils.Timer;
	

	/**
	 * @author Thanh Tran
	 */
	public class TimerUtilTester {
		private var timer: Timer;
		private var startTime : int;
		private var totalTime: int;
		private var count: int;
		private static const INTERVAL: int = 100;
		private static const REPEAT: int = 10;
		private static const COMPLETE_DELTA: int = 100;
		private static const TICK_DELTA: int = 10;
		
		[Before]
		public function setUp(): void {
			timer = new Timer(INTERVAL, REPEAT);
			totalTime = INTERVAL * REPEAT;
			count = 0;
		}

		[Test(async, timeout=1200, description="Test complete event of timer")]
		public function testTimerComplete(): void {
			var asyncHandler: AsyncHandler = new AsyncHandler(this, timerCompleteHandler, 1200);
			timer.completed.add(asyncHandler);
			startTime = getTimer();
			timer.start();	
		}

		private function timerCompleteHandler(): void {
			var dur: int = getTimer() - startTime;
			
			Assert.assertTrue((dur < totalTime + COMPLETE_DELTA) && (dur > totalTime - COMPLETE_DELTA));
		}
		
		[Test(async, timeout=1200, description="Test complete event of timer")]
		public function testTimerTick(): void {
			var asyncHandler: AsyncHandler = new AsyncHandler(this, timerTickHandler, 1200);
			timer.ticked.add(asyncHandler);
			startTime = getTimer();
			timer.start();	
		}

		private function timerTickHandler(): void {
			count ++;
			var now: int = getTimer();
			var dur: int = now - startTime;
			
			if((dur < INTERVAL - TICK_DELTA) || (dur > INTERVAL + TICK_DELTA)) {
				Assert.fail("Timer interval is out of tolerance : " + dur + " instead of: " + INTERVAL);
				return;
			}
			
			if(count == REPEAT) {
				Assert.assertTrue(true);
			}

		}

		[After]
		public function tearDown(): void {
			timer.reset();
			timer.completed.removeAll();
			timer.ticked.removeAll();
			timer = null;
		}
		
	}
}
