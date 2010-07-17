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
