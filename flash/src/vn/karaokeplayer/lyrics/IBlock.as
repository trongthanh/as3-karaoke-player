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
package vn.karaokeplayer.lyrics {
	import org.osflash.signals.Signal;
	import vn.karaokeplayer.data.LyricStyle;

	/**
	 * @author Thanh Tran
	 */
	public interface IBlock {
		function dispose(): void;
		function get width(): Number;
		function get height(): Number;
		function get text(): String;
		function set text(value: String): void;
		function setStyle(normalStyle: LyricStyle, syncStyle: LyricStyle): void;
		function reset(): void;
		function get completed(): Signal;
		function get begin(): Number;
		function set begin(value: Number): void;
		function get duration(): Number;
		function set duration(value: Number): void;
		function get end(): Number;
		function set end(value: Number): void;
	}
}
