package com.goalgroup.ui;

import java.util.ArrayList;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.info.GgChatInfo;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.common.GgBroadCast;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.ui.adapter.NewsListAdapter;

public class NewsAlarmActivity extends Activity {
	private final int FROM_DISCUSS_FIELD = 1;
	
	private TextView tvTitle;
	private Button btnBack;
	
	private ListView newsListView;
	private NewsListAdapter adapter;
	private MyClubData myClubData;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_news_alaram);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.news));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		adapter = new NewsListAdapter(NewsAlarmActivity.this);
//		initRoom();
		
		newsListView = (ListView)findViewById(R.id.news_listview);
		newsListView.setAdapter(adapter);
		newsListView.setOnItemClickListener(new OnItemClickListener() {
			
			@Override
        	public void onItemClick(AdapterView<?> parent, View v, int position, long id) {
				if (position == 0){
					Intent intent = new Intent(NewsAlarmActivity.this, ManagerNewsActivity.class);
					startActivity(intent);
					return;
				}
				myClubData = new MyClubData();
				
				ChatRoomInfo room = (ChatRoomInfo)adapter.getItem(position);
				
				MyClubData clubsInfo = new MyClubData();
				boolean isHome = clubsInfo.isOwnClub(room.getClubId01());
				
				int clubId01 = (isHome ? room.getClubId01() : room.getClubId02());
				int clubId02 = (!isHome ? room.getClubId01() : room.getClubId02());
				int gameType = room.getGameType();
				int gameId = room.getGameId();
				int roomId = room.getRoomId();
				Intent intent = new Intent(NewsAlarmActivity.this, ChatActivity.class);
				intent.putExtra(ChatConsts.CHAT_TYPE_TAG, ChatConsts.FROM_DISCUSS);
				intent.putExtra(ChatConsts.CREATE_CLUB_ID_TAG, room.getClubId01());
				if (myClubData.isOwner(clubId01))
					intent.putExtra(ChatConsts.CLUB_ID_TAG, clubId01);
				else
					intent.putExtra(ChatConsts.CLUB_ID_TAG, clubId02);
				intent.putExtra(ChatConsts.OPP_CLUB_ID_TAG, String.valueOf(clubId02));
				intent.putExtra(ChatConsts.GAME_TYPE, gameType);
				intent.putExtra(ChatConsts.ROOM_ID, roomId);
				intent.putExtra(ChatConsts.GAME_STATE, room.getGameState());
				intent.putExtra((gameType == 0 || gameType == 1) ? ChatConsts.CHALLENGE_ID : ChatConsts.GAME_ID, gameId);
				startActivityForResult(intent, FROM_DISCUSS_FIELD);
			}
		});
	}
	
	@Override
	public void onResume() {
		super.onResume();
		
		if (GgApplication.getInstance().getLastNotifyRoomType() == ChatConsts.CHAT_ROOM_DISCUSS) {
			GgApplication.getInstance().getChatEngine().hideNotification();
		}
		adapter.clearData();
		initRoom();
		adapter.notifyDataSetChanged();
	}
	
	private void initRoom() {
		GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
		ArrayList<ChatRoomInfo> allRooms = chatInfo.getChatRooms();
		
		for(int i = 1; i < allRooms.size() - 1; i++)
			for(int j = i + 1; j < allRooms.size(); j++) {
				if(allRooms.get(i).getLastTime().compareTo(allRooms.get(j).getLastTime()) < 0) {
					ChatRoomInfo temp;
					temp = allRooms.get(i);
					allRooms.set(i, allRooms.get(j));
					allRooms.set(j, temp);
				}
			}
		
		int isNewsOfManager = 0;
		for (ChatRoomInfo info : allRooms) {
			
			if ((isNewsOfManager != 0) && ("".equals(info.getLastContent()) || null == info.getLastContent())) continue; //2015_06_07_KYR
			if (info.getRoomType() == ChatConsts.CHAT_ROOM_MANAGER ||
				info.getRoomType() == ChatConsts.CHAT_ROOM_DISCUSS) {
				adapter.addData(info);
			}
			isNewsOfManager++;
		}
	}
	
	public void onActivityResult (int requestCode, int resultCode, Intent data) {
		if (resultCode != Activity.RESULT_OK)
			return;
		
		switch(requestCode) {
		case FROM_DISCUSS_FIELD:
			adapter = new NewsListAdapter(NewsAlarmActivity.this);
			newsListView.removeAllViewsInLayout();
			newsListView.setAdapter(adapter);
			break;
		}
		super.onActivityResult(requestCode, resultCode, data);
		return;
	}
	
	@Override
	public void onStart() {
		super.onStart();
		
		IntentFilter filter = new IntentFilter();
		filter.addAction(GgBroadCast.GOAL_GROUP_BROADCAST);
		registerReceiver(broadCastReceiver, filter);
	}
	
	private BroadcastReceiver broadCastReceiver = new BroadcastReceiver() {

		@Override
		public void onReceive(Context context, Intent intent) {
			int msg = intent.getExtras().getInt("Message");
			if (msg != GgBroadCast.MSG_UNREAD_MESSAGE)
				return;
			
			adapter.notifyDataSetChanged();
//			if (GgApplication.getInstance().getLastNotifyRoomType() == ChatConsts.CHAT_ROOM_DISCUSS) {
//				GgApplication.getInstance().getChatEngine().hideNotification();
//			}
		}
	};
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		unregisterReceiver(broadCastReceiver);
	}
}
