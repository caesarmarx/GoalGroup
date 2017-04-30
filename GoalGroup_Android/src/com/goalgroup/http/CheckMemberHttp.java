package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class CheckMemberHttp extends GoalGroupHttpPost {
	
	private int error;
	private int datas;
	
	public CheckMemberHttp() {
		super();
		error = GgHttpErrors.HTTP_POST_FAIL;
	}

	@Override
	public boolean run() {
		try {
			postExecute();
			getResult();
			checkResult();
		} catch(Exception e) {
			e.printStackTrace();
			return false;
		}
		
		return true;
	}

	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "check_member"));
		post_params.add(new BasicNameValuePair("user_id", params[0].toString()));
		post_params.add(new BasicNameValuePair("club_id", params[1].toString()));
	}
	
	private void checkResult()
	{
		datas = JSONUtil.getValueInt(result, "status");
		if (!StringUtil.isEmpty(String.valueOf(datas)))
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		return;
	}
	
	public int getData() {
		return datas;
	}
	
	public int getError() {
		return error;
	}

}
