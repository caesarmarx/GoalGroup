package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.goalgroup.R;
import com.goalgroup.model.ManagerNewsItem;
import com.goalgroup.ui.ManagerNewsActivity;
import com.goalgroup.utils.StringUtil;

public class ManagerNewsListAdapter extends BaseAdapter {
	
	private Context ctx;
	private ManagerNewsActivity parent;
	private ArrayList<ManagerNewsItem> datas;
	
	public ManagerNewsListAdapter(Context aCtx) {
		ctx = aCtx;
		parent = (ManagerNewsActivity)ctx;
		datas = new ArrayList<ManagerNewsItem>();
	}
	
	@Override
	public int getCount() {
		return datas.size();
	}

	@Override
	public Object getItem(int position) {
		return datas.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View view, ViewGroup parent) {
		ManagerNewsItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.manager_news_list_adapter, null);
			
			holder = new ViewHolder();
			holder.tv_dateTime = (TextView)view.findViewById(R.id.date_time);
			holder.tv_apContent = (TextView)view.findViewById(R.id.news_appeal);
			holder.tv_anContent = (TextView)view.findViewById(R.id.news_answer);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data);
		
		return view;
	}
	
	private class ViewHolder {
		public TextView tv_dateTime;
		public TextView tv_apContent;
		public TextView tv_anContent;
		
		public void initHolder(ManagerNewsItem data) {
			tv_apContent.setText(data.getAppealContent());
			if (data.getAnswerContent() == null)
				tv_anContent.setVisibility(View.GONE);
			tv_anContent.setText(data.getAnswerContent());
			String item = data.getDate().concat(" ");
			item = item.concat(StringUtil.getWeekDay(data.getWeekDay())).concat(" ");
			item = item.concat(data.getTime());
			tv_dateTime.setText(item);
		}
	}
	
	public void addData(ArrayList<ManagerNewsItem> newdatas) {
		for (ManagerNewsItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void clearData() {
		datas.clear();
	}
}
