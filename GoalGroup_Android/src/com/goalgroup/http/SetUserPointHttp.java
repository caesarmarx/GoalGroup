package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class SetUserPointHttp extends GoalGroupHttpPost {
	
	private int error;
	private int datas;
	
	public SetUserPointHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "set_user_point"));
		post_params.add(new BasicNameValuePair("game_id", String.valueOf(params[0])));
		post_params.add(new BasicNameValuePair("club_id", String.valueOf(params[1])));
		post_params.add(new BasicNameValuePair("user_id", (String)params[2]));
		post_params.add(new BasicNameValuePair("goal_point", (String)params[3]));
		post_params.add(new BasicNameValuePair("assist", (String)params[4]));
		post_params.add(new BasicNameValuePair("point", (String)params[5]));
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
	
	public int getData() {
		return datas;
	}
	
	public int getError() {
		return error;
	}
	
	private void checkResult() {
		datas = JSONUtil.getValueInt(result, "data");
		if (datas != GgHttpErrors.HTTP_POST_FAIL) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
		
		return;
	}
}
