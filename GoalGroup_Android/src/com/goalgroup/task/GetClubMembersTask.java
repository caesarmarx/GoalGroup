package com.goalgroup.task;


import android.app.Activity;
import android.os.AsyncTask;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetClubMembersHttp;
import com.goalgroup.ui.ClubMembersActivity;
public class GetClubMembersTask extends AsyncTask<Void, Void, Void> {
	private ClubMembersActivity parent;
	private String club_id;
	
	private GetClubMembersHttp post;
	
	public GetClubMembersTask(Activity parent, int club_id) {
		this.parent = (ClubMembersActivity)parent;
		this.club_id = Integer.toString(club_id);
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetClubMembersHttp();
		post.setParams(club_id);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		String data_result = "";
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopDownloadMemberInfo(data_result, post.hasMore());
	}
}
