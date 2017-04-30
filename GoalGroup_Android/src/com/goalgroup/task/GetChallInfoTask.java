package com.goalgroup.task;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetChallInfoHttp;
import com.goalgroup.http.GetProfileHttp;
import com.goalgroup.ui.NewChallengeActivity;
import com.goalgroup.ui.ProfileActivity;

import android.os.AsyncTask;

public class GetChallInfoTask extends AsyncTask<Void, Void, Void> {
	private NewChallengeActivity parent;
	private GetChallInfoHttp post;
	
	private int game_id;
	private int type;
	
	public GetChallInfoTask(NewChallengeActivity parent, int game_id, int type) {
		this.parent = parent;
		this.game_id = game_id;
		this.type = type;
	}
	
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetChallInfoHttp();
		post.setParams(game_id, type);
		post.run();
		return null;
	}
	
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		String data_result = "";
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopAttachChallInfo(data_result);
	}

}
