package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetBbsListHttp;
import com.goalgroup.model.BbsItem;
import com.goalgroup.ui.adapter.BbsListAdapter;
import com.goalgroup.ui.fragment.BBSFragment;
import com.goalgroup.utils.JSONUtil;

public class GetBbsListTask extends AsyncTask<Void, Void, Void> {
	
	private final int CHALL_UNIT_COUNT = 5;
	
	private BBSFragment parent;	
	private BbsListAdapter adapter;
	private int pagenum;
	
	private GetBbsListHttp post;
	
	public GetBbsListTask(BBSFragment parent, BbsListAdapter adapter) {
		this.parent = parent;
		this.adapter = adapter;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();		
		pagenum = (adapter.getCount() / CHALL_UNIT_COUNT) + 1;
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetBbsListHttp();
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
			
			ArrayList<BbsItem> datas = new ArrayList<BbsItem>();
			for (int i = 0; i < model_values.length; i++) {
				BbsItem data = new BbsItem(
					JSONUtil.getValueInt(model_values[i], "bbs_id"),
					JSONUtil.getValue(model_values[i], "user_icon"), 
					JSONUtil.getValue(model_values[i], "user_name"), 
					JSONUtil.getValue(model_values[i], "date"), 
					JSONUtil.getValue(model_values[i], "img_url"), 
					JSONUtil.getValue(model_values[i], "content"), 
					JSONUtil.getValueInt(model_values[i], "reply_count"));
				datas.add(data);
			}
			
			adapter.addData(datas);
		}
		
		parent.stopAttachBbsList(post.hasMore());
	}
}
