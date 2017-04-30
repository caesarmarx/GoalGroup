package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class GetBbsDetailHttp extends GoalGroupHttpPost {
	
	private int error;
	private String datas;
	private String more;
	
	public GetBbsDetailHttp() {
		super();		
		error = GgHttpErrors.GET_CHALL_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "get_discuss_detail"));
		post_params.add(new BasicNameValuePair("bbs_id", String.valueOf(params[0])));
		post_params.add(new BasicNameValuePair("page", String.valueOf(params[1])));
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
		datas = JSONUtil.getValue(result, "data");
		if (!StringUtil.isEmpty(datas)) {
			error = GgHttpErrors.GET_CHALL_SUCCESS;
			more = JSONUtil.getValue(result, "more");
		}
		return;
	}
}
