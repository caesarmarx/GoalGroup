package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetBbsDetailHttp;
import com.goalgroup.model.BbsReplyItem;
import com.goalgroup.ui.ReadBBSActivity;
import com.goalgroup.ui.adapter.BbsListAdapter;
import com.goalgroup.ui.adapter.BbsReplyAdapter;
import com.goalgroup.ui.adapter.ClubChallengeAdapter;
import com.goalgroup.utils.JSONUtil;

public class GetBbsDetailTask extends AsyncTask<Void, Void, Void> {
	
	private final int REPLY_UNIT_COUNT = 5;
	
	private ReadBBSActivity parent;	
	private BbsReplyAdapter adapter;
	private int pagenum;
	private int bbs_id;
	
	private GetBbsDetailHttp post;
	
	public GetBbsDetailTask(ReadBBSActivity parent, BbsReplyAdapter adapter, int bbs_id) {
		this.parent = parent;
		this.adapter = adapter;
		this.bbs_id = bbs_id;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();		
		pagenum = (adapter.getCount() / REPLY_UNIT_COUNT) + 1;
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetBbsDetailHttp();
		post.setParams(bbs_id, pagenum);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		String bbs_detail = "";
		String[] arr_content = new String[0];
		
		if (post.getError() == GgHttpErrors.GET_CHALL_SUCCESS) {
			String data_result = post.getData();
			bbs_detail = JSONUtil.getValue(data_result, "bbs_detail");
			String[] discuss_reply = JSONUtil.getArrays(data_result, "discuss_reply");
			arr_content = JSONUtil.getArrays(data_result, "content_arr");
			
			ArrayList<BbsReplyItem> datas = new ArrayList<BbsReplyItem>();
			for (int i = 0; i < discuss_reply.length; i++) {
				BbsReplyItem data = new BbsReplyItem(
						JSONUtil.getValueInt(discuss_reply[i], "id"),
						JSONUtil.getValueInt(discuss_reply[i], "user_id"),
						JSONUtil.getValue(discuss_reply[i], "user_name"),
						JSONUtil.getValue(discuss_reply[i], "reply_date"),
						JSONUtil.getValue(discuss_reply[i], "content"),
						JSONUtil.getValueInt(discuss_reply[i], "reply_id"),
						JSONUtil.getValueInt(discuss_reply[i], "depth"));
					
				datas.add(data);
			}
			
			adapter.addData(datas);
		}
		
		parent.stopAttachBbsBetail(bbs_detail, arr_content, post.hasMore());
	}
}
