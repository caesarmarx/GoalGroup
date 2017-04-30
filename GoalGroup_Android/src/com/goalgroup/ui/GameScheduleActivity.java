package com.goalgroup.ui;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.info.GgChatInfo;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.model.ScheduleItem;
import com.goalgroup.task.GetGameScheduleTask;
import com.goalgroup.task.SetApplyGameTask;
import com.goalgroup.ui.adapter.GameScheduleAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.CustomSwipeListView;
import com.goalgroup.ui.view.CustomSwipeListView.OnMenuItemClickListener;
import com.goalgroup.ui.view.CustomSwipeMenu;
import com.goalgroup.ui.view.CustomSwipeMenuCreator;
import com.goalgroup.ui.view.CustomSwipeMenuItem;
import com.goalgroup.utils.ListViewUtil;
import com.goalgroup.utils.NetworkUtil;

public class GameScheduleActivity extends Activity implements CustomSwipeListView.IXListViewListener {
	
	private TextView tvTitle;
	private Button btnBack;
	
	private CustomSwipeListView scheduleListView;
	private GameScheduleAdapter adapter;
	private GgProgressDialog dlg;
	private MyClubData myClubData;
	
	private boolean firstUpdate;
	
	private int fromType;
	private int clubId;
	private int userId;
	private int gameId;
	private int index;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_game_schedule);
		
		myClubData = new MyClubData();
		
		fromType = getIntent().getExtras().getInt(CommonConsts.SCHEDULE_FROM_TAG);
		clubId = getIntent().getExtras().getInt(ChatConsts.CLUB_ID_TAG);
		userId = getIntent().getExtras().getInt(ChatConsts.REQ_USER_ID);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		
		if (fromType == CommonConsts.SCHEDULE_FROM_CHAT)
			tvTitle.setText(myClubData.getNameFromID(clubId) + "-" + getString(R.string.game_schedule));
		else 
			tvTitle.setText(getString(R.string.game_schedule));
			
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		adapter = new GameScheduleAdapter(this);
		adapter.setType(fromType);
		adapter.setClubId(clubId);
		
		scheduleListView = (CustomSwipeListView)findViewById(R.id.schedule_listview);
		scheduleListView.setPullLoadEnable(true);
		scheduleListView.setPullRefreshEnable(false);
		scheduleListView.setXListViewListener(this, 0);
		scheduleListView.setPadding(0);
		scheduleListView.setDividerHeight(10);
		//scheduleListView.setMenuPos(0.415f, 0.87f);
		scheduleListView.setAdapter(adapter);
		scheduleListView.setRadius(true);
		
		if (fromType == CommonConsts.SCHEDULE_FROM_CHAT){	
		// create menu and set menu creator to listview
			CustomSwipeMenuCreator creator = new CustomSwipeMenuCreator(){
	
				@Override
				public void create(CustomSwipeMenu menu) {
					CustomSwipeMenuItem item = new CustomSwipeMenuItem(getApplicationContext());
					
					item = new CustomSwipeMenuItem(getApplicationContext());
					item.setBackground(R.drawable.more_menu_top);
					item.setWidth(ListViewUtil.dp2px(70, getResources()));
					item.setIcon(R.drawable.schedule_func_01);
					item.setGravity(Gravity.TOP);
					item.setTitle(getResources().getString(R.string.sign));
					item.setTitleColor(getResources().getColor(R.color.white));
					menu.addMenuItem(item);
	
					item = new CustomSwipeMenuItem(getApplicationContext());
					item.setBackground(R.drawable.more_menu_bottom);
					item.setWidth(ListViewUtil.dp2px(70, getResources()));
					item.setIcon(R.drawable.schedule_func_02);
					item.setGravity(Gravity.TOP);
					item.setTitle(getResources().getString(R.string.discuss));
					item.setTitleColor(getResources().getColor(R.color.white));
					menu.addMenuItem(item);
				}
			};
			scheduleListView.setMenuCreator(creator);
		
			// set menuitem click listener
			scheduleListView.setOnMenuItemClickListener(new OnMenuItemClickListener() {
				@Override
				public boolean onMenuItemClick(int position, CustomSwipeMenu menu, int index) {
					ScheduleItem item = (ScheduleItem)adapter.getItem(position);
					if (item.getState() == CommonConsts.GAME_STATE_CANCELED) {
						Toast.makeText(GameScheduleActivity.this, getString(R.string.game_canceled), Toast.LENGTH_SHORT).show();
						return false;
					} else if (item.getType() == CommonConsts.CUSTOM_GAME){
						Toast.makeText(GameScheduleActivity.this, getString(R.string.custom_game), Toast.LENGTH_SHORT).show();
						return false;
					}
					
					switch (index) {
					case 0:	// apply menu
						if (item.getState() == CommonConsts.GAME_STATE_FINISHED) {
							Toast.makeText(GameScheduleActivity.this, getString(R.string.game_finished), Toast.LENGTH_SHORT).show();
							return false;
						}
						
						applyGame(item.getGameId(), position);
						break;
					case 1:	// chat menu
						if (myClubData.isOwner(clubId))
							moveDiscussChat(item, GameScheduleActivity.this.clubId, adapter.getOppClubId(item), item.getGameId(), item.getState());
						else 
							Toast.makeText(GameScheduleActivity.this, getString(R.string.no_manager), Toast.LENGTH_SHORT).show();
						break;
					}
					return false;
				}
			});
		}
		
		scheduleListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
			
			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				//ScheduleItem item = (ScheduleItem)adapter.getItem(position - 1);
