package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class LeaveClubHttp extends GoalGroupHttpPost {
	
	private int error;
	private String datas;
	
	public LeaveClubHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "dismiss_club"));
		post_params.add(new BasicNameValuePair("user_id", GgApplication.getInstance().getUserId()));
		post_params.add(new BasicNameValuePair("club_id", (String)params[0]));
		post_params.add(new BasicNameValuePair("new_manager_id", ""));
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
		datas = JSONUtil.getValue(result, "succeed");
		if (!StringUtil.isEmpty(datas)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
		
		return;
	}
}
