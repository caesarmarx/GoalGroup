package com.goalgroup.task;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.SendReportHttp;
import com.goalgroup.ui.ReportActivity;

import android.os.AsyncTask;
import android.widget.Toast;

public class SendReportTask extends AsyncTask<Void, Void, Void> {
	private ReportActivity parent;
	private SendReportHttp post;

	private int user_id;
	private String content;
	
	public SendReportTask(ReportActivity parent, String content) {
		this.parent = parent;
		this.content = content;
		this.user_id = Integer.valueOf(GgApplication.getInstance().getUserId());
	}
	
	protected void onPreExecute(){
		super.onPreExecute();
	}

	@Override
	protected Void doInBackground(Void... arg0) {
		post = new SendReportHttp();
		post.setParams(user_id, content);
		post.run();
		return null;
	}
	
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		int data_result = 0;
		
		if(post.getError() == GgHttpErrors.GET_CHALL_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopSendReport(data_result);
	}
}
