package com.goalgroup.task;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.SetUserOptionHttp;
import com.goalgroup.ui.SettingsActivity;

import android.os.AsyncTask;

public class SetUserOptionTask extends AsyncTask<Void, Void, Void> {
	private SettingsActivity parent;
	private SetUserOptionHttp post;
	
	private int option;
	
	public SetUserOptionTask(SettingsActivity parent, int option) {
		this.parent = parent;
		this.option = option;
	}
	
	protected void onPreExecute() {
		super.onPreExecute();
	}

	@Override
	protected Void doInBackground(Void... arg0) {
		post = new SetUserOptionHttp();
		post.setParams(option);
		post.run();
		return null;
	}
	
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		int data_result = 0;
		
		if(post.getError() == GgHttpErrors.GET_CHALL_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopSetUserOption(data_result);
	}
}
