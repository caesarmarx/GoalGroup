package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;

public class ProcessReqHttp extends GoalGroupHttpPost {
	private int error;
	private int data;

	public ProcessReqHttp() {
		super();
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	@Override
	public boolean run() {
		try {
			postExecute();
			getResult();
			checkResult();
		} catch (Exception ex) {
			ex.printStackTrace();
			return false;
		}
		return true;
	}

	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "accept_request"));
		post_params.add(new BasicNameValuePair("user_id", String.valueOf(params[0])));
		post_params.add(new BasicNameValuePair("club_id", String.valueOf(params[1])));
		post_params.add(new BasicNameValuePair("req_type", String.valueOf(params[2])));
	}
	
	public int getData() {
		return data;
	}
	
	public int getError() {
		return error;
	}
	
	private void checkResult() {
		data = JSONUtil.getValueInt(result, "succeed");
		if (data == GgHttpErrors.HTTP_POST_SUCCESS) 
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		return;
	}

}
