package com.goalgroup.http;

import net.arnx.jsonic.JSON;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;

public class CreateClubHttp extends GoalGroupHttpPost {
	
	private int error;
	private int datas;
	
	public CreateClubHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "create_club"));
		post_params.add(new BasicNameValuePair("user_id", (String)params[0]));
		post_params.add(new BasicNameValuePair("ClubName", (String)params[1]));
		post_params.add(new BasicNameValuePair("Mark_Pic_Url", (String)params[3]));
		post_params.add(new BasicNameValuePair("City", params[4].toString()));
		post_params.add(new BasicNameValuePair("Money", "1500"));
		post_params.add(new BasicNameValuePair("Introduction", (String)params[6]));
		post_params.add(new BasicNameValuePair("ActivityTime", params[7].toString()));
		post_params.add(new BasicNameValuePair("ActivityArea", (String)params[8]));
		post_params.add(new BasicNameValuePair("Home_Stadium_Area", (String)params[9]));
		post_params.add(new BasicNameValuePair("Home_Stadium_Address", (String)params[10]));
		post_params.add(new BasicNameValuePair("Sponsor", (String)params[11]));
		post_params.add(new BasicNameValuePair("create_type", String.valueOf(params[12])));
		post_params.add(new BasicNameValuePair("club_id", String.valueOf(params[13])));
//		post_params.add(new BasicNameValuePair("Create_Date", (String)params[2]));
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
	
	public int getData() {
		return datas;
	}
	
	public int getError() {
		return error;
	}
	
	private void checkResult() {
		datas = JSONUtil.getValueInt(result, "status");
		if (datas != 0) {
			error = GgHttpErrors.GET_CHALL_SUCCESS;
			String data = JSONUtil.getValue(result, "data");
			String club_id = JSONUtil.getValue(data, "club_id");
			String club_name = JSONUtil.getValue(data, "club_name");
			int room_id = JSONUtil.getValueInt(data, "room_id");
			int chat_type = JSONUtil.getValueInt(data, "chat_type");
			
			int post = JSONUtil.getValueInt(data, "post");
			
			GgApplication.getInstance().addClubInfo(club_id, club_name, post);
			GgApplication.getInstance().getChatInfo().addClubChatRoom(Integer.valueOf(club_id), club_name, room_id, chat_type);
		}
		
		return;
	}
}
