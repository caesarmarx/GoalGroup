package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetInvitationHttp;
import com.goalgroup.http.SearchPlayerHttp;
import com.goalgroup.model.InvitationItem;
import com.goalgroup.ui.InvitationActivity;
import com.goalgroup.ui.adapter.InvitationListAdapter;
import com.goalgroup.utils.JSONUtil;

public class GetInvitationTask extends AsyncTask<Void, Void, Void> {
	
	private final int INVITATION_UNIT_COUNT = 10;
	
	private InvitationActivity parent;	
	private InvitationListAdapter adapter;
	private int pagenum;
	
	private GetInvitationHttp post;
	
	public GetInvitationTask(InvitationActivity parent, InvitationListAdapter adapter) {
		this.parent = parent;
		this.adapter = adapter;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();		
		pagenum = (adapter.getCount() / INVITATION_UNIT_COUNT) + 1;
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetInvitationHttp();
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
			
			ArrayList<InvitationItem> datas = new ArrayList<InvitationItem>();
			for (int i = 0; i < model_values.length; i++) {
				InvitationItem data = new InvitationItem(
					JSONUtil.getValueInt(model_values[i], "club_id"),
					JSONUtil.getValue(model_values[i], "mark_pic_url"), 
					JSONUtil.getValue(model_values[i], "club_name"), 
					JSONUtil.getValue(model_values[i], "req_date"));
				datas.add(data);
			}
			
			adapter.addData(datas);
		}
		
		parent.stopAttachInvs(post.hasMore());
	}
}
