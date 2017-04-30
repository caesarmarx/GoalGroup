package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;

public class SendChallHttp extends GoalGroupHttpPost {
	
	private int error;
	private int datas;
	private int type;
	private int room_id;
	private String room_title;
	
	public SendChallHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "send_challenge"));
		post_params.add(new BasicNameValuePair("club_id", String.valueOf(params[0])));
		post_params.add(new BasicNameValuePair("game_date", (String)params[1]));
		post_params.add(new BasicNameValuePair("game_time", (String)params[2]));
		post_params.add(new BasicNameValuePair("player_count", (String)params[3]));
		post_params.add(new BasicNameValuePair("stadium_area", (String)params[4]));
		post_params.add(new BasicNameValuePair("stadium_address", (String)params[5]));
		post_params.add(new BasicNameValuePair("money_split", (String)params[6]));
		post_params.add(new BasicNameValuePair("req_club_id", (String)params[7]));
		post_params.add(new BasicNameValuePair("type", String.valueOf(params[8])));
		post_params.add(new BasicNameValuePair("create_type", String.valueOf(params[9])));
		post_params.add(new BasicNameValuePair("challenge_id", String.valueOf(params[10])));
		
		type = (int)((Integer)params[8]);
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
	
	public int getRoomId() {
		return room_id;
	}
	
	public String getRoomTitle() {
		return room_title;
	}
	
	private void checkResult() {
		datas = JSONUtil.getValueInt(result, "succeed");
		if (datas == 1) {
			error = GgHttpErrors.SEND_CHALL_SUCCESS;
			String room_info = JSONUtil.getValue(result, "data");
			if (type != 0) {
				room_id = JSONUtil.getValueInt(room_info, "room_id");
				room_title = JSONUtil.getValue(room_info, "room_name");
			}
		}
		
		return;
	}
}
