package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetMyClubsHttp;
import com.goalgroup.model.MyClubItem;
import com.goalgroup.ui.adapter.ClubListAdapter;
import com.goalgroup.ui.fragment.ClubFragment;
import com.goalgroup.utils.JSONUtil;

public class GetMyClubsTask extends AsyncTask<Void, Void, Void> {
	
	private final int CHALL_UNIT_COUNT = 10;
	
	private ClubFragment parent;	
	private ClubListAdapter adapter;
	private int pagenum;
	
	private GetMyClubsHttp post;
	
	public GetMyClubsTask(ClubFragment parent, ClubListAdapter adapter) {
		this.parent = parent;
		this.adapter = adapter;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();		
		pagenum = (adapter.getCount() / CHALL_UNIT_COUNT) + 1;
	}
	
	private String[] urls = {
		"GetRunningOrders", "GetPrestartOrders", "GetCompleteOrders", "GetDeletedOrders"
	};
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetMyClubsHttp();
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
			
			ArrayList<MyClubItem> datas = new ArrayList<MyClubItem>();
			for (int i = 0; i < model_values.length; i++) {
				MyClubItem data = new MyClubItem(
					JSONUtil.getValueInt(model_values[i], "club_id"), 
					JSONUtil.getValue(model_values[i], "mark_pic_url"), 
					JSONUtil.getValue(model_values[i], "name"));
				datas.add(data);
			}
			
			adapter.addData(datas);
		}
		
		parent.stopAttachClubs(post.hasMore());
	}
}
