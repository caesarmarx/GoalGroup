package com.goalgroup.task;


import android.app.Activity;
import android.os.AsyncTask;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.http.GetClubInfoHttp;
import com.goalgroup.ui.ClubInfoActivity;
import com.goalgroup.ui.CreateClubActivity;
public class GetClubInfoTask extends AsyncTask<Void, Void, Void> {
	private ClubInfoActivity parent1;
	private CreateClubActivity parent2;
	private String club_id;
	private int show_type;
	
	private GetClubInfoHttp post;
	
	public GetClubInfoTask(Activity parent, String club_id, int show_type) {
		if (show_type == CommonConsts.CLUB_INFO)
			this.parent1 = (ClubInfoActivity)parent;
		else
			this.parent2 = (CreateClubActivity)parent;
		this.club_id = club_id;
		this.show_type = show_type;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetClubInfoHttp();
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
		
		if (show_type == CommonConsts.CLUB_INFO)
			parent1.stopAttachClubInfo(data_result);
		else
			parent2.stopGetClubInfo(data_result);
	}
}
