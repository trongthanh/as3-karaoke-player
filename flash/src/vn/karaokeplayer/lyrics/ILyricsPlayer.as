package vn.karaokeplayer.lyrics {
	import vn.karaokeplayer.data.SongLyrics;

	/**
	 * @author Thanh Tran
	 */
	public interface ILyricsPlayer {
		function init(lyrics: SongLyrics): void;
		
		/**
		 * position of the 
		 */
		function get position(): Number;
		function set position(position: Number): void;
		
		/**
		 * Test release memory
		 */
		function cleanUp(): void;
		
		//some display object interfaces
		function get width(): Number;
		function get height(): Number;
		function get x(): Number;
		function set x(value: Number): void;
		function get y(): Number;
		function set y(value: Number): void;
		function get alpha(): Number;
		function set alpha(value: Number): void;
	}
}
