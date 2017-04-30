package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.GgApplication;
import com.goalgroup.chat.info.GgChatInfo;
import com.goalgroup.chat.info.history.ChatBean;
import com.goalgroup.chat.util.UserFunctions;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.SendChallHttp;
import com.goalgroup.ui.NewChallengeActivity;
import com.goalgroup.utils.DateUtil;
public class SendChallTask extends AsyncTask<Void, Void, Void> {
	private NewChallengeActivity parent;	
	
	private Object[] challInfo;
	private SendChallHttp post;
	private int type;
	
	public SendChallTask(NewChallengeActivity parent, Object[] params) {
		this.parent = parent;
		this.challInfo = params;
		this.type = (int)((Integer)params[8]);
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new SendChallHttp();
		post.setParams(challInfo);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int data_result = 0;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
			if (type != 0) {
				int room_id = post.getRoomId();
				String room_title = post.getRoomTitle();
				
				GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
				chatInfo.addDiscussChatRoom(room_id, room_title);				
				GgApplication.getInstance().getChatEngine().sendCreateNewDiscussRoom(room_id, room_title);
			}
		}
		
		parent.stopSendChallenge(data_result);
	}
}
