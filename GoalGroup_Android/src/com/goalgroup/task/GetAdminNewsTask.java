package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetManagerNewsHttp;
import com.goalgroup.model.ManagerNewsItem;
import com.goalgroup.ui.ManagerNewsActivity;
import com.goalgroup.ui.adapter.ManagerNewsListAdapter;
import com.goalgroup.utils.JSONUtil;

public class GetAdminNewsTask extends AsyncTask<Void, Void, Void> {
	private final int NEWS_UNIT_COUNT = 10;
	
	private ManagerNewsActivity parent;	
	private ManagerNewsListAdapter adapter;
	private int pagenum;
	
	private GetManagerNewsHttp post;
	
	public GetAdminNewsTask(ManagerNewsActivity parent, ManagerNewsListAdapter adapter) {
		this.parent = parent;
		this.adapter = adapter;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
		pagenum = (adapter.getCount() / NEWS_UNIT_COUNT) + 1;
		if (pagenum == 1)
			adapter.clearData();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetManagerNewsHttp();
		post.setParams(Integer.toString(pagenum));
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			String data_result = post.getData();
			String[] model_values = JSONUtil.getArrays(data_result, "result");
			
			ArrayList<ManagerNewsItem> datas = new ArrayList<ManagerNewsItem>();
			for (int i = 0; i < model_values.length; i++) {
				ManagerNewsItem data = new ManagerNewsItem(
					JSONUtil.getValue(model_values[i], "date"),
					JSONUtil.getValue(model_values[i], "time"), 
					JSONUtil.getValue(model_values[i], "weekday"),
					JSONUtil.getValue(model_values[i], "user_name"),
					JSONUtil.getValue(model_values[i], "appeal_content"), 
					JSONUtil.getValue(model_values[i], "answer_content") 
					);
				datas.add(data);
			}
			
			adapter.addData(datas);
		}
		
		parent.stopGetManagerNews(post.hasMore());
	}
}
