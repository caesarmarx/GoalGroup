package com.goalgroup.utils;

import com.goalgroup.R;

import android.content.Context;
import android.os.Environment;
import android.widget.Toast;

public class StorageUtil {
	
	public static boolean isMountedStorage(Context ctx) {
		if (!Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState())) {
			Toast.makeText(ctx, ctx.getString(R.string.error_storage_mounted), Toast.LENGTH_SHORT).show();
			return false;
		}
		
		return true;
	}

}
