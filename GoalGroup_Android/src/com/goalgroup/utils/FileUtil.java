package com.goalgroup.utils;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class FileUtil {
	
	public final static String FILE_PATH = "/data/data/com.goalgroup/files/";
	
	public static String getFullPath(String filename) {
		return FILE_PATH + filename;
	}
	
	public static void writeFile(String filename, byte[] buffer) {
		try {
			FileOutputStream fos = new FileOutputStream(filename);
			fos.write(buffer);
			fos.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