//				if (item.getState() == CommonConsts.GAME_STATE_FINISHED || item.getState() == CommonConsts.GAME_STATE_CANCELED) {
				if (fromType != CommonConsts.SCHEDULE_FROM_CHAT) 
					return;
				ScheduleItem data = (ScheduleItem)adapter.getItem(position-1);
				Intent intent = new Intent(GameScheduleActivity.this, GameDetailActivity.class);
				intent.putExtra("game_id", data.getGameId());
				intent.putExtra("club_id", clubId);
				intent.putExtra("club01_id", data.getClubId01());
				intent.putExtra("club02_id", data.getClubId02());
				intent.putExtra("club01_mark", data.getClubMark01());
				intent.putExtra("club02_mark", data.getClubMark02());
				intent.putExtra("club01_name", data.getClubName01());
				intent.putExtra("club02_name", data.getClubName02());
				intent.putExtra("player_count", data.getPlayerCounts());
				intent.putExtra("game_date", data.getDate());
				intent.putExtra("game_time", data.getTime());
				intent.putExtra("game_wday", data.getWDay());
				intent.putExtra("stadium", data.getStadiumAddress());
				intent.putExtra("state", data.getState());
				intent.putExtra("remain_time", data.getRemainTime());
				if (data.getState() == CommonConsts.GAME_STATE_FINISHED || data.getState() == CommonConsts.GAME_STATE_CANCELED)
					intent.putExtra("result", adapter.getResult(data));
				GameScheduleActivity.this.startActivity(intent);
//				}
			}
		});
		
		firstUpdate = true;
	}
	
	@Override
	public void onResume() {
		super.onResume();
		
		if (firstUpdate) {
			startAttachSchedule(true, fromType);
			firstUpdate = false;
		}
	}

	@Override
	public void onRefresh(int id) {
		adapter.clearData();
		adapter.notifyDataSetChanged();
		
		startAttachSchedule(true, fromType);
		return;
	}

	@Override
	public void onLoadMore(int id) {
		startAttachSchedule(false, fromType);
	}
	
	private boolean checkNetworkStatus(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(GameScheduleActivity.this))
			return false;
		
		if (showdlg) {
			dlg = new GgProgressDialog(GameScheduleActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		return true;
	}
	
	public void startAttachSchedule(boolean showdlg, int from_type) {
		if (checkNetworkStatus(showdlg) == false)
			return;
		
		GetGameScheduleTask task = new GetGameScheduleTask(this, adapter, clubId, from_type);
		task.execute();
	}
	
	public void stopAttachSchedule(boolean hasMore) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		adapter.notifyDataSetChanged();
		scheduleListView.setPullLoadEnable(hasMore);
	}
	
	public void startApplyGame(boolean showDlg) {
		if (checkNetworkStatus(showDlg) == false)
			return;
		
		SetApplyGameTask task = new SetApplyGameTask(this, clubId, gameId, userId);
		task.execute();
	}
	
	public void stopApplyGame(int success) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (success != 0) {
			int num = 0;
			if (success == 1)
				num = 1;
			else if(success == 2)
				num = -1;
			adapter.setPlayerNumber(clubId, index, num);
			adapter.notifyDataSetChanged();
			if (success == 1)
				Toast.makeText(this, getString(R.string.apply_game_success),Toast.LENGTH_SHORT).show();
			else if(success == 2)
				Toast.makeText(this, getString(R.string.reject_game_success),Toast.LENGTH_SHORT).show();
			else if(success == 3)
				Toast.makeText(this, getString(R.string.reject_reason_game_cancel),Toast.LENGTH_SHORT).show();
			else if(success == 4) {
				ScheduleItem item = (ScheduleItem)adapter.getItem(index);
				String oppClubName = "";
				if (Integer.valueOf(item.getClubId01()) == clubId)
					oppClubName = item.getClubName02();
				else 
					oppClubName = item.getClubName01();
				String toastMsg = getString(R.string.apply_game_by_other_club_prefix) + oppClubName + getString(R.string.apply_game_by_other_club_suffix);
				Toast.makeText(this, toastMsg, Toast.LENGTH_SHORT).show();
			}
		} else {
			Toast.makeText(this, getString(R.string.apply_game_failed),Toast.LENGTH_SHORT).show();
		}
	}
	
	public void inviteGame(int gameId) {
		getIntent().putExtra(CommonConsts.GAME_ID_TAG, gameId);
		setResult(RESULT_OK, getIntent());
		finish();
	}
	
	private void moveDiscussChat(ScheduleItem item, int clubId, int oppClubId, int gameId, int state) {
		GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
		int room_id = chatInfo.getDiscussRoomId(Integer.valueOf(item.getClubId01()), 
				Integer.valueOf(item.getClubId02()), 2, gameId);
		
		Intent intent = new Intent(GameScheduleActivity.this, ChatActivity.class);
		intent.putExtra(ChatConsts.CHAT_TYPE_TAG, ChatConsts.FROM_DISCUSS);
		intent.putExtra(ChatConsts.CREATE_CLUB_ID_TAG, Integer.valueOf(item.getClubId01()));
		intent.putExtra(ChatConsts.CLUB_ID_TAG, clubId);
		intent.putExtra(ChatConsts.OPP_CLUB_ID_TAG, String.valueOf(oppClubId));
		intent.putExtra(ChatConsts.GAME_ID, gameId);
		intent.putExtra(ChatConsts.ROOM_ID, room_id);
		intent.putExtra(ChatConsts.GAME_STATE, state);
		startActivityForResult(intent, ChatConsts.FROM_SCHEDULE);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode != Activity.RESULT_OK)
			return;

		switch (requestCode) {
		case ChatConsts.FROM_SCHEDULE:
			onRefresh(0);
			break;
		}
	}
	
	private void applyGame(int gameId, int position) {
		this.gameId = gameId;
		this.index = position;
		startApplyGame(true);
	}
}
