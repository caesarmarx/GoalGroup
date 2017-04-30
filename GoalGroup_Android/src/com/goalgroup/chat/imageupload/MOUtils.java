package com.goalgroup.chat.imageupload;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.json.JSONArray;
import org.json.JSONObject;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.BitmapFactory.Options;
import android.graphics.drawable.BitmapDrawable;
import android.os.Environment;
import android.util.Log;
import android.view.Gravity;

public class MOUtils {

//	public static PropertyItem	curProperty;
	
//	public static void copyVideoFile(Context context) {
//		if(!new File("/sdcard/Mandarin/").exists())
//			new File("/sdcard/Mandarin/").mkdirs();
//
//		File dbFile = new File(MOConstants.VIDEO_PATH);
//		if(dbFile.exists())
//			return;
//
//		try {
//			InputStream in = context.getResources().getAssets().open("mohg_ding_iphone_ret.mp4");
//			BufferedInputStream bis = new BufferedInputStream(in);
//			FileOutputStream fos = new FileOutputStream(dbFile);
//			BufferedOutputStream bos = new BufferedOutputStream(fos);
//
//			int len = 0;
//			byte[] buf = new byte[4096];
//			while ((len = bis.read(buf)) != -1)
//			{
//				bos.write(buf, 0, len);
//			}
//
//			bos.close();
//			bis.close();
//			fos.close();
//			in.close();
//		}
//		catch (Exception e) {
//			// TODO: handle exception
//			e.printStackTrace();
//		}
//	}

	public static void DeleteRecursive(File dir)
	{
		Log.d("DeleteRecursive", "DELETEPREVIOUS TOP" + dir.getPath());
		if (dir.isDirectory())
		{
			String[] children = dir.list();
			for (int i = 0; i < children.length; i++) 
			{
				File temp =  new File(dir, children[i]);
				if(temp.isDirectory())
				{
					Log.d("DeleteRecursive", "Recursive Call" + temp.getPath());
					DeleteRecursive(temp);
				}
				else
				{
					Log.d("DeleteRecursive", "Delete File" + temp.getPath());
					boolean b = temp.delete();
					if(b == false)
					{
						Log.d("DeleteRecursive", "DELETE FAIL");
					}
				}
			}

			dir.delete();
		}
	}

	/*************************************************************************************
	 * IO FUNCTIONS
	 ************************************************************************************/
	// File IO function
	public static String getFilePath(Context context, String path) {
		String fullPath;
		String state;

		String packageName = context.getApplicationContext().getPackageName();

		state = Environment.getExternalStorageState(); 
		if (state.equals(Environment.MEDIA_MOUNTED)) {
			fullPath = Environment.getExternalStorageDirectory().getAbsolutePath();
			fullPath += "/" + packageName + "/" + path;
		}
		else {
			fullPath = "/data/data/" + packageName + "/" + path;
		}

		return fullPath;
	}

//	public static String getResourcePath(Context context, MOCacheableResourceType resType, String resName) {
//		String resPath = null;
//
//		switch (resType) {
//		case MO_CACHEABLE_RESOURCE_IMAGE:
//			resPath = MOConstants.RES_IMAGE_FOLDER + resName;
//			break;
//		default:
//			Assert.assertTrue("Not supported cache type" != null);
//		}
//
//		resPath = getFilePath(context, resPath);
//		return resPath;
//	}

	/**
	 * Ensure directory existing
	 * @param activity
	 * @param path
	 */
	public static void ensureDir(Context context, String path) {
		boolean result;

		path = getFilePath(context, path);

		File file = new File(path);
		if (!file.exists()) {
			result = file.mkdirs();
			if (result == false) {
				Log.e("Storage Error", "There is no storage to cache app data");
			}
		}
	}

