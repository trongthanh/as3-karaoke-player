package vn.karaokeplayer.lyricseditor.managers {
	import flash.text.TextField;

	/**
	 * @author Thanh Tran
	 */
	public class ErrorMessageManager {
		private static var _errorText: TextField;
		
		public static function init(tf: TextField): void {
			_errorText = tf;
			_errorText.text = "";
		}
		
		public static function showMessage(msg: String, noError: Boolean = false): void {
			if(noError) _errorText.textColor = 0x00FF00;
			else _errorText.textColor = 0xFF0000;
			_errorText.text = msg;
		}
		
		public static function clearMessage(): void {
			if(_errorText.text)	_errorText.text = "";
		}
	}
}
