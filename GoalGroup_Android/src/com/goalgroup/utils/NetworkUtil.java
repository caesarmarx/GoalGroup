package com.goalgroup.utils;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.widget.Toast;

import com.goalgroup.R;

public class NetworkUtil {
	
	public static boolean isNetworkAvailable(Context context) {  
        ConnectivityManager connMgr = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo[] info = connMgr.getAllNetworkInfo();
        
        boolean state = false;
        if (info != null) {        
	        for (int i = 0; i < info.length; i++) {  
	            if (info[i].getState() == NetworkInfo.State.CONNECTED) {
	                state = true;
	                break;
	            }
	        }
        }
        
        if (!state) {
        	Toast.makeText(context, context.getString(R.string.none_network), Toast.LENGTH_SHORT).show();
        }
        
        return state;  
    }	
}
