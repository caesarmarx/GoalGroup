package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class CreateDiscussRoomHttp extends GoalGroupHttpPost {
	
	private int error;
	private String datas;
	private int room_id;
	private String room_title;
	
	public CreateDiscussRoomHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "create_discuss_chat_room"));
		post_params.add(new BasicNameValuePair("team1", String.valueOf(params[0])));
		post_params.add(new BasicNameValuePair("team2", String.valueOf(params[1])));
		post_params.add(new BasicNameValuePair("challenge_id", String.valueOf(params[2])));
		post_params.add(new BasicNameValuePair("player_count", String.valueOf(params[3])));
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
	
	public int getError() {
		return error;
	}
	
	public int getRoomId() {
		return room_id;
	}
	
	public String getRoomTitle() {
		return room_title;
	}
	
	private void checkResult() {
		datas = JSONUtil.getValue(result, "data");
		if (!StringUtil.isEmpty(datas)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
			String room_info = JSONUtil.getValue(result, "data");
			room_id = JSONUtil.getValueInt(room_info, "room_id");
			room_title = JSONUtil.getValue(room_info, "room_name");
		}
		
		return;
	}
}
