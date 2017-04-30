package com.goalgroup.task;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.AnswerBbsHttp;
import com.goalgroup.http.SendReportHttp;
import com.goalgroup.ui.ReadBBSActivity;
import com.goalgroup.ui.ReportActivity;

import android.os.AsyncTask;
import android.widget.Toast;

public class AnswerBbsTask extends AsyncTask<Void, Void, Void> {
	private ReadBBSActivity parent;
	private AnswerBbsHttp post;

	private Object[] param;
	
	public AnswerBbsTask(ReadBBSActivity parent, Object[] param) {
		this.parent = parent;
		this.param = param;
	}
	
	protected void onPreExecute(){
		super.onPreExecute();
	}

	@Override
	protected Void doInBackground(Void... arg0) {
		post = new AnswerBbsHttp();
		post.setParams(param);
		post.run();
		return null;
	}
	
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		String data_result = "";
		
		if(post.getError() == GgHttpErrors.GET_CHALL_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopAnswerBbs(data_result);
	}
}
