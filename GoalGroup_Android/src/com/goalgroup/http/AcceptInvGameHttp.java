package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class AcceptInvGameHttp extends GoalGroupHttpPost {
	
	private int error;
	private int successed;
	private String data;
	
	public AcceptInvGameHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
		successed = 0;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "accept_temp_req"));
		post_params.add(new BasicNameValuePair("user_id", GgApplication.getInstance().getUserId()));
		post_params.add(new BasicNameValuePair("club_id", (String)params[0]));
		post_params.add(new BasicNameValuePair("game_id", (String)params[1]));
		post_params.add(new BasicNameValuePair("req_type", (String)params[2]));
	}

	@Override
	public boolean run() {
		try {
			postExecute();			
			getResult();
			checkResult();
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		
		return true;
	}
	
	public int isSuccess() {
		return successed;
	}
	
	public int getError() {
		return error;
	}
	
	private void checkResult() {
		successed = JSONUtil.getValueInt(result, "succeed");
		if (successed == 1) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
			data = JSONUtil.getValue(result, "data");
		}
		return;
	}
	
	public String getData() {
		return data;
	}
}
