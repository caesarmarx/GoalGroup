package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class GetReqListHttp extends GoalGroupHttpPost {
	
	private int error;
	private String data;
	private String more;
	
	public GetReqListHttp() {
		super();
		error = GgHttpErrors.HTTP_POST_FAIL;
	}

	@Override
	public boolean run() {
		try {
			postExecute();
			getResult();
			checkResult();
		} catch (Exception ex) {
			ex.printStackTrace();
			return false;
		}
		return true;
	}

	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "browse_reqmember_list"));
		post_params.add(new BasicNameValuePair("club_id", String.valueOf(params[0])));
		post_params.add(new BasicNameValuePair("page", String.valueOf(params[1])));
	}
	
	private void checkResult(){
		data = JSONUtil.getValue(result, "data");
		more = "0";
		if (!StringUtil.isEmpty(data)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
			more = JSONUtil.getValue(result, "more");
		}
	}
	
	public String getData() {
		return data;
	}
	
	public int getError() {
		return error;
	}
	
	public boolean hasMore() {
		if (StringUtil.isEmpty(more))
			return true;
		
		return "1".equals(more);
	}

}
