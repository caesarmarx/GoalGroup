package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class GetCheckVersionHttp extends GoalGroupHttpPost {
	
	private int error;
	private String datas;
	private String version;
	private String resultData;
	
	public GetCheckVersionHttp(String version) {
		super();
		this.version = version;
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "update_ver"));
		post_params.add(new BasicNameValuePair("oldVer", version));
		post_params.add(new BasicNameValuePair("dev_type", "1"));
	}

	@Override
	public boolean run() {
		try {
			postExecute();
			getResult();
			checkResult();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return true;
	}
	
	public boolean isSuccess() {
		return (error == GgHttpErrors.HTTP_POST_SUCCESS);
	}
	
	public String getResultData() {
		return resultData;
	}
	
	private void checkResult() {
		resultData = JSONUtil.getValue(result, "data");
		if (!StringUtil.isEmpty(resultData)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}		
		return;
	}
}
