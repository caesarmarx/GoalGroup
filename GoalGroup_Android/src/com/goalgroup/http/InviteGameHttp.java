package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class InviteGameHttp extends GoalGroupHttpPost {
	
	private int error;
	private int retCode;
	
	public InviteGameHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
		retCode = GgHttpErrors.INVITE_GAME_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "send_temp_req"));
		post_params.add(new BasicNameValuePair("user_id", (String)params[0]));
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
	
	public int getRetCode() {
		return retCode;
	}
	
	public int getError() {
		return error;
	}
	
	private void checkResult() {
		if (!StringUtil.isEmpty(result)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
			retCode = JSONUtil.getValueInt(result, "succeed");
		}
		
		return;
	}
}
