package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class GetUserIDHttp extends GoalGroupHttpPost {
	
	private int error;
	private String datas;
	
	public GetUserIDHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		
		post_params.add(new BasicNameValuePair("cmd", "get_user_id"));
		post_params.add(new BasicNameValuePair("user_name", (String)params[0]));
		
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
	
	public String getData() {
		return datas;
	}
	
	public int getError() {
		return error;
	}
	
	private void checkResult() {
		datas = JSONUtil.getValue(result, "user_id");
		if (!StringUtil.isEmpty(datas)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
		
		return;
	}
}
