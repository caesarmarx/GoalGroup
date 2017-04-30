package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.PlayerFilterResultItem;
import com.goalgroup.model.PlayerResultItem;
import com.goalgroup.ui.ChatActivity;
import com.goalgroup.ui.ClubInfoActivity;
import com.goalgroup.ui.CreateClubActivity;
import com.goalgroup.ui.ProfileActivity;
import com.goalgroup.ui.SettingsActivity;
import com.nostra13.universalimageloader.core.ImageLoader;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class PlayerResultAdapter extends BaseAdapter {

	private Context ctx;
	private ArrayList<PlayerResultItem> datas;
	
	private ImageLoader imgLoader;
	
	public PlayerResultAdapter(Context aCtx) {
		ctx = aCtx;
//		initTestDatas();
		datas = new ArrayList<PlayerResultItem>();
		
		imgLoader = GgApplication.getInstance().getImageLoader();
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
		PlayerResultItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.player_result_adapater, null);
			
			holder = new ViewHolder();
			holder.photo = (ImageView)view.findViewById(R.id.photo);
			holder.name = (TextView)view.findViewById(R.id.user_name);
			holder.goal = (TextView)view.findViewById(R.id.goal_score);
			holder.assist = (TextView)view.findViewById(R.id.assist_score);
			holder.point = (TextView)view.findViewById(R.id.point_score);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data);
		
		return view;
	}
	
	private class ViewHolder {
		public ImageView photo;
		public TextView name;
		public TextView goal;
		public TextView assist;
		public TextView point;
		
		public void initHolder(final PlayerResultItem data) {
			imgLoader.displayImage(data.getPhotoURL(), photo, GgApplication.img_opt_photo);
			photo.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					Intent intent;
					intent = new Intent(ctx, ProfileActivity.class);
					intent.putExtra("user_id", data.getUserID());
					if (data.getUserID() == Integer.valueOf(GgApplication.getInstance().getUserId()))
						intent.putExtra("type", CommonConsts.EDIT_PROFILE);
					else 
						intent.putExtra("type", CommonConsts.SHOW_PROFILE);
					ctx.startActivity(intent);
				}
			});
			
			name.setText(data.getUserName());
			
			goal.setText(String.valueOf(data.getGoal()));
			assist.setText(String.valueOf(data.getAssist()));
			point.setText(String.valueOf(data.getPoint()));
			
//			String item = String.format(
//					ctx.getString(R.string.goal) + ": %d, " + ctx.getString(R.string.assist) + ": %d, " + ctx.getString(R.string.point) + ":%d", 
//					data.getGoal(), data.getAssist(), data.getPoint());
//			result.setText(item);
		}
	}
	
	public void addData(ArrayList<PlayerResultItem> newdatas) {
		for (PlayerResultItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void clearData() {
		datas.clear();
	}
	
	public void setPointWithPos(int position, int goal, int assist, int point) {
		
	}
	
//	private void initTestDatas() {
//		datas = new ArrayList<PlayerResultItem>();
//		for (int i = 0; i < testDatas.length; i++)
//			datas.add(testDatas[i]);
//	}
//	
//	private PlayerResultItem[] testDatas = {
//		new PlayerResultItem("", "User01", 0, 0, 0), 
//		new PlayerResultItem("", "User02", 0, 0, 0),
//		new PlayerResultItem("", "User03", 0, 0, 0),
//		new PlayerResultItem("", "User04", 0, 0, 0),
//		new PlayerResultItem("", "User05", 0, 0, 0)
//	};
}
