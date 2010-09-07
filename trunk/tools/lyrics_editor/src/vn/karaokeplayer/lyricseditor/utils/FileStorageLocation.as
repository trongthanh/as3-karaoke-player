package vn.karaokeplayer.lyricseditor.utils {

	/**
	* Enumeration of default storage location.
	* @author Thanh Tran
	*/
	public class FileStorageLocation {
		
		/**
		 * User's home directory (read, write)
		 * 
		 * <p>
		 * on Windows: "C:\Documents and Settings\[userName]"<br/>
		 * on Mac OS: "Users/[userName]"
		 * </p>
		 */
		public static const USER_HOME_DIR:String = "home";
		
		/**
		 * User's documents directory (read, write)
		 * 
		 * <p>
		 * on Windows: "C:\Documents and Settings\[userName]\My Documents"<br/>
		 * on Mac OS: "Users/[userName]/Documents"
		 * </p>
		 */
		public static const USER_DOCS_DIR: String = "documents";
		
		/**
		 * User's desktop (read, write)
		 * 
		 * <p>on Windows, it is often: "C:\Documents and Settings\[userName]\Desktop" </p>
		 */
		public static const USER_DESKTOP: String = "desktop";
		
		/** 
		 * User-dependent application storage (read, write)
		 * 
		 * <p>
		 * on Windows: "C:\Documents and Settings\[userName]\Application Data\applicationID.publisherID\Local Store"<br/>
		 * on Mac OS: "/Users/[userName]/Library/Preferences/applicationID.publisherID/Local Store/"
		 * </p>
		 */
		public static const USER_APP_STORAGE: String = "storage";
		
		/** Application's installed directory (read-only) */
		public static const APP_DIR: String = "application";
		
		/** A little cheat for Windows XP and Mac OS users (with admin right) to be able to write in application's directory */
		public static const APP_DIR_WRITABLE: String = "appDirWritable";
		
		/** absolute path starting from the root of the file system */
		public static const ABSOLUTE_PATH: String = "absolute";
		
		/**
		 * This class is not for instantiation
		 */
		public function FileStorageLocation() {
			throw new Error("This class is not supposed to create instances");
		}
		
	}
	
}