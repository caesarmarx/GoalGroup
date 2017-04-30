package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.http.GetCheckVersionHttp;
import com.goalgroup.ui.AboutActivity;
import com.goalgroup.utils.JSONUtil;

public class GetVersionTask extends AsyncTask<Void, Void, Void> {
	
	private AboutActivity parent;
	private GetCheckVersionHttp post;
	private String curVer;
	
	public GetVersionTask(AboutActivity parent, String version) {
		this.parent = parent;
		this.curVer = version;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetCheckVersionHttp(curVer);
		post.setParams();
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		boolean post_state = post.isSuccess();
		if (post_state) {
			String checkResult = post.getResultData();
			String[] data = JSONUtil.getArrays(checkResult, "result");
			
			for (int i = 0; i < data.length; i++) {
				String ver = JSONUtil.getValue(data[i], "new_ver");
				String url = JSONUtil.getValue(data[i], "url");
				parent.setUpdateInfo(ver, url);
			}
		}
		
		parent.stopCheckVersion(post_state);
	}

}
