package com.goalgroup.task;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.ProcessReqHttp;
import com.goalgroup.ui.EnterReqListActivity;
import com.goalgroup.ui.adapter.EnterReqListAdapter;

import android.os.AsyncTask;

public class ProcessReqTask extends AsyncTask<Void, Void, Void> {
	private EnterReqListAdapter adapter;
	private EnterReqListActivity parent;
	private ProcessReqHttp post;
	private String req_type;
	
	private Object[] param;

	public ProcessReqTask(EnterReqListAdapter adapter, Object[] params) {
		this.adapter = adapter;
		this.param = params;
		req_type = String.valueOf(params[2]);
	}
	
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... arg0) {
		post = new ProcessReqHttp();
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
		
		adapter.stopProcessReq(data_result, Integer.valueOf(req_type));
	}
	
}
