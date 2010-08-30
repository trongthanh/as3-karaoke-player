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
package vn.karaokeplayer.utils {

	/**
	 * @author Thanh Tran
	 */
	public class TimeUtil {
		public static const CLOCK_REG: RegExp = /^((\d+):)?(\d+):((\d+)(.\d+)?)$/;
		public static const TIMEOFFSET_REG: RegExp = /^(\d+(.\d+)?)(h|m|s|ms)?$/;
		
		/**
		 * Converts from milliseconds value to clock string format (hh:mm:ss.iii)
		 * @param millis	milliseconds
		 * @return			clock string format
		 */
		public static function msToClockString(millis: Number, skipHour: Boolean = false): String {
			var str: String = fillZeroes(String(millis % 1000), 3);
			var remain: Number = uint(millis / 1000);
			str = fillZeroes(String(remain % 60), 2) + "." + str;
			remain = uint(remain / 60);
			str = fillZeroes(String(remain % 60), 2) + ":" + str;
			if(!skipHour)
				str = fillZeroes(String(uint(remain / 60)), 2) + ":" + str;
			
			return str;
		}
		
		/**
		 * Converts from clock string (hh:mm:ss.iii) to milliseconds
		 * @param clockStr	clock string
		 * @return	milliseconds / NaN if not converted
		 *
		 */
		public static function clockStringToMs(clockStr: String): Number {
			var ms: Number = NaN;
			var results:Object = CLOCK_REG.exec(clockStr);
			if (results != null) {
				ms = 0;
				ms += (uint(results[2]) * 3600 * 1000);
				ms += (uint(results[3]) * 60 * 1000);
				ms += uint((Number(results[4]) * 1000));
			}
			return ms;
		}
		
		/**
		 * Converts from time offset (hours, minutes, seconds, mlliseconds) to milliseconds
		 * @param timeOffset	time offset (####h|m|s|ms or just bare number)
		 * @return	milliseconds / NaN if not converted
		 */
		public static function timeOffsetToMs(timeOffset: String): Number {
			var ms: Number;
			var multiplier:Number;
			var results: Object = TIMEOFFSET_REG.exec(timeOffset);
			if (results != null) {
				switch (results[3]) {
				case "h": multiplier = 3600 * 1000; break;
				case "m": multiplier = 60 * 1000; break;
				case "s": multiplier = 1000; break;
				case "ms":
				default:
					multiplier = 1;
					break;
				}
				ms = Number(results[1]) * multiplier;
			} else {
				// as a last ditch we treat a bare number as milliseconds
				ms = uint(timeOffset);
				if (ms == 0) ms = NaN;
			}
			
			return ms;
		}

		/**
		 * Fills zeroes before a number (as String) to match a length. <br/>
		 * If string's length exceeds expected length, no zeroes are added and original string is returned 
		 * @param src	input string
		 * @param len	length to match
		 * @return		the processed string
		 */
		public static function fillZeroes(src: String, len: uint): String {
			if(!src) src = "";
			var out: String = src;
			
			while (out.length < len) {
				out = "0" + out;
			}
			
			return out;
		}
		
	}
}
