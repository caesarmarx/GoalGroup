package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.GgApplication;
import com.goalgroup.chat.info.GgChatInfo;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.CreateDiscussRoomHttp;
import com.goalgroup.ui.adapter.ChallengeListAdapter;

public class CreateDiscussRoomTask extends AsyncTask<Void, Void, Void> {
	private ChallengeListAdapter parent;
	private int club_id_01;
	private int club_id_02;
	private int chall_id;
	private int player_count;
	
	private CreateDiscussRoomHttp post;
	
	public CreateDiscussRoomTask(ChallengeListAdapter parent, int club_id_01, int club_id_02, int chall_id, int player_count) {
		this.parent = (ChallengeListAdapter)parent;
		this.club_id_01 = club_id_01;
		this.club_id_02 = club_id_02;
		this.chall_id = chall_id;
		this.player_count = player_count;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new CreateDiscussRoomHttp();
		post.setParams(club_id_01, club_id_02, chall_id, player_count);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		boolean success = false;
		ChatRoomInfo room = null;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			success = true;
			
			int room_id = post.getRoomId();
			String room_title = post.getRoomTitle();
			
			GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
			chatInfo.addDiscussChatRoom(room_id, room_title);
			
			GgApplication.getInstance().getChatEngine().sendCreateNewDiscussRoom(room_id, room_title);
			
			room = chatInfo.getChatRoom(room_id);
		}
		
		parent.stopCreateDiscussRoom(success, room);
	}
}
