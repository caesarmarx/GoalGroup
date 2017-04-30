package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;

public class RunTimeDetailHttp extends GoalGroupHttpPost {

	private int runtimeDetailError;
	private String datas;
	
	public RunTimeDetailHttp() {
		super();		
		runtimeDetailError = GgHttpErrors.LOGIN_CONNECTION;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "get_runtime_detail"));
		post_params.add(new BasicNameValuePair("user_id", params[0].toString()));
		post_params.add(new BasicNameValuePair("club_id", params[1].toString()));
	}

	@Override
	public boolean run() {
		TIME_OUT = 1000;
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
		return runtimeDetailError;
	}
	
	private void checkResult() {
		String clubInfo[];
		String clubId[];
		String clubName[];
		int post[];
		String all_club_info[];
		String all_club_id[];
		String all_club_name[];
		
		int inv_count;
		int temp_inv_count;
		
		runtimeDetailError = JSONUtil.getValueInt(result, "succeed");
		if (runtimeDetailError == GgHttpErrors.LOGIN_SUCCESS) {

			datas = JSONUtil.getValue(result, "data");
			
			clubInfo = JSONUtil.getArrays(datas, "club_info");
			clubId = new String[clubInfo.length];
			clubName = new String[clubInfo.length];
			post = new int[clubInfo.length];
			for(int i=0;i<clubInfo.length;i++) {
				clubId[i] = JSONUtil.getValue(clubInfo[i], "club_id");
				clubName[i] = JSONUtil.getValue(clubInfo[i], "club_name");
				post[i] = JSONUtil.getValueInt(clubInfo[i], "post");
			}
			
			GgApplication.getInstance().getChatInfo().initClubChatRoom(clubInfo);
			
			String[] discuss_room = JSONUtil.getArrays(datas, "discuss_chat_room");
			GgApplication.getInstance().getChatInfo().initDiscussRoom(discuss_room);
			
			all_club_info = JSONUtil.getArrays(datas, "all_club");
			all_club_id = new String[all_club_info.length];
			all_club_name = new String[all_club_info.length];
			for (int i = 0; i < all_club_info.length; i++) {
				all_club_id[i] = JSONUtil.getValue(all_club_info[i], "club_id");
				all_club_name[i] = JSONUtil.getValue(all_club_info[i], "club_name");
			}
			
			inv_count = JSONUtil.getValueInt(datas, "inv_cnt");
			temp_inv_count = JSONUtil.getValueInt(datas, "tempinv_cnt");
			
			GgApplication.getInstance().setClubInfo(clubId, clubName, post, CommonConsts.MY_CLUB);
			GgApplication.getInstance().setClubInfo(all_club_id, all_club_name, null, CommonConsts.ALL_CLUB);
			
			GgApplication.getInstance().setInvCount(inv_count);
			GgApplication.getInstance().setTempInvCount(temp_inv_count);
			
			GgApplication app = GgApplication.getInstance();
			app.getChatInfo().openChatHistDB(app);
			
		}
		return;
	}

}
