package com.goalgroup.login;

import android.content.Context;

import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;

public class GgLoginAgent {
	
	private Context ctx;
	private LoginThread thrdLogin;
	private LogoutThread thrdLogout;
	
	public GgLoginAgent(Context ctx) {
		this.ctx = ctx;
		thrdLogin = null;
		thrdLogout = null;
	}
	
	public void login(String id, String pwd) {
		if (!NetworkUtil.isNetworkAvailable(ctx))
			return;
		
		if (StringUtil.isEmpty(id) || StringUtil.isEmpty(pwd))
			return;
		
		if (thrdLogin != null)
			return;
		
		thrdLogin = new LoginThread(ctx, this, id, pwd);
		thrdLogin.start();
	}
	
	public void logout(int reason) {
		if (!NetworkUtil.isNetworkAvailable(ctx))
			return;
		
//		if (thrdLogout != null)
//			return;
		
		thrdLogout = new LogoutThread(ctx, this, reason);
		thrdLogout.start();
	}
	
	public void reset() {
		thrdLogin = null;
		thrdLogout = null;
	}
}
