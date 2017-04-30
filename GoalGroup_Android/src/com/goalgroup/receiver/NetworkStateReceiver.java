package com.goalgroup.receiver;

import com.goalgroup.GgApplication;
import com.goalgroup.constants.CommonConsts;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

public class NetworkStateReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent) {
		GgApplication.getInstance().getLoginAgent().logout(CommonConsts.LOGOUT_REASON_NETWORK);
		
		ConnectivityManager cm = (ConnectivityManager)context.getSystemService(Context.CONNECTIVITY_SERVICE);
    	NetworkInfo ni = cm.getActiveNetworkInfo();
    	
    	if (ni == null)
    		return;
    	
    	String id = GgApplication.getInstance().getUserId();
    	String pwd = GgApplication.getInstance().getUserPwd();
    	GgApplication.getInstance().getLoginAgent().login(id, pwd);
	}

}
