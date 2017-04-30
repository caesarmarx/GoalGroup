package com.goalgroup.utils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class JSONUtil {
	
	public static String getValue(String src, String key) {
		String ret = "";
		
		try {
			if (!StringUtil.isEmpty(src)) {
				JSONObject json = new JSONObject(src);
				ret = json.getString(key);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return ret;
	}
	
	public static int getValueInt(String src, String key) {
		int ret = -1;
		
		try {
			if (!StringUtil.isEmpty(src)) {
				JSONObject json = new JSONObject(src);
				ret = json.getInt(key);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return ret;
	}
	
	public static String[] getArrays(String src, String key) {
		String[] ret = new String[0];
		try {
			JSONObject json = new JSONObject(src);
			JSONArray arrays = json.getJSONArray(key);
			
			int count = arrays.length();
			if (count != 0)
				ret = new String[count];
			
			for (int i = 0; i < count; i++) {
				ret[i] = arrays.getString(i);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return ret;
	}
}
