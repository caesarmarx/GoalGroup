package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.SendInvReqHttp;
import com.goalgroup.ui.ProfileActivity;
import com.goalgroup.ui.adapter.PlayFilterResultAdapter;

public class SendInvReqTask extends AsyncTask<Void, Void, Void> {
	private Object context;
	private SendInvReqHttp post;
	private Object[] param;
	private int contextFlag = 0;
	
	public SendInvReqTask(Object context, Object[] param, int contextFlag){
		this.context = context;
		this.param = param;
		this.contextFlag = contextFlag;
	}
	
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... arg0) {
		post = new SendInvReqHttp();
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
		
		if (contextFlag == 0) ((PlayFilterResultAdapter) context).stopSendInvReq(data_result);
		else if (contextFlag == 1) ((ProfileActivity) context).stopSendInvReq(data_result);
	}

}