	public static String convertStreamToString(InputStream is) {
		/*
		 * To convert the InputStream to String we use the
		 * BufferedReader.readLine() method. We iterate until the BufferedReader
		 * return null which means there's no more data to read. Each line will
		 * appended to a StringBuilder and returned as String.
		 */
		BufferedReader reader = new BufferedReader(new InputStreamReader(is));
		StringBuilder sb = new StringBuilder();

		String line = null;
		try {
			while ((line = reader.readLine()) != null) {
				sb.append(line);
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				is.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return sb.toString();
	}

	public static String getJSONStringValue(JSONObject LObject, String name, String defaultValue) {
		try {
			return LObject.getString(name);
		} catch (Exception e) {
			return defaultValue;
		}
	}

	public static int getJSONIntValue(JSONObject LObject, String name, int defaultValue) {
		try {
			return LObject.getInt(name);
		} catch (Exception e) {
			return defaultValue;
		}
	}

	public static double getJSONDoubleValue(JSONObject LObject, String name, double defaultValue) {
		try {
			return LObject.getDouble(name);
		} catch (Exception e) {
			return defaultValue;
		}
	}

	public static String jsonArrayValues(JSONArray Jarray, int i) {
		try {
			return (String) Jarray.get(i);
		} catch (Exception e) {
			return "";
		}
	}

	public static String escapeStirng(String str)
	{
		if (str == null)
			return "";
		return str.replace("'", "''");
	}

//	public static Boolean initDatabase(Context context) {
//		if(!new File("/sdcard/Mandarin/").exists())
//			new File("/sdcard/Mandarin/").mkdirs();
//
//		DatabaseHandler dbHandler = new DatabaseHandler(context);
//		dbHandler.openDatabase();
//
//		MainHomeActivity.instance.mDBHandler = dbHandler;
//
//		String strQuery;
//
//		strQuery = "begin";
//
//		dbHandler.executeSQL(strQuery);
//
//		strQuery = "CREATE TABLE IF NOT EXISTS " + MOConstants.TABLE_PROPERTIES 
//				+ " ("
//				+ MOConstants.COL_PROPERTY_ID +" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " 
//				+ MOConstants.COL_ID + " int, " 
//				+ MOConstants.COL_NAME + " text, "
//				+ MOConstants.COL_CITY + " text, "
//				+ MOConstants.COL_LINE1 + " text, "
//				+ MOConstants.COL_CONTIENT + " text, "
//				+ MOConstants.COL_PROVINCE + " text, "
//				+ MOConstants.COL_LINE2 + " text, "
//				+ MOConstants.COL_LATITUDE + " double, "
//				+ MOConstants.COL_COUNTRY + " text, "
//				+ MOConstants.COL_PHONE_NUMBER_USE + " text, "
//				+ MOConstants.COL_SECONDARY_NAME + " text, "
//				+ MOConstants.COL_POSTAL_CODE + " text, "
//				+ MOConstants.COL_RES_SYSTEM_HOTEL_ID + " int, "
//				+ MOConstants.COL_SHORT_DESCRIPTION + " text, "
//				+ MOConstants.COL_ALTITUDE + " double, "
//				+ MOConstants.COL_LONG_DESCRIPTION + " text, "
//				+ MOConstants.COL_PHONE_NUMBER + " text, "
//				+ MOConstants.COL_LONGITUDE + " double, "
//				+ MOConstants.COL_RESERVATIONS_EMAIL + " text, "
//				+ MOConstants.COL_TRAVEL_GUIDE_CITY_CODE + " text, "
//				+ MOConstants.COL_LOCAL_NAV_IMAGE + " text, "
//				+ MOConstants.COL_MO_CITIES_MEDIA_IMAGE + " text, "
//				+ MOConstants.COL_PROPERTY_LOGO_IMAGE + " text, "
//				+ MOConstants.COL_NODE_ID + " int, "
//				+ MOConstants.COL_DETAIL_URL + " text"
//				+ ")";
//
//		if (dbHandler.executeSQL(strQuery) != 0) {
//			dbHandler.executeSQL("rollback");
//			return false;
//		}
//
//		strQuery = "CREATE TABLE IF NOT EXISTS " + MOConstants.TABLE_PAYMENT_TYPE 
//				+ " ("
//				+ MOConstants.COL_PAYMENT_TYPE_ID +" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " 
//				+ MOConstants.COL_ID + " int, " 
//				+ MOConstants.COL_NAME + " text, "
//				+ "UNIQUE(" + MOConstants.COL_ID + ", " + MOConstants.COL_NAME + ")"
//				+ ")";
//
//		if (dbHandler.executeSQL(strQuery) != 0) {
//			dbHandler.executeSQL("rollback");
//			return false;
//		}
//
//		strQuery = "CREATE TABLE IF NOT EXISTS " + MOConstants.TABLE_ACCEPTED_PAYMENT_TYPE 
//				+ " ("
//				+ MOConstants.COL_ID +" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " 
//				+ MOConstants.COL_PROPERTY_ID + " int, " 
//				+ MOConstants.COL_PAYMENT_TYPE_ID + " int, "
//				+ "UNIQUE(" + MOConstants.COL_PAYMENT_TYPE_ID + ", " + MOConstants.COL_PROPERTY_ID + ")"
//				+ ")";
//
//		if (dbHandler.executeSQL(strQuery) != 0) {
//			dbHandler.executeSQL("rollback");
//			return false;
//		}
//
//		strQuery = "CREATE TABLE IF NOT EXISTS " + MOConstants.TABLE_ROOMS
//				+ " ("
//				+ MOConstants.COL_ROOM_ID +" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " 
//				+ MOConstants.COL_ID + " int, " 
//				+ MOConstants.COL_NAME + " text, "
//				+ MOConstants.COL_LONG_DESCRIPTION + " text, "
//				+ MOConstants.COL_MAX_OCCUPANCY + " int, "
//				+ MOConstants.COL_MAX_ROLLAWAYS + " int, "
//				+ MOConstants.COL_NUM_BEDS + " int, "
//				+ MOConstants.COL_ROOM_SECONDARY_NAME + " text, "
//				+ MOConstants.COL_SHORT_DESCRIPTION + " text, "
//				+ MOConstants.COL_SQUARE_FOOTAGE + " text, "
//				+ MOConstants.COL_SQUARE_METERS + " text, "
//				+ MOConstants.COL_VIEW + " text, "
//				+ MOConstants.COL_PROPERTY_ID + " int"
//				+ " )";
//
//		if (dbHandler.executeSQL(strQuery) != 0) {
//			dbHandler.executeSQL("rollback");
//			return false;
//		}
//
//		strQuery = "CREATE TABLE IF NOT EXISTS " + MOConstants.TABLE_BEDDING_TYPE
//				+ " ("
//				+ MOConstants.COL_BEDDING_TYPE_ID +" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " 
//				+ MOConstants.COL_ID + " int, " 
//				+ MOConstants.COL_NAME + " text, "
//				+ MOConstants.COL_ROOM_ID + " int" 
//				+ " )";
//
//		if (dbHandler.executeSQL(strQuery) != 0) {
//			dbHandler.executeSQL("rollback");
//			return false;
//		}
//
//		strQuery = "CREATE TABLE IF NOT EXISTS " + MOConstants.TABLE_PROPERTY_PHOTOES
//				+ " ("
//				+ MOConstants.COL_PHOTO_ID +" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " 
//				+ MOConstants.URL + " text, "
//				+ MOConstants.THUMBNAIL_URL + " text, "
//				+ MOConstants.COL_ID + " text, "
//				+ MOConstants.KIND + " text, "
//				+ MOConstants.UPDATED_AT + " text, "
//				+ MOConstants.COL_PROPERTY_ID + " int, "
//				+ MOConstants.COL_ROOM_ID + " int, "
//				+ ("unique(") + MOConstants.COL_ID + ")"
//				+ " )";
//
//		if (dbHandler.executeSQL(strQuery) != 0) {
//			dbHandler.executeSQL("rollback");
//			return false;
//		}
//		
//		strQuery = "CREATE TABLE IF NOT EXISTS " + MOConstants.TABLE_ROOM_PREVIEW_PHOTOES
//				+ " ("
//				+ MOConstants.COL_PHOTO_ID +" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " 
//				+ MOConstants.URL + " text, "
//				+ MOConstants.THUMBNAIL_URL + " text, "
//				+ MOConstants.COL_ID + " text, "
//				+ MOConstants.KIND + " text, "
//				+ MOConstants.UPDATED_AT + " text, "
//				+ MOConstants.COL_PROPERTY_ID + " int, "
//				+ MOConstants.COL_ROOM_ID + " int, "
//				+ ("unique(") + MOConstants.COL_ID + ")"
//				+ " )";
//
//		if (dbHandler.executeSQL(strQuery) != 0) {
//			dbHandler.executeSQL("rollback");
//			return false;
//		}
//		
//		strQuery = "CREATE TABLE IF NOT EXISTS " + MOConstants.TABLE_ROOM_PHOTOES
//				+ " ("
//				+ MOConstants.COL_PHOTO_ID +" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " 
//				+ MOConstants.URL + " text, "
//				+ MOConstants.THUMBNAIL_URL + " text, "
//				+ MOConstants.COL_ID + " text, "
//				+ MOConstants.KIND + " text, "
//				+ MOConstants.UPDATED_AT + " text, "
//				+ MOConstants.COL_PROPERTY_ID + " int, "
//				+ MOConstants.COL_ROOM_ID + " int, "
//				+ ("unique(") + MOConstants.COL_ID + ")"
//				+ " )";
//
//		if (dbHandler.executeSQL(strQuery) != 0) {
//			dbHandler.executeSQL("rollback");
//			return false;
//		}
//
//		dbHandler.executeSQL("commit");
//
//		return true;
//	}

	public static Options getBitmapInfo(String pathName) {
		Options options = new Options();

		options.inJustDecodeBounds = true;
		options.outWidth = 0;
		options.outHeight = 0;
		options.inSampleSize = 1;

		BitmapFactory.decodeFile(pathName, options);

		return options;
	}

	public static Bitmap makeThumb(String pathName, int iWidth, int iHeight) {
		Options options;

		try {
			if((new File(pathName)).exists())
				options = getBitmapInfo(pathName);
			else
				return null;

			if (options.outWidth > 0 && options.outHeight > 0) {
				// Now see how much we need to scale it down.
				int widthFactor = (options.outWidth + iWidth - 1) / iWidth;
				int heightFactor = (options.outHeight + iHeight - 1) / iHeight;

				widthFactor = Math.min(widthFactor, heightFactor);
				//				widthFactor = Math.min(widthFactor, 1);

				// Now turn it into a power of two.
				if (widthFactor > 1) {
					if ((widthFactor & (widthFactor - 1)) != 0) {
						while ((widthFactor & (widthFactor - 1)) != 0) {
							widthFactor &= widthFactor - 1;
						}

						widthFactor <<= 1;
					}
				}
				options.inSampleSize = widthFactor;
				options.inJustDecodeBounds = false;
				Bitmap imageBitmap = BitmapFactory
						.decodeFile(pathName, options);
				BitmapDrawable drawable = new BitmapDrawable(imageBitmap);
				if(iHeight < iWidth)
					drawable.setGravity(Gravity.FILL_HORIZONTAL);
				else
					drawable.setGravity(Gravity.FILL_VERTICAL);

				drawable.setBounds(0, 0, iWidth, iHeight);
				return drawable.getBitmap();
			}
		} catch (java.lang.OutOfMemoryError e) {
			Log.e("utils", e.getMessage());
		}

		return null;
	}
}
