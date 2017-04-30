package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetGameResultHttp;
import com.goalgroup.http.SetGameResultHttp;
import com.goalgroup.http.SetUserPointHttp;
import com.goalgroup.ui.GameDetailActivity;
import com.goalgroup.ui.GameResultActivity;
import com.goalgroup.utils.StringUtil;

public class SetUserPointTask extends AsyncTask<Void, Void, Void> {
	private GameDetailActivity parent;
	private SetUserPointHttp post;

	
	private Object[] param;	
	public SetUserPointTask(GameDetailActivity parent, Object[] param) {
		this.parent = parent;
		this.param = param;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new SetUserPointHttp();
		post.setParams(param);
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
		
		parent.stopSetUsersPoint(data_result);
	}
}
