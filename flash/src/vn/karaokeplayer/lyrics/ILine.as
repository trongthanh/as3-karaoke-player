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
	import vn.karaokeplayer.data.LineInfo;

	import org.osflash.signals.ISignal;

	/**
	 * @author Thanh Tran
	 */
	public interface ILine extends ISeekable {
		function init(data: LineInfo): void;
		function reset(): void;
		function dispose(): void;
		function get playing(): Boolean;
		function get complete(): Boolean;
		function toString(): String;
		function get completed(): ISignal;
		
		//some display object interfaces
		function get height(): Number;
		function get width(): Number;
		function get x(): Number;
		function set x(value: Number): void;
		function get y(): Number;
		function set y(value: Number): void;
	}
}
