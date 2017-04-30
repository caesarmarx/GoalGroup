package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class GetChallInfoHttp extends GoalGroupHttpPost {

	private int error;
	private String datas;
	
	public GetChallInfoHttp() {
		super();
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "get_game_detail"));
		post_params.add(new BasicNameValuePair("game_id", String.valueOf(params[0])));
		post_params.add(new BasicNameValuePair("type", String.valueOf(params[1])));
	}
	
	@Override
	public boolean run() {
		// TODO Auto-generated method stub
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

	private void checkResult() {
		datas = JSONUtil.getValue(result, "data");
		if (!StringUtil.isEmpty(datas)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
		return;
	}
	
	public String getData() {
		return datas;
	}
	
	public int getError() {
		return error;
	}
}
