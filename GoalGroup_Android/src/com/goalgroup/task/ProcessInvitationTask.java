package com.goalgroup.task;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.ProcessInvitationHttp;
import com.goalgroup.ui.adapter.InvitationListAdapter;

import android.os.AsyncTask;

public class ProcessInvitationTask extends AsyncTask<Void, Void, Void> {
	private InvitationListAdapter adapter;
	private ProcessInvitationHttp post;
	private Object[] param;
	private String req_type;
	
	public ProcessInvitationTask(InvitationListAdapter adapter, Object[] param) {
		this.adapter = adapter;
		this.param = param;
		req_type = String.valueOf(param[2]);
	}
	
	protected void onPreExecute() {
		super.onPreExecute();
	}

	@Override
	protected Void doInBackground(Void... arg0) {
		post = new ProcessInvitationHttp();
		post.setParams(param);
		post.run();
		return null;
	}
	
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		String data_result = "";
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		adapter.stopProcessInvitation(post.getError(),data_result, Integer.valueOf(req_type));
	}

}
