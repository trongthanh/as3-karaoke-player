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
	import flash.media.Sound;

	/**
	 * @author Thanh Tran
	 */
	public class SongInfo {
		/** original XML for later extension */
		public var songXML: XML;
		public var title: String = "";
		public var description: String = "";
		public var copyright: String = "";
		public var beatURL: String = "";
		public var lyrics: SongLyrics;
		
		/** used to store reference of Sound object for this song */
		public var beatSound: Sound;
	}
}
