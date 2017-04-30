package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.support.v4.app.Fragment;
import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.model.MyClubItem;
import com.goalgroup.ui.ClubInfoActivity;
import com.goalgroup.ui.CreateClubActivity;
import com.nostra13.universalimageloader.core.ImageLoader;

public class ClubListAdapter extends BaseAdapter {
	private final int FROM_CLUB_INFO = 1;
	
	private Context ctx;
	private Fragment frg;
	private ArrayList<MyClubItem> datas;
	private MyClubData mClubData;
	
	private ImageLoader imgLoader;
	
	public ClubListAdapter(Context aCtx, Fragment frgment) {
		ctx = aCtx;
		frg = frgment;
		datas = new ArrayList<MyClubItem>();
		mClubData = new MyClubData();
		
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
		MyClubItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.club_list_adapter, null);
			
			holder = new ViewHolder();
			holder.mark = (ImageView)view.findViewById(R.id.club_list_mark);
			holder.name = (TextView)view.findViewById(R.id.club_list_name);
			holder.areaUnread = view.findViewById(R.id.area_unread_count);
			holder.unread = (TextView)view.findViewById(R.id.unread_count);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data);
		
		return view;
	}
	
	private class ViewHolder {
		public ImageView mark;
		public TextView name;
		public View areaUnread;
		public TextView unread;
		
		private String clubId;
		
		public void initHolder(MyClubItem data) {
			imgLoader.displayImage(data.getClubMarkURL(), mark, GgApplication.img_opt_club_mark);
			
			clubId = Integer.toString(data.getClubId());
			mark.setOnClickListener(new View.OnClickListener() {				
				@Override
				public void onClick(View view) {
					mClubData = new MyClubData();
					if (mClubData.isManagerOfClub(Integer.valueOf(clubId))){
						Intent intent = new Intent(ctx, CreateClubActivity.class);
						intent.putExtra(CommonConsts.CLUB_ID_TAG, Integer.valueOf(clubId));
						intent.putExtra(CommonConsts.CLUB_TYPE_TAG, CommonConsts.EDIT_CLUB);
						frg.startActivityForResult(intent, FROM_CLUB_INFO);
						return;
					}
					Intent intent = new Intent(ctx, ClubInfoActivity.class);
					intent.putExtra(GgIntentParams.CLUB_ID, clubId);
					frg.startActivityForResult(intent, FROM_CLUB_INFO);
					
//					Intent intent = new Intent(ctx, ClubInfoActivity.class);
//					intent.putExtra(GgIntentParams.CLUB_ID, clubId);
//					frg.startActivityForResult(intent, FROM_CLUB_INFO);
				}
			});
			name.setText(data.getName());
			
			ChatRoomInfo room = GgApplication.getInstance().getChatInfo().getClubChatRoom(data.getClubId());
			
			int unread_count = 0;
			
			if (null != room) 
				unread_count = GgApplication.getInstance().getChatInfo().getChatRoomDB().getUnreadCount(room.getRoomId());
			
			if (unread_count != 0) {
				areaUnread.setVisibility(View.VISIBLE);
				unread.setText(Integer.toString(unread_count));
			} else {
				areaUnread.setVisibility(View.GONE);
			}
		}
	}
	
	public void addData(ArrayList<MyClubItem> newdatas) {
		for (MyClubItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void clearData() {
		datas.clear();
	}
	
	public int getClubId(int position) {
		return datas.get(position-1).getClubId();
	}
	
	public void rebuildClubData()
	{
		String[] clubIdString = GgApplication.getInstance().getClubId();
		
		for (int j = 0; j < datas.size(); j ++)
		{
			MyClubItem club = datas.get(j);
			String clubId = String.valueOf(club.getClubId());
			
			int i = 0;
			for (i = 0; i < clubIdString.length; i++)
			{
				if (clubIdString[i].equals (clubId))
					return;
			}
			
			if (i == clubIdString.length)
			{
				datas.remove(club);
				j--;
			}
		}
	}
}
