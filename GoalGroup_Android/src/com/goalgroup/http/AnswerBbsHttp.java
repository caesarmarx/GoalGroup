package com.goalgroup.http;

import net.arnx.jsonic.JSON;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class AnswerBbsHttp extends GoalGroupHttpPost {
	private int error;
	private String data;
	
	public AnswerBbsHttp() {
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
		post_params.add(new BasicNameValuePair("cmd", "eval_discuss"));
		post_params.add(new BasicNameValuePair("user_id", (String)params[0]));
		post_params.add(new BasicNameValuePair("content", (String)params[1]));
		post_params.add(new BasicNameValuePair("reply_src", String.valueOf(params[2])));
		post_params.add(new BasicNameValuePair("reply_type", String.valueOf(params[3])));
	}
	
	private void checkResult() {
		data = JSONUtil.getValue(result, "data");
		if (!StringUtil.isEmpty(data)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
	}
	
	public String getData() {
		return data;
	}
	
	public int getError() {
		return error;
	}
}
