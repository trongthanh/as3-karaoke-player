package vn.karaokeplayer.data {

	/**
	 * @author Thanh Tran
	 */
	public class KarPlayerOptions {
		public var width: Number = 600;
		public var height: Number = 400;
		public var paddingLeft: Number = 10;
		public var paddingRight: Number = 10;
		public var paddingTop: Number = 10;
		public var paddingBottom: Number = 10;
		
		/** Default volume of beat sound, 0 - 1 */
		public var beatVolume: Number = 1; 
		
		public var basicLyricStyle: LyricStyle;
		public var maleLyricStyle: LyricStyle;
		public var femaleLyricStyle: LyricStyle;
		public var syncLyricStyle: LyricStyle;
		
		//reserve for later impl'
		public var numLines: uint;
		public var align: String = "bottom"
		
		
	}
}
