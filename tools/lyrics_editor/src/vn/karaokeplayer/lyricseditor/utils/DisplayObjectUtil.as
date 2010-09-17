package vn.karaokeplayer.lyricseditor.utils {
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;

	/**
	 * @author Thanh Tran
	 */
	public class DisplayObjectUtil {
		
		private static var _s: Number = 0;
		private static var _grayFilter: ColorMatrixFilter = new ColorMatrixFilter (
			[0.114 + 0.886 * _s,	0.299 * (1 - _s),	0.1 * (1 - _s),	0,	0,
			 0.114 * (1 - _s), 		0.299 + 0.701 * _s,	0.1 * (1 - _s),	0,	0, 
			 0.114 * (1 - _s), 		0.299 * (1 - _s),	0.1 + 0.413 * _s, 0,	0, 					
			 0,						0, 					0, 					1,	0]);
			
//			[0.114 + 0.886 * _s,	0.299 * (1 - _s),	0.587 * (1 - _s),	0,	0,
//			 0.114 * (1 - _s), 		0.299 + 0.701 * _s,	0.587 * (1 - _s),	0,	0, 
//			 0.114 * (1 - _s), 		0.299 * (1 - _s),	0.587 + 0.413 * _s, 0,	0, 					
//			 0,						0, 					0, 					1,	0]);
		
		public static function disableControl(target: Sprite): void {
			target.filters = null;
			target.mouseChildren = true;
			target.mouseEnabled = true;
		}
		
		public static function enableControl(target: Sprite): void {
			target.filters = [_grayFilter];
			target.mouseChildren = false;
			target.mouseEnabled = false;
		}
		
		public static function isControlEnabled(target: Sprite): Boolean {
			return target.mouseChildren;
		}
	}
}
