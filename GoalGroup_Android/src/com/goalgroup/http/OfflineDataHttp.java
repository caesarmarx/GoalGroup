package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;

public class OfflineDataHttp extends GoalGroupHttpPost {
	
	private int error;
	private String datas;
	
	public OfflineDataHttp() {
		super();		
		error =GgHttpErrors.GETOFFLINEDATA_ERROR;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "get_offline_data"));
		post_params.add(new BasicNameValuePair("last_updated_time", (String)params[0]));
	}

	@Override
	public boolean run() {
		TIME_OUT = 20000;
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
		error = JSONUtil.getValueInt(result, "state");
		datas=result;
		return;
	}
}
