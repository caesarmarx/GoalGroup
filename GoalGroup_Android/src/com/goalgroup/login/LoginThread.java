package com.goalgroup.login;

import java.util.Set;

import android.content.Context;
import android.content.Intent;

import cn.jpush.android.api.JPushInterface;
import cn.jpush.android.api.TagAliasCallback;

import com.goalgroup.GgApplication;
import com.goalgroup.chat.component.ChatEngine;
import com.goalgroup.common.GgBroadCast;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.http.LoginHttp;

public class LoginThread extends Thread {
	
	private Context ctx;
	private GgLoginAgent agent;
	private String id;
	private String pwd;
	
	public LoginThread(Context ctx, GgLoginAgent agent, String id, String pwd) {
		this.ctx = ctx;
		this.agent = agent;
		this.id = id;
		this.pwd = pwd;
	}
	
	public void run() {
		login();
		agent.reset();
	}
	
	private void login() {
		LoginHttp post = new LoginHttp();
		post.setParams(id, pwd);
		post.run();
		
		int error = post.getLoginError();
		if (error == GgHttpErrors.LOGIN_SUCCESS) {			
			ChatEngine chatEngine = GgApplication.getInstance().getChatEngine();
			
			chatEngine.createSocketIOManager();
			chatEngine.netConnect();
			
			JPushInterface.setAliasAndTags(ctx, (String)id, null, mAliasCallback);
		}
		
		GgBroadCast caster = GgApplication.getInstance().getBroadCaster();
		Intent param = caster.getIntent();
		param.putExtra(CommonConsts.LOGIN_ERROR, error);
		caster.send(GgBroadCast.MSG_LOGIN_RESULT);
	}
	
	private final TagAliasCallback mAliasCallback = new TagAliasCallback() {

        @Override
        public void gotResult(int code, String alias, Set<String> tags) {
        }
	    
	};
}
