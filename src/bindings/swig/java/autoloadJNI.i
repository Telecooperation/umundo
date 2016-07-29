// automatically load the native library
// see http://tlrobinson.net/blog/2009/03/embedding-and-loading-a-jni-library-from-a-jar/
// see http://www.mkyong.com/java/how-to-detect-os-in-java-systemgetpropertyosname/

%pragma(java) jniclassimports=%{
import java.net.URL;
import java.util.zip.ZipFile;
import java.util.zip.ZipEntry;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.FileOutputStream;
import java.io.InputStream;
%}

%pragma(java) jniclasscode=%{

	static {
		String fullLibName = "";
		String osPrefix = "";
		String debugPrefix = "";
		String libName = "umundoNativeJava";
		String bitWidth = "";

		System.err.println("os.arch: " + System.getProperty("os.arch"));
		System.err.println("os.name: " + System.getProperty("os.name"));

		// is this a 64bit host?
		if (System.getProperty("os.arch").indexOf("64") > 0) {
			bitWidth = "64";
		}
		// do we want the debug build?
		if (System.getProperty("umundo.debug") != null) {
			debugPrefix = "_d";
			// just do not load any JNI code - we dropped it in 0.4.4
		} else {

			// dispatch os.type for filename
			String osSuffix = "";
			String os = System.getProperty("os.name").toLowerCase();
			if (os.indexOf("win") >= 0) {
				osSuffix = ".dll";
			} else if (os.indexOf("mac") >= 0) {
				osSuffix = ".jnilib";				
				osPrefix = "lib";				
			} else if(os.indexOf("nix") >= 0 || os.indexOf("nux") >= 0) {
				osSuffix = ".so";				
				osPrefix = "lib";				
			} else if(os.indexOf("sunos") >= 0) {
				throw new RuntimeException("Solaris not supported yet - ask me about it.");
			} else {
				throw new RuntimeException("Unknown platform " + os);
			}
			try {
				// get the class object for this class, and get the location of it
				final Class c = umundoNativeJavaJNI.class;
				final URL location = c.getProtectionDomain().getCodeSource().getLocation();

				// jars are just zip files, get the input stream for the lib
				ZipFile zf = new ZipFile(new File(location.toURI()));
				InputStream in = null;
				
				while(in == null) {
					fullLibName = osPrefix + libName + bitWidth + debugPrefix + osSuffix;
					System.out.println("Trying to load " + fullLibName);
					ZipEntry entry = zf.getEntry(fullLibName);
					if (entry == null) {
						System.out.println("File " + fullLibName + " not contained in " + location.toURI());
	  				if (debugPrefix.length() == 0) {
							debugPrefix = "_d";
							continue;
						} else {
							throw new FileNotFoundException(fullLibName);
						}
					}
					in = zf.getInputStream(entry);
				}

				// create a temp file and an input stream for it
				File f = File.createTempFile("JARLIB-", "-" + fullLibName);
				FileOutputStream out = new FileOutputStream(f);

				// copy the lib to the temp file
				byte[] buf = new byte[1024];
				int len;
				while ((len = in.read(buf)) > 0)
					out.write(buf, 0, len);
				in.close();
				out.close();

				// load the lib specified by its absolute path and delete it
				System.load(f.getAbsolutePath());
				f.delete();

			} catch (FileNotFoundException e) {
				System.err.println(e);
			} catch (Exception e) {
				System.err.println(e);
				System.err.println("Warning: failed to load native library " + fullLibName + " use System.load() yourself.");
			}
		}
	}
%}
