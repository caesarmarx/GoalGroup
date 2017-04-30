package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class UserRegisterHttp extends GoalGroupHttpPost {
	
	private int error;
	private String datas;
	
	public UserRegisterHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "user_register"));
		post_params.add(new BasicNameValuePair("Account_Num", (String)params[0]));
		post_params.add(new BasicNameValuePair("NickName", (String)params[1]));
		post_params.add(new BasicNameValuePair("Password", (String)params[2]));
		post_params.add(new BasicNameValuePair("IP_Addr", (String)params[3]));
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
		datas = JSONUtil.getValue(result, "register_status");
		if (datas == "1") {
			error = GgHttpErrors.USER_REGISTER_SUCCESS;
		} else if (datas == "0"){
			error = GgHttpErrors.USER_REGISTER_FAIL1;
		} else {
			error = GgHttpErrors.USER_REGISTER_FAIL2;
		}
		
		return;
	}
}
