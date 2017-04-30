package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class GetBbsListHttp extends GoalGroupHttpPost {
	
	private int error;
	private String datas;
	private String more;
	
	public GetBbsListHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "browse_discuss_list"));
		post_params.add(new BasicNameValuePair("page", (String)params[0]));
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
	
	public String getData() {
		return datas;
	}
	
	public boolean hasMore() {
		if (StringUtil.isEmpty(more))
			return true;
		
		return "1".equals(more);
	}
	
	public int getError() {
		return error;
	}
	
	private void checkResult() {
		more = "0";
		datas = JSONUtil.getValue(result, "data");
		more = "0";
		if (!StringUtil.isEmpty(datas)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
			more = JSONUtil.getValue(result, "more");
		}
		
		return;
	}
}
