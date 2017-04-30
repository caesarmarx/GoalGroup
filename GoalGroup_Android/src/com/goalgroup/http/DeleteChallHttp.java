package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class DeleteChallHttp extends GoalGroupHttpPost {
	
	private int error;
	private int datas;
	
	public DeleteChallHttp() {
		super();		
		error = GgHttpErrors.GET_CHALL_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "del_challenge"));
		post_params.add(new BasicNameValuePair("game_type", (String)params[0]));
		post_params.add(new BasicNameValuePair("club_id", (String)params[1]));
		post_params.add(new BasicNameValuePair("game_id", (String)params[2]));
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
		datas = JSONUtil.getValueInt(result, "del_status");
		if (datas != GgHttpErrors.HTTP_POST_FAIL) {
			error = GgHttpErrors.GET_CHALL_SUCCESS;
		}
		return;
	}
}
