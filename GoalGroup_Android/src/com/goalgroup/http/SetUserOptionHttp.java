package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;

public class SetUserOptionHttp extends GoalGroupHttpPost {
	int error;
	int data;
	
	public SetUserOptionHttp() {
		super();
		error = GgHttpErrors.HTTP_POST_FAIL;
	}

	@Override
	public boolean run() {
		try{
			postExecute();
			getResult();
			checkResult();			
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}

	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "set_user_option"));
		post_params.add(new BasicNameValuePair("user_id", GgApplication.getInstance().getUserId()));
		post_params.add(new BasicNameValuePair("option", String.valueOf(params[0])));
	}
	
	public int getData() {
		return data;
	}
	
	public int getError() {
		return error;
	}

	private void checkResult() {
		data = JSONUtil.getValueInt(result, "succeed");
		if (data != GgHttpErrors.HTTP_POST_FAIL)
			error = GgHttpErrors.HTTP_POST_SUCCESS;
	}
}
