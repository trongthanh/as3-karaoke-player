/**
 * @author Phuc.Dam
 * @author Thanh Tran
 */
package vn.karaokeplayer.lyricseditor.utils {
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	/**
	 * Utility that facilitate reading and writing simple text/XML file.
	 * @see FileStorageLocation
	 */
	public class FileSystemUtil {
		
		/**
		 * This class is not for creating instances
		 */
		public function FileSystemUtil() {
			throw new Error("This class is not supposed to create instances");
		}
		
		/**
		 * Writes a string to a text file. This action is synchronous.
		 * @param	text			the text to be written
		 * @param	filePath		relative or absolute path to the file (if relative, a defaultStorage must be provided)
		 * @param	defaultStorage	enumeration of FileStorageLocation
		 * @param	append			to append the string at the end of the file; if append, the file must already exist
		 * @return notifies if write successfully
		 */
		public static function writeTextFile(text: String, filePath: String, defaultStorage: String = null, append: Boolean = false): Boolean {
			var stream:FileStream = new FileStream();
			var fileMode: String = (append == true)? FileMode.APPEND : FileMode.WRITE;
			var ok: Boolean = false;
			try {
				stream.open(getFileFromPath(filePath, defaultStorage), fileMode);
				stream.writeUTFBytes(text);
				stream.close();
				ok = true;
			} catch (e: Error) {
				trace("Write file error: " + e.name + ": " + e.message);
			}
			return ok;
		}
		
		/**
		 * Reads a text file and returns the string content. This action is synchronous.
		 * @param	filePath		relative or absolute path to the file (if relative, a defaultStorage must be provided)
		 * @param	defaultStorage	enumeration of FileStorageLocation
		 * @return	string content of the text file (null if read error)
		 */
		public static function readTextFile(filePath: String, defaultStorage: String = null): String {
			var stream:FileStream = new FileStream();
			var str: String;
			try {
				stream.open(getFileFromPath(filePath, defaultStorage), FileMode.READ);
				str = stream.readUTFBytes(stream.bytesAvailable);
				stream.close();
			} catch (e:Error){
				trace("Read file error: " + e.message);
			}
			return str;
		}		
		
		/**
		 * Writes the XML's string to a file. This action is synchronous.
		 * @param	xml				the XML to be written
		 * @param	filePath		relative or absolute path to the file (if relative, a defaultStorage must be provided)
		 * @param	defaultStorage	enumeration of FileStorageLocation
		 * @return notifies if write successfully
		 */
		public static function writeXML(xml:XML, filePath:String, defaultStorage: String = null): Boolean {
			var xmlStr: String = xml.toXMLString();
			var ok: Boolean = writeTextFile(xmlStr, filePath, defaultStorage, false);
			return ok;
		}
		
		/**
		 * Reads an .xml file and return an XML (E4X) object. This action is synchronous.
		 * 
		 * <p>If the file's content cannot be parsed into valid XML, a 'null' will be returned.</p>
		 * 
		 * @param	filePath		relative or absolute path to the file (if relative, a defaultStorage must be provided)
		 * @param	defaultStorage	enumeration of FileStorageLocation
		 * @return	a parsed XML
		 */
		public static function readXML(filePath:String, defaultStorage: String = null):XML {
			var xmlStr: String = readTextFile(filePath, defaultStorage);
			
			XML.ignoreWhitespace = true;
			XML.ignoreProcessingInstructions = true;
			var xml: XML;
			try {
				trace("xmlStr: " + xmlStr);
				xml = new XML(xmlStr);
				
				if(xml.nodeKind() != "element")
				{
					//this is only a text file, invalid XML!
					xml = null;
				}
			} catch (e: Error) {
				trace("Invalid XML. " + e.message);
			}
			return xml;
		}
		
		/**
		 * @param	filePath
		 * @param	defaultStorage
		 * @return
		 */
		private static function getFileFromPath(filePath:String, defaultStorage: String = null):File {
			var file:File = null;
			if (defaultStorage == null) defaultStorage = "";
			switch (defaultStorage) {
				case FileStorageLocation.USER_HOME_DIR:
					file = File.userDirectory.resolvePath(filePath);
					break;
				case FileStorageLocation.USER_DOCS_DIR:
					file = File.documentsDirectory.resolvePath(filePath);
					break;
				case FileStorageLocation.USER_APP_STORAGE:
					file = File.applicationStorageDirectory.resolvePath(filePath);
					break;
				case FileStorageLocation.USER_DESKTOP:
					file = File.desktopDirectory.resolvePath(filePath);
					break;
				case FileStorageLocation.APP_DIR:
					file = File.applicationDirectory.resolvePath(filePath);
					break;
				case FileStorageLocation.APP_DIR_WRITABLE:
					//to avoid read-only, use the absolute path of the installed folder after resolving it
					var tempFile: File = File.applicationDirectory.resolvePath(filePath);
					file = new File(tempFile.nativePath);
					break;
				default:
					file = new File();
					file.url = filePath;
			}
			return file;
		}
	}
}



