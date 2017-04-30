package com.goalgroup.login;

import com.goalgroup.GgApplication;
import com.goalgroup.chat.component.ChatEngine;
import com.goalgroup.common.GgBroadCast;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.http.LogOutHttp;

import android.content.Context;
import android.content.Intent;

public class LogoutThread extends Thread {
	
	private Context ctx;
	private GgLoginAgent agent;
	private String id;
	private int reason;
	
	public LogoutThread(Context ctx, GgLoginAgent agent, int reason) {
		this.ctx = ctx;
		this.agent = agent;
		this.id = GgApplication.getInstance().getUserId();
		this.reason = reason;
	}
	
	public void run() {
		logout();
		agent.reset();
	}
	
	private void logout() {
		LogOutHttp post = new LogOutHttp();
		post.setParams(id);
		post.run();
		
		ChatEngine chatEngine = GgApplication.getInstance().getChatEngine();	
		if(chatEngine != null)
			chatEngine.disconnect();
		
		int error = post.getError();
		
		GgBroadCast caster = GgApplication.getInstance().getBroadCaster();
		Intent param = caster.getIntent();
		param.putExtra(CommonConsts.LOGOUT_ERROR, error);
		param.putExtra(CommonConsts.LOGOUT_REASON, reason);
		caster.send(GgBroadCast.MSG_LOGOUT_RESULT);
	}
}
