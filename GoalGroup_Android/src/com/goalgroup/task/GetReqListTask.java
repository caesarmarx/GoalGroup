package com.goalgroup.task;

import java.util.ArrayList;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.http.GetReqListHttp;
import com.goalgroup.model.EnterReqItem;
import com.goalgroup.ui.EnterReqListActivity;
import com.goalgroup.ui.adapter.EnterReqListAdapter;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

import android.os.AsyncTask;

public class GetReqListTask extends AsyncTask<Void, Void, Void> {
	
	private final int REQ_UNIT_COUNT = 10;
	
	private EnterReqListActivity parent;
	private EnterReqListAdapter adapter;
	private GetReqListHttp post;
	
	private int club_id;
	private int page_num;

	public GetReqListTask(EnterReqListActivity parent, EnterReqListAdapter adapter, int club_id) {
		this.parent = parent;
		this.adapter = adapter;
		this.club_id = club_id;
	}
	
	protected void onPreExecute() {
		super.onPreExecute();		
		page_num = (adapter.getCount() / REQ_UNIT_COUNT) + 1;
	}
	
	@Override
	protected Void doInBackground(Void... arg0) {
		post = new GetReqListHttp();
		post.setParams(club_id, page_num);
		post.run();
		return null;
	}
	
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS){
			String data_result = post.getData();
			String[] model_values = JSONUtil.getArrays(data_result, "result");
			
			ArrayList<EnterReqItem> data = new ArrayList<EnterReqItem>();
			for (int i = 0; i < model_values.length; i++){
				EnterReqItem reqItem = new EnterReqItem(
					JSONUtil.getValueInt(model_values[i], "user_id"),
					JSONUtil.getValue(model_values[i], "user_name").toString(),
					JSONUtil.getValue(model_values[i], "req_date").toString(),
					JSONUtil.getValue(model_values[i], "user_icon").toString(),
					StringUtil.getStrFromSelValue(JSONUtil.getValueInt(model_values[i], "position"), CommonConsts.POSITION));
				data.add(reqItem);
			}
			adapter.addData(data);
		}
		parent.stopAttachReqList(post.hasMore());
	}
	
}
