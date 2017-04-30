package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;

public class AddBBSHttp extends GoalGroupHttpPost {
	
	private int error;
	private int datas;
	
	public AddBBSHttp() {
		super();
		error = GgHttpErrors.HTTP_POST_FAIL;
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

	@Override
	public void setParams(Object... params) {
		int count = Integer.valueOf(params[1].toString());
		post_params.add(new BasicNameValuePair("cmd", "create_discuss"));
		post_params.add(new BasicNameValuePair("user_id", (String)params[0]));
		post_params.add(new BasicNameValuePair("count", String.valueOf(params[1])));
		for (int i = 0; i < count; i ++) {
			post_params.add(new BasicNameValuePair("img_"+String.valueOf(i+1), (String)params[(i+1)*2]));
			post_params.add(new BasicNameValuePair("content_"+String.valueOf(i+1), (String)params[(i+1)*2+1]));
		}
		post_params.add(new BasicNameValuePair("type", String.valueOf(params[2 + 2 * count])));
	}
	
	public int getData() {
		return datas;
	}
	
	public int getError() {
		return error;
	}
	
	private void checkResult() {
		datas = JSONUtil.getValueInt(result, "create_discuss_status");
		if (datas == 1) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
		
		return;
	}

}
