package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class EditUserProfileHttp extends GoalGroupHttpPost {
	private int error;
	private int datas;
	
	public EditUserProfileHttp() {
		super();
		error = GgHttpErrors.HTTP_POST_FAIL;
	}

	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "edit_user_profile"));
		post_params.add(new BasicNameValuePair("OldNick", (String)params[0]));
		post_params.add(new BasicNameValuePair("NewNick", (String)params[1]));
		post_params.add(new BasicNameValuePair("Photo_URL", (String)params[2]));
		post_params.add(new BasicNameValuePair("Sex", (String)params[3]));
		post_params.add(new BasicNameValuePair("Birthday", (String)params[4]));
		post_params.add(new BasicNameValuePair("Height", (String)params[5]));
		post_params.add(new BasicNameValuePair("Weight", (String)params[6]));
		post_params.add(new BasicNameValuePair("Term", (String)params[7]));
		post_params.add(new BasicNameValuePair("City", (String)params[8]));
		post_params.add(new BasicNameValuePair("Position", (String)params[9]));
		post_params.add(new BasicNameValuePair("ActivityArea", (String)params[10]));
		post_params.add(new BasicNameValuePair("ActivityTime", (String)params[11]));
		post_params.add(new BasicNameValuePair("user_id", (String)GgApplication.getInstance().getUserId()));
	}

	@Override
	public boolean run() {
		try{
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
		datas = JSONUtil.getValueInt(result, "edit_profile_status");
		if (datas != GgHttpErrors.HTTP_POST_FAIL) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
		return;
	}
}
