package com.goalgroup.task;

import android.app.Activity;
import android.os.AsyncTask;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.SetClubMembersHttp;
import com.goalgroup.ui.ClubMembersActivity;

public class SetClubMembersTask extends AsyncTask<Void, Void, Void> {
	private ClubMembersActivity parent;
	private String club_id;
	private String manager_id;
	private String caption_id;
	private String club_members;
	private String club_position;
	private String del_players;
	
	private SetClubMembersHttp post;
	
	public SetClubMembersTask(Activity parent, int club_id, String manager_id, String caption_id, String club_members, String club_position, String delPlayerIds) {
		this.parent = (ClubMembersActivity)parent;
		this.club_id = Integer.toString(club_id);
		this.manager_id = manager_id;
		this.caption_id = caption_id;
		this.club_members = club_members;
		this.club_position = club_position;
		this.del_players = delPlayerIds;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new SetClubMembersHttp();
		post.setParams(club_id, manager_id, caption_id, club_members, club_position, del_players);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		parent.stopSetMemberPosition(post.getError() == GgHttpErrors.HTTP_POST_SUCCESS);
	}
}
