package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;

public class SendInvReqHttp extends GoalGroupHttpPost {
	private int error;
	private int data;
	
	public SendInvReqHttp() {
		super();
		this.error = GgHttpErrors.HTTP_POST_FAIL;
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
		post_params.add(new BasicNameValuePair("cmd", "send_inv_request"));
		post_params.add(new BasicNameValuePair("club_id", (String)params[0]));
		post_params.add(new BasicNameValuePair("user_id", String.valueOf(params[1])));
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
		return;
	}
}
