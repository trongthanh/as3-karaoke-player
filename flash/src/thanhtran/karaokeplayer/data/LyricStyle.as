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
package thanhtran.karaokeplayer.data {

	/**
	 * TODO: consider support other property of text format like fontWeight, fontStyle, leading ... 
	 * @author Thanh Tran
	 */
	public class LyricStyle {
		public static const BASIC: String = "b";
		public static const MALE: String = "m";
		public static const FEMALE: String = "f";
		
		public static const DEFAULT_BASIC_STYLE: LyricStyle = new LyricStyle("Verdana",30, 0x33CC33, false, 0x000000);
		public static const DEFAULT_MALE_STYLE: LyricStyle = new LyricStyle("Verdana",30, 0x3299FF, false, 0x000000);
		public static const DEFAULT_FEMALE_STYLE: LyricStyle = new LyricStyle("Verdana",30, 0xFF32CC, false, 0x000000);
		public static const DEFAULT_SYNC_STYLE: LyricStyle = new LyricStyle("Verdana",30, 0xFF9900, false, 0x000000);
		
		public var color: Number;
		public var strokeColor: Number;
		public var font: String;
		public var size: Number;
		public var embedFonts: Boolean = false;
		
		//reserve for later
		public var lineSpace: Number; //space beetween lines
		public var fontWeight: String; //bold or normal
		public var fontStyle: String; //italic or normal
		 
		
		public function LyricStyle(font: String = null, size: Number = NaN, color: Number = NaN, 
									embedFonts: Boolean = false, strokeColor: Number = NaN) {
			if(font) this.font = font;
			if(size) this.size = size;
			if(color) this.color = color;
			this.embedFonts = embedFonts;
			if(strokeColor) this.strokeColor = strokeColor;
		}
	}
}
