/**
 * Copyright 2010 Thanh Tran - trongthanh@gmail.com
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package vn.karaokeplayer.data {
	/**
	 * Karaoke Player's errors
	 * @author Thanh Tran
	 */
	public class KarPlayerError extends Error {
		public static const COMMON_ERROR: uint = 1300;
		public static const XML_ERROR: uint = 1301;
		public static const INVALID_XML: uint = 1302;
		public static const AUDIO_ERROR: uint = 1303;
		public static const INITALIZATION_ERROR: uint = 1304;
		
		private static const ERROR_MSG: Array = [
			"Karaoke common error"
			,"XML data error"
			,"Invalid TimedText XML"
			,"Audio Error"
			,"Initialization Error"
		]
		
		private var _code: uint;
		
		public function KarPlayerError(errCode: uint, message: String = null) {
			super("" + errCode + ": " + ERROR_MSG[errCode - COMMON_ERROR] +
			       ((message == null) ? "" : (": " + message)));
			name = "KarPlayerError";
			_code = errCode;
		}
		
		public function get code(): uint { return _code; }
		
	}

}