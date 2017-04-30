package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetInvGameHttp;
import com.goalgroup.http.GetInvitationHttp;
import com.goalgroup.model.InvGameItem;
import com.goalgroup.ui.InvGameActivity;
import com.goalgroup.ui.adapter.InviteGameAdapter;
import com.goalgroup.utils.JSONUtil;

public class GetInvGameTask extends AsyncTask<Void, Void, Void> {
	
	private final int INVITATION_UNIT_COUNT = 5;
	
	private InvGameActivity parent;	
	private InviteGameAdapter adapter;
	private int pagenum;
	
	private GetInvGameHttp post;
	
	public GetInvGameTask(InvGameActivity parent, InviteGameAdapter adapter) {
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
		post = new GetInvGameHttp();
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
			
			ArrayList<InvGameItem> datas = new ArrayList<InvGameItem>();
			for (int i = 0; i < model_values.length; i++) {
				InvGameItem data = new InvGameItem(
					JSONUtil.getValueInt(model_values[i], "game_id"),
					JSONUtil.getValueInt(model_values[i], "club_id"),
					JSONUtil.getValue(model_values[i], "club_name"), 
					JSONUtil.getValue(model_values[i], "mark_pic_url"),
					JSONUtil.getValueInt(model_values[i], "opp_club_id"),
					JSONUtil.getValue(model_values[i], "opp_club_name"), 
					JSONUtil.getValue(model_values[i], "opp_mark_pic_url"),
					JSONUtil.getValueInt(model_values[i], "home"),
					JSONUtil.getValueInt(model_values[i], "player_count"), 
					JSONUtil.getValue(model_values[i], "game_date"), 
					JSONUtil.getValue(model_values[i], "game_time"),
					JSONUtil.getValueInt(model_values[i], "game_weekday"),
					JSONUtil.getValue(model_values[i], "stadium_address"));
				datas.add(data);
			}
			
			adapter.addData(datas);
		}
		
		parent.stopAttachInvs(post.hasMore());
	}
}
