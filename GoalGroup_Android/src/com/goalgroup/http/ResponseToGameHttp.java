package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;

public class ResponseToGameHttp extends GoalGroupHttpPost {
	
	private int error;
	private int data;
	private int room_id;
	private String room_title;
	
	public ResponseToGameHttp() {
		super();
		error = GgHttpErrors.HTTP_POST_FAIL;
		room_id = -1;
		room_title = "";
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
		post_params.add(new BasicNameValuePair("cmd", "game_agree"));
		post_params.add(new BasicNameValuePair("agree_game_id", String.valueOf(params[0])));
		post_params.add(new BasicNameValuePair("agree_club_id", String.valueOf(params[1])));
		post_params.add(new BasicNameValuePair("game_type", String.valueOf(params[2])));
	}
	
	public int getData() {
		return data;
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
		String datas = JSONUtil.getValue(result, "data");
		data = JSONUtil.getValueInt(datas, "success");
		int flag = JSONUtil.getValueInt(result, "succeed");
		
		if (flag == 1 || flag == 2) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
			room_id = JSONUtil.getValueInt(datas, "room_id");
			room_title = JSONUtil.getValue(datas, "room_name");
		}
		
		return;
	}

}
