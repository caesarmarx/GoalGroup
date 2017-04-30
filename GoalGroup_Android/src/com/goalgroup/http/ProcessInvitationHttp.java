package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class ProcessInvitationHttp extends GoalGroupHttpPost {
	private int error;
	private String data;
	
	public ProcessInvitationHttp() {
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
		post_params.add(new BasicNameValuePair("cmd", "accept_inv_req"));
		post_params.add(new BasicNameValuePair("user_id", String.valueOf(params[0])));
		post_params.add(new BasicNameValuePair("club_id", String.valueOf(params[1])));
		post_params.add(new BasicNameValuePair("req_type", String.valueOf(params[2])));
	}
	
	private void checkResult() {
		data = JSONUtil.getValue(result, "data");
		if (!StringUtil.isEmpty(data)) 
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		return;
	}
	
	public String getData() {
		return data;
	}
	
	public int getError() {
		return error;
	}

}
