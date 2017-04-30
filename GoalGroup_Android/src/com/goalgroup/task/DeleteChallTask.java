package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.DeleteChallHttp;
import com.goalgroup.ui.ClubChallengesActivity;

public class DeleteChallTask extends AsyncTask<Void, Void, Void> {
	private ClubChallengesActivity parent;
	private int type;
	private int club_id;
	private int game_id;
	
	private DeleteChallHttp post;
	
	public DeleteChallTask(ClubChallengesActivity parent, int type, int club_id, int game_id) {
		this.parent = parent;
		this.type = type;
		this.club_id = club_id;
		this.game_id = game_id;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new DeleteChallHttp();
		post.setParams(Integer.toString(type), Integer.toString(club_id), Integer.toString(game_id));		
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		int data_result = 0;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopDeleteChallenge(data_result);
	}
}
