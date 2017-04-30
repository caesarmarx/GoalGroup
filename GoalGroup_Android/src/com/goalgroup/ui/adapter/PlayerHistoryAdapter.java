package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.goalgroup.R;
import com.goalgroup.model.PlayerHistoryItem;

public class PlayerHistoryAdapter extends BaseAdapter {
	
	private Context ctx;
	private ArrayList<PlayerHistoryItem> datas;
	
	public PlayerHistoryAdapter(Context aCtx) {
		ctx = aCtx;
		initData();
//		initTestData();
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
		PlayerHistoryItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.player_history_adapter, null);
			
			holder = new ViewHolder();
			holder.total_area = view.findViewById(R.id.player_history_area);
			holder.info01 = (TextView)view.findViewById(R.id.history_info_01);
			holder.info02 = (TextView)view.findViewById(R.id.history_info_02);
			holder.info03 = (TextView)view.findViewById(R.id.history_info_03);
			holder.info04 = (TextView)view.findViewById(R.id.history_info_04);
			holder.info05 = (TextView)view.findViewById(R.id.history_info_05);
			holder.devider = (View)view.findViewById(R.id.devide_line);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data, position);
		
		return view;
	}
	
	private class ViewHolder {
		public View total_area;
		public TextView info01;
		public TextView info02;
		public TextView info03;
		public TextView info04;
		public TextView info05;
		public View devider;
		
		public void initHolder(PlayerHistoryItem data, int position) {
			if (position == 0) {
				total_area.setBackgroundResource(R.color.pattern_black_green);
				info03.setTextColor(android.graphics.Color.WHITE);
				devider.setVisibility(View.GONE);
			} else {
				info03.setTextColor(0xFFffe8ab);
				devider.setVisibility(View.VISIBLE);
				if (position % 2 == 0)
					total_area.setBackgroundResource(R.color.pattern_light_green);
				else 
					total_area.setBackgroundResource(R.color.green_bk);
			}
			info01.setText(data.getSeason());
			info02.setText(data.getTotal());
			info03.setText(data.getGoal());
			info04.setText(data.getAssist());
			info05.setText(data.getPoint());
		}
	}
	
	public void addData(ArrayList<PlayerHistoryItem> newdatas) {
		for (PlayerHistoryItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void clearData() {
		initData();
	}
	
	private void initTestData() {
		datas = new ArrayList<PlayerHistoryItem>();
		for (int i = 0; i < testData.length; i++)
			datas.add(testData[i]);
	}
	
	private void initData() {
		if (datas == null) {
			datas = new ArrayList<PlayerHistoryItem>();
		}
		
		PlayerHistoryItem header = new PlayerHistoryItem("赛季", "参赛", "进球", "助攻", "赛季评分");
		datas.clear();
		datas.add(header);
	}
	
	private PlayerHistoryItem[] testData = {
		new PlayerHistoryItem("赛季", "参赛", "进球", "助攻", "赛季评分"), 
		new PlayerHistoryItem("2014", "20", "15", "1", "8.5"), 
		new PlayerHistoryItem("2013", "25", "20", "3", "5"), 
		new PlayerHistoryItem("2012", "23", "16", "5", "6.5")
	};

}
