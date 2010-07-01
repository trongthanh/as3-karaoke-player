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
	import org.osflash.signals.Signal;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * Simple loader to load different assets
	 * @author Thanh Tran
	 */
	public class AssetLoader {
		public var completed: Signal;
		/**
		 * Arguments: AssetLoader, percent, byteLoaded, byteTotal
		 */
		public var progress: Signal;
		public var failed: Signal;
		public var url: String;
		public var data: *;
		public var type: String;
		
		public function AssetLoader() {
			completed = new Signal(AssetLoader);
			progress = new Signal(AssetLoader, Number, uint, uint); 
			failed = new Signal(AssetLoader, String);
		}
		
		/**
		 * TODO: add loader context for cross domain checking
		 * @param	url
		 */
		public function load(url: String): void {
			this.url = url; 
//			trace('url: ' + (url));
			switch(checkType(url)) {
				case "MP3":
					var sound: Sound = new Sound();		            
					sound.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					sound.addEventListener(ProgressEvent.PROGRESS, progressHandler);
					sound.addEventListener(Event.COMPLETE, loadSoundCompleteHandler);
		            try {
		                sound.load(new URLRequest(url));
		            } catch ( e :SecurityError ) {
						failed.dispatch(this, "Security error");
					}
					break;
				case "SWF":
				case "IMAGE":
					var loader: Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					loader.load(new URLRequest(url), new LoaderContext(true));
					break;
				case "TEXT":
					var urlLoader: URLLoader = new URLLoader();
					urlLoader.addEventListener(Event.COMPLETE, urlLoaderCompleteHandler);
					urlLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
					urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					urlLoader.load(new URLRequest(url));
					break;
				default:
					trace("URL is invalid");
			}
		}

		private function loadSoundCompleteHandler(event: Event): void {
			data = event.target;			
			completed.dispatch(this);	
		}

		private function ioErrorHandler(event: IOErrorEvent): void {
			trace("Asset load failed: " + url);
			failed.dispatch(this, "I/O Error");	
		}

		private function loaderCompleteHandler(event: Event): void {
			var loaderInfo: LoaderInfo = LoaderInfo(event.target);
			data = loaderInfo.content;
			completed.dispatch(this);
		}
		
		private function urlLoaderCompleteHandler(event: Event): void {
			var urlLoader: URLLoader = URLLoader(event.target);
			data = urlLoader.data;
			completed.dispatch(this);
		}

		private function progressHandler(event: ProgressEvent): void {
			progress.dispatch(this, event.bytesLoaded / event.bytesTotal, event.bytesLoaded, event.bytesTotal);
		}
		
		public function dispose(): void {
			completed.removeAll();
			progress.removeAll();
			failed.removeAll();
			completed = null;
			progress = null;
			failed = null;
			data = null;
		}

		/**
		 * Checks type of TXT, IMAGE, MP3
		 * TODO: implement complicated type checking. 
		 */
		private function checkType(url: String): String {
			if(!url) return "";
			
			if(url.toLowerCase().indexOf(".mp3") != -1){
				type = "MP3";
			} else if (url.toLowerCase().indexOf(".jpg") != -1 ||
					   url.toLowerCase().indexOf(".png") != -1 ||
					   url.toLowerCase().indexOf(".gif") != -1){
				type = "IMAGE";
			} else if(url.toLowerCase().indexOf(".swf") != -1){
				type = "SWF";
			} else  {
				type = "TEXT";
			}
//			trace('type: ' + (type));
			return type;
		}
	}
}
