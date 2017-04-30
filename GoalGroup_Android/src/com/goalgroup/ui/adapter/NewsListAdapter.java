package com.goalgroup.ui.adapter;

import java.util.ArrayList;

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
import com.goalgroup.chat.info.GgChatInfo;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.ui.ClubInfoActivity;
import com.goalgroup.ui.CreateClubActivity;
import com.goalgroup.ui.chat.ChatEntity;
import com.goalgroup.ui.chat.EmoteUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class NewsListAdapter extends BaseAdapter {
	
	private Context ctx;
	private ArrayList<ChatRoomInfo> datas;
	
	private MyClubData mClubData;
	
	public NewsListAdapter(Context aCtx) {
		ctx = aCtx;
		datas = new ArrayList<ChatRoomInfo>();
		mClubData = new MyClubData();
//		initRoomsData();
		
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
	
	public void clearData() {
		datas.clear();
		return;
	}

	public void addData(ChatRoomInfo data) {
		datas.add(data);
	}

	@Override
	public View getView(int position, View view, ViewGroup parent) {
		ChatRoomInfo data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		
			view = LayoutInflater.from(ctx).inflate(R.layout.news_list_adapter, null);
			
			holder = new ViewHolder();
			holder.managerNews = view.findViewById(R.id.from_manager);
			holder.discussList = view.findViewById(R.id.discuss_list);
			holder.clubName01 = (TextView)view.findViewById(R.id.club_name_01);
			holder.clubName02 = (TextView)view.findViewById(R.id.club_name_02);
			holder.clubMark01 = (ImageView)view.findViewById(R.id.club_mark_01);
			holder.clubMark02 = (ImageView)view.findViewById(R.id.club_mark_02);
			holder.playerCount = (TextView)view.findViewById(R.id.player_count);
			holder.content = (TextView)view.findViewById(R.id.content);
			holder.datetime = (TextView)view.findViewById(R.id.game_date_time);
			holder.areaNewsCount = view.findViewById(R.id.area_news_count);
			holder.newsCount = (TextView)view.findViewById(R.id.news_count);
			holder.imgLoader = GgApplication.getInstance().getImageLoader();
			
			view.setTag(holder);
		
			holder = (ViewHolder)view.getTag();
		
		
		holder.initHolder(data);
		return view;
	}
	
	private class ViewHolder {
		public View managerNews;
		public View discussList;
		public ImageView clubMark01;
		public ImageView clubMark02;
		public TextView clubName01;
		public TextView clubName02;
		public TextView playerCount;
		public TextView content;
		public TextView datetime;
		public View areaNewsCount;
		public TextView newsCount;
		
		private ImageLoader imgLoader;
		
		public void initHolder(final ChatRoomInfo data) {
			if(data.getRoomTitle() == "平台信息"){
				managerNews.setVisibility(View.VISIBLE);
				discussList.setVisibility(View.GONE);
				return;
			}
			clubName01.setText(data.getClubName01());
			clubName02.setText(data.getClubName02());
			imgLoader.displayImage(data.getClubMark01(), clubMark01, GgApplication.img_opt_club_mark);
			clubMark01.setOnClickListener(new View.OnClickListener() {				
				@Override
				public void onClick(View view) {
					mClubData = new MyClubData();
					int clubId01 = data.getClubId01();
					if (mClubData.isManagerOfClub(clubId01)){
						Intent intent = new Intent(ctx, CreateClubActivity.class);
						intent.putExtra(CommonConsts.CLUB_ID_TAG, clubId01);
						intent.putExtra(CommonConsts.CLUB_TYPE_TAG, CommonConsts.EDIT_CLUB);
						ctx.startActivity(intent);
						return;
					}
					Intent intent = new Intent(ctx, ClubInfoActivity.class);
					intent.putExtra(GgIntentParams.CLUB_ID, String.valueOf(clubId01));
					ctx.startActivity(intent);
				}
			});
			
			clubMark02.setOnClickListener(new View.OnClickListener() {				
				@Override
				public void onClick(View view) {
					int clubId02 = data.getClubId02();
					mClubData = new MyClubData();
					if (mClubData.isManagerOfClub(clubId02)){
						Intent intent = new Intent(ctx, CreateClubActivity.class);
						intent.putExtra(CommonConsts.CLUB_ID_TAG, clubId02);
						intent.putExtra(CommonConsts.CLUB_TYPE_TAG, CommonConsts.EDIT_CLUB);
						ctx.startActivity(intent);
						return;
					}
					Intent intent = new Intent(ctx, ClubInfoActivity.class);
					intent.putExtra(GgIntentParams.CLUB_ID, String.valueOf(clubId02));
					ctx.startActivity(intent);
					
				}
			});
			imgLoader.displayImage(data.getClubMark02(), clubMark02, GgApplication.img_opt_club_mark);
			EmoteUtil.setEmoteText(content, data.getLastContent());
			playerCount.setText(String.valueOf(data.getPlayerCount()) + ctx.getString(R.string.player_number));
			datetime.setText(data.getSimpleGameDate());
			datetime.setVisibility(View.VISIBLE);
			int unreadCount = data.getUnreadCount();
			if (unreadCount != 0) {
				areaNewsCount.setVisibility(View.VISIBLE);
				newsCount.setText(Integer.toString(unreadCount));
			} else {
				areaNewsCount.setVisibility(View.GONE);
			}
		}
	}
	
//	public void initRoomsData() {
//		GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
//		
//		datas = new ArrayList<ChatRoomInfo>();
//		ArrayList<ChatRoomInfo> allRooms = chatInfo.getChatRooms();
//		
//		for(int i = 1; i < allRooms.size() - 1; i++)
//			for(int j = i + 1; j < allRooms.size(); j++) {
//				if(allRooms.get(i).getLastTime().compareTo(allRooms.get(j).getLastTime()) < 0) {
//					ChatRoomInfo temp;
//					temp = allRooms.get(i);
//					allRooms.set(i, allRooms.get(j));
//					allRooms.set(j, temp);
//				}
//			}
//		
//		for (ChatRoomInfo info : allRooms) {
//			if (info.getRoomType() == ChatConsts.CHAT_ROOM_MANAGER ||
//				info.getRoomType() == ChatConsts.CHAT_ROOM_DISCUSS) {
//				datas.add(info);
//			}
//		}
//	}
	
//	private void initTestData() {
//		datas = new ArrayList<NewsItem>();
//		for (int i = 0; i < testData.length; i++)
//			datas.add(testData[i]);
//	}
//	
//	private NewsItem[] testData = {
//		new NewsItem(2, "求乐部大厅-对求乐部1比赛", "对求乐部1比赛的求乐部大厅，对求乐部1比赛的求乐部大厅，", "下午 04:45"), 
//		new NewsItem(0, "会议厅-求乐部2", "求乐部2-会议厅，求乐部2-会议厅，求乐部2-会议厅", "下午 04:30"), 
//		new NewsItem(1, "平台消息1", "平台消息1，平台消息1，平台消息1，平台消息1，平台消息1，平台消息1", "下午 03:30"),
//		new NewsItem(3, "求乐部大厅-求乐部3", "23", "下午 03:30")
//	};
}
