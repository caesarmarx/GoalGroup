package com.goalgroup.task;

import com.goalgroup.GgApplication;
import com.goalgroup.chat.info.GgChatInfo;
import com.goalgroup.chat.info.history.ChatBean;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.chat.util.UserFunctions;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.ResponseToGameHttp;
import com.goalgroup.ui.ChatActivity;
import com.goalgroup.ui.adapter.ChallengeListAdapter;
import com.goalgroup.ui.adapter.ClubChallengeAdapter;
import com.goalgroup.ui.fragment.ChallengeFragment;
import com.goalgroup.utils.DateUtil;

import android.os.AsyncTask;

public class ResponseToGameTask extends AsyncTask<Void, Void, Void> {
	private ChallengeListAdapter adapter1;
	private ClubChallengeAdapter adapter2;
	private ResponseToGameHttp post;
	private ChatActivity parent;
	int type = 0;
	int index = 0;
	
	private Object[] param;
	
	public ResponseToGameTask(ChallengeListAdapter adapter, Object[] param, int index) {
		this.adapter1 = adapter;
		this.param = param;
		this.index = index;
	}
	
	public ResponseToGameTask(ClubChallengeAdapter adapter, Object[] param, int index) {
		this.adapter2 = adapter;
		this.param = param;
		this.index = index;
		this.type = 2;
	}
	
	public ResponseToGameTask(ChatActivity parent, Object[] param, int type, int index) {
		this.type = type;
		this.parent = parent;
		this.param = param;
		this.index = index;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}

	@Override
	protected Void doInBackground(Void... arg0) {
		post = new ResponseToGameHttp();
		post.setParams(param);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int data_result = 0;
		int game_id = 0;
		int game_state = 0;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();			
			
			int room_id = post.getRoomId();
			String room_title = post.getRoomTitle();
			
			GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
			if(type == 0) {
				
				ChatRoomInfo room = chatInfo.getChatRoom(room_id);
				if (room == null) {
					chatInfo.addDiscussChatRoom(room_id, room_title);					
					GgApplication.getInstance().getChatEngine().sendCreateNewDiscussRoom(room_id, room_title);
				} else {
					room.getRoomInfoByTitle(room_title);
					game_id = room.getGameId();
					GgApplication.getInstance().getChatEngine().updateDiscussRoom(room_id, room_title);
				}
			} else {
				ChatRoomInfo room = chatInfo.getChatRoom(room_id);
				if (room == null) {
                    chatInfo.addDiscussChatRoom(room_id, room_title);
                    GgApplication.getInstance().getChatEngine().sendCreateNewDiscussRoom(room_id, room_title);
                } else {
                    room.getRoomInfoByTitle(room_title);
                    game_id = room.getGameId();
                    GgApplication.getInstance().getChatEngine().updateDiscussRoom(room_id, room_title);
                }
			}
		}
		
		if (type == 0)
			adapter1.stopResponseToChallenge(data_result, index);
		else if (type == 1)
			parent.stopResponseToChallenge(data_result, index, game_id);
		else if (type == 2)
			adapter2.stopResponseToChallenge(data_result, index);
	}

}
