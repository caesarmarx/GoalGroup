package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class GetMasterDataHttp extends GoalGroupHttpPost {
	private int error;
	private String datas;
	
	public GetMasterDataHttp() {
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
	
	private void checkResult() {
		String city_info[];
		String city_id[];
		String city_name[];
		String district_info[];
		String district_id[];
		String district_city_id[];
		String district_name[];
		
		datas = JSONUtil.getValue(result, "data");
		if (!StringUtil.isEmpty(datas)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
		
		city_info = JSONUtil.getArrays(datas, "city_info");
		district_info = JSONUtil.getArrays(datas, "district_info");
		
		city_id = new String[city_info.length];
		city_name = new String[city_info.length];
		for (int i = 0; i < city_info.length; i++) {
			city_id[i] = JSONUtil.getValue(city_info[i], "id");
			city_name[i] = JSONUtil.getValue(city_info[i], "city");
		}
		
		district_id = new String[district_info.length];
		district_city_id = new String[district_info.length];
		district_name = new String[district_info.length];
		for (int i = 0; i < district_info.length; i++) {
			district_id[i] = JSONUtil.getValue(district_info[i], "id");
			district_city_id[i] = JSONUtil.getValue(district_info[i], "city");
			district_name[i] = JSONUtil.getValue(district_info[i], "district");
		}
		
		GgApplication.getInstance().setCityInfo(city_id, city_name);
		GgApplication.getInstance().setDistrictInfo(district_id, district_city_id, district_name);
		return;
	}
	
	public String getData() {
		return datas;
	}
	
	public int getError() {
		return error;
	}

	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "get_masterdata"));
	}
	
}
