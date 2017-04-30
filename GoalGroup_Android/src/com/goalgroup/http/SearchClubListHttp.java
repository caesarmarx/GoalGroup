package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class SearchClubListHttp extends GoalGroupHttpPost {
	
	private int error;
	private String datas;
	private String more;
	
	public SearchClubListHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "search_club_list"));
		post_params.add(new BasicNameValuePair("min_age", String.valueOf(params[0])));
		post_params.add(new BasicNameValuePair("max_age", String.valueOf(params[1])));
		post_params.add(new BasicNameValuePair("ActivityTime", String.valueOf(params[2])));
		post_params.add(new BasicNameValuePair("ActivityArea", (String)params[3]));
		post_params.add(new BasicNameValuePair("page", String.valueOf(params[4])));
		post_params.add(new BasicNameValuePair("user_id", GgApplication.getInstance().getUserId()));
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
		if (!StringUtil.isEmpty(datas)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
			more = JSONUtil.getValue(result, "more");
		}
		
		return;
	}
}
