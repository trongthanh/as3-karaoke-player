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
	import vn.karaokeplayer.data.BlockInfo;
	import vn.karaokeplayer.data.LyricStyle;

	import org.osflash.signals.Signal;

	/**
	 * @author Thanh Tran
	 */
	public interface IBlock {
		function init(blockInfo: BlockInfo): void;
		function setStyle(normalStyle: LyricStyle, syncStyle: LyricStyle): void;
		function dispose(): void;
		function get next(): IBlock;
		function set next(value: IBlock): void;
		function get width(): Number;
		function get noSpaceWidth(): Number;
		function get height(): Number;
		function get x(): Number;
		function set x(value: Number): void;
		function get text(): String;
		function reset(): void;
		function get completed(): Signal;
	}
}
