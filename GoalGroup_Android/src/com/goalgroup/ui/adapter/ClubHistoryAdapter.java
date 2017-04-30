package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Point;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.goalgroup.R;
import com.goalgroup.model.ClubHistoryItem;

@SuppressLint("ResourceAsColor")
public class ClubHistoryAdapter extends BaseAdapter {
	
	private Context ctx;
	private ArrayList<ClubHistoryItem> datas;
	
	public ClubHistoryAdapter(Context aCtx) {
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
		ClubHistoryItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.club_history_adapter, null);
			
			holder = new ViewHolder();
			holder.area = (View)view.findViewById(R.id.history_area);
			holder.info01 = (TextView)view.findViewById(R.id.history_info_01);
			holder.info02 = (TextView)view.findViewById(R.id.history_info_02);
			holder.info03 = (TextView)view.findViewById(R.id.history_info_03);
			holder.info04 = (TextView)view.findViewById(R.id.history_info_04);
			holder.info05 = (TextView)view.findViewById(R.id.history_info_05);
			holder.info06 = (TextView)view.findViewById(R.id.history_info_06);
			holder.info07 = (TextView)view.findViewById(R.id.history_info_07);
			holder.info08 = (TextView)view.findViewById(R.id.history_info_08);
			holder.devider = view.findViewById(R.id.devide_line);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data, position);
		
		return view;
	}
	
	private class ViewHolder {
		public View area;
		public TextView info01;
		public TextView info02;
		public TextView info03;
		public TextView info04;
		public TextView info05;
		public TextView info06;
		public TextView info07;
		public TextView info08;
		public View devider;
		
		public void initHolder(ClubHistoryItem data, int position) {
			if (position == 0) {
				info01.setTextSize(16);
				info02.setTextSize(16);
				info03.setTextSize(16);
				info04.setTextSize(16);
				info05.setTextSize(16);
				info06.setTextSize(16);
				info07.setTextSize(16);
				info08.setTextSize(16);
				area.setBackgroundResource(R.color.pattern_black_green);
				info03.setBackgroundResource(R.drawable.green_left_panel);
				info03.setTextColor(android.graphics.Color.WHITE);
				info04.setBackgroundResource(R.drawable.green_normal_panel);
				info04.setTextColor(android.graphics.Color.WHITE);
				info05.setBackgroundResource(R.drawable.green_right_panel);
				info05.setTextColor(android.graphics.Color.WHITE);
				devider.setVisibility(View.GONE);
			} else {
				info01.setTextSize(14);
				info02.setTextSize(14);
				info03.setTextSize(14);
				info04.setTextSize(14);
				info05.setTextSize(14);
				info06.setTextSize(14);
				info07.setTextSize(14);
				info08.setTextSize(14);
				info03.setBackgroundResource(R.color.transparent);
				info03.setTextColor(0xFFffe8ab);
				info04.setBackgroundResource(R.color.transparent);
				info04.setTextColor(0xFF348C5C);
				info05.setBackgroundResource(R.color.transparent);
				info05.setTextColor(0xFFFF4040);
				devider.setVisibility(View.VISIBLE);
				if (position % 2 == 0)
					area.setBackgroundResource(R.color.pattern_light_green);
				else 
					area.setBackgroundResource(R.color.green_bk);
			}
			
			info01.setText(data.getSeason());
			info02.setText(data.getTotal());
			info03.setText(data.getWin());
			info04.setText(data.getDraw());
			info05.setText(data.getLose());
			info06.setText(data.getGoal01());
			info07.setText(data.getGoal02());
			info08.setText(data.getGoalDiff());
			
		}
	}
	
	public void addData(ArrayList<ClubHistoryItem> newdatas) {
		for (ClubHistoryItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void clearData() {
		initData();
	}
	
	private void initData() {
		if (datas == null) {
			datas = new ArrayList<ClubHistoryItem>();
		}
		
		ClubHistoryItem header = new ClubHistoryItem("赛季", "赛", "胜", "平", "负", "进球", "失球", "胜球");
		datas.clear();
		datas.add(header);
//		initTest();
	}
	
	private void initTest() {
		for (int i = 0; i < testData.length; i++) {
			datas.add(testData[i]);
		}
	}
	
	private ClubHistoryItem[] testData = {
		new ClubHistoryItem("2014", "20", "15", "1", "4", "18", "8", "10"), 
		new ClubHistoryItem("2013", "25", "20", "3", "2", "30", "4", "26"), 
		new ClubHistoryItem("2012", "23", "16", "5", "2", "18", "6", "12")
	};
}
