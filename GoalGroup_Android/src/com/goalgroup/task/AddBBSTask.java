package com.goalgroup.task;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.AddBBSHttp;
import com.goalgroup.ui.AddBBSActivity;

import android.os.AsyncTask;

public class AddBBSTask extends AsyncTask<Void, Void, Void> {
	private AddBBSActivity parent;
	private Object[] param;
	private AddBBSHttp post;
	
	public AddBBSTask(AddBBSActivity parent, Object[] param){
		this.parent = parent;
		this.param = param;
	}
	
	protected void onPreExecute() {
		super.onPreExecute();
	}

	@Override
	protected Void doInBackground(Void... arg0) {
		post = new AddBBSHttp();
		post.setParams(param);
		post.run();
		return null;
	}
	
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int data_result = 0;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopCreateDiscuss(data_result);
	}
}
