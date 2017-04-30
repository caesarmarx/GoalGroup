package com.goalgroup.task;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetMasterDataHttp;
import com.goalgroup.ui.LoginActivity;

import android.os.AsyncTask;

public class GetMasterDataTask extends AsyncTask<Void, Void, Void> {
	private LoginActivity parent;
	private GetMasterDataHttp post;

	public GetMasterDataTask(LoginActivity parent) {
		this.parent = parent;
	}
	
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... arg0) {
		post = new GetMasterDataHttp();
		post.setParams();
		post.run();
		// TODO Auto-generated method stub
		return null;
	}

	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		String data_result = "";
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.startHomeActivity();
	}
}
