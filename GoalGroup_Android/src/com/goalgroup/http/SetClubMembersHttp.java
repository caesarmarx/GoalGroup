package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;

public class SetClubMembersHttp extends GoalGroupHttpPost {
	
	private int error;

	public SetClubMembersHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "set_member_position"));
		post_params.add(new BasicNameValuePair("club_id", (String)params[0]));
		post_params.add(new BasicNameValuePair("manager_id", (String)params[1]));
		post_params.add(new BasicNameValuePair("captain_id", (String)params[2]));
		post_params.add(new BasicNameValuePair("user_id", (String)params[3]));
		post_params.add(new BasicNameValuePair("position", (String)params[4]));
		post_params.add(new BasicNameValuePair("del_user_id", (String)params[5]));
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
	
	public int getError() {
		return error;
	}
	
	private void checkResult() {
		int succeed = JSONUtil.getValueInt(result, "set_status");
		if (succeed == 1) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
		
		return;
	}
}
