package com.goalgroup.http;

import net.arnx.jsonic.JSON;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class SendReportHttp extends GoalGroupHttpPost {
	private int error;
	private int data;
	
	public SendReportHttp() {
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
		post_params.add(new BasicNameValuePair("cmd", "advise_opinion"));
		post_params.add(new BasicNameValuePair("user_id", String.valueOf(params[0])));
		post_params.add(new BasicNameValuePair("content", (String)params[1]));
	}
	
	private void checkResult() {
		data = JSONUtil.getValueInt(result, "advise_status");
		if (data != GgHttpErrors.HTTP_POST_FAIL) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
	}
	
	public int getData() {
		return data;
	}
	
	public int getError() {
		return error;
	}
}
