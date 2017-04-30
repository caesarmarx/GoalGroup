package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class RegisterUserToClubHttp extends GoalGroupHttpPost {

	private int error;
	private int datas;
	
	public RegisterUserToClubHttp() {
		super();
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		// TODO Auto-generated method stub
		post_params.add(new BasicNameValuePair("cmd", "register_user_to_club"));
		post_params.add(new BasicNameValuePair("user_id", (String)params[0]));
		post_params.add(new BasicNameValuePair("club_id", (String)params[1]));
	}
	
	@Override
	public boolean run() {
		// TODO Auto-generated method stub
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

	private void checkResult() {
		datas = JSONUtil.getValueInt(result, "succeed");
		if (!StringUtil.isEmpty(String.valueOf(datas))) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
		return;
	}
	
	public int getData() {
		return datas;
	}
	
	public int getError() {
		return error;
	}
}
