package thanhtran.karaokeplayer {
	import thanhtran.karaokeplayer.data.LyricStyle;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	public class KarPlayer extends Sprite {
		public static const VERSION: String = Version.VERSION;

		public function KarPlayer (width: Number = 600, height: Number = 400, 
								   basicStyle: LyricStyle = null, syncStyle: LyricStyle = null,
								   maleStyle: LyricStyle = null, femaleStyle: LyricStyle = null) 
		{
			
		}
		
		/**
		 * Play the audio and lyric without recording
		 */
		public function play(): void {
			
		}
		
		/**
		 * Play beat audio, lyrics and record at the same time 
		 */
		public function record(): void {
			
		}
	}
}
