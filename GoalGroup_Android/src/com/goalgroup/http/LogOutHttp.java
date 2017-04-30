package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class LogOutHttp extends GoalGroupHttpPost {
	
	private int error;
	private int datas;
	private String sysTime;
	
	public LogOutHttp() {
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
		post_params.add(new BasicNameValuePair("cmd", "user_logout"));
		post_params.add(new BasicNameValuePair("user_id", params[0].toString()));
	}
	
	private void checkResult()
	{
		datas = JSONUtil.getValueInt(result, "logout_status");
		sysTime = JSONUtil.getValue(result, "system_time");
		GgApplication.getInstance().getPrefUtil().setLastChatTime(sysTime);
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
