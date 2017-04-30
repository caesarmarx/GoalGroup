package com.goalgroup.ui;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.PorterDuff.Mode;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.R;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.task.InviteGameTask;
import com.goalgroup.task.SearchPlayerListTask;
import com.goalgroup.task.SearchPlayerTask;
import com.goalgroup.ui.adapter.PlayFilterResultAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.CustomSwipeListView;
import com.goalgroup.ui.view.GgListView;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.utils.NetworkUtil;

public class PlayerMarketActivity extends Activity implements XListView.IXListViewListener {

	private final int FROM_INVITE_GAME = 1;
	private final int FROM_PLAYER_SEARCH = 0;
	private final int FROM_PLAYER_LIST = 2;
	
	private boolean selAgeConds[];
	private boolean selPosConds[];
	private boolean selDayConds[];
	private boolean selAreaConds[];
	
	private TextView tvTitle;
	private Button btnBack;
	private Button btnSearch;
	private ImageView btnSearchImg;
	private TextView btnText;
	private int request;
	private Object[] param;
	
	
	private GgListView resultListView;
//	private CustomSwipeMenuItem item1;
//	private CustomSwipeMenuItem item2;
//	private CustomSwipeMenuItem item3;
	private PlayFilterResultAdapter adapter;
	private GgProgressDialog dlg;
//	private MyClubData myClubData;
	
	private boolean firstUpdate;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_player_market);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.player_market));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		btnText = (TextView) findViewById(R.id.common_action_text);
		btnText.setVisibility(View.GONE);
		
		selAgeConds = new boolean[0];
		selPosConds = new boolean[0];
		selDayConds = new boolean[0];
		selAreaConds = new boolean[0];
		
//		myClubData = new MyClubData();
		request = FROM_PLAYER_LIST;
		btnSearch = (Button)findViewById(R.id.btn_view_more);
		btnSearchImg = (ImageView)findViewById(R.id.top_img);
		btnSearch.setVisibility(View.VISIBLE);
		btnSearchImg.setVisibility(View.VISIBLE);
//		btnSearch.setText(R.string.filter);
		btnSearchImg.setBackgroundResource(R.drawable.search_ico);
		btnSearch.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View view) {
				Intent intent = new Intent(PlayerMarketActivity.this, PlayerMarketSearchActivity.class);
				intent.putExtra("sel_age", selAgeConds);
				intent.putExtra("sel_pos", selPosConds);
				intent.putExtra("sel_day", selDayConds);
				intent.putExtra("sel_area", selAreaConds);
				startActivityForResult(intent, FROM_PLAYER_SEARCH);
			}
		});

		adapter = new PlayFilterResultAdapter(this);
		
		resultListView = (GgListView)findViewById(R.id.result_listview);
		resultListView.setPullLoadEnable(true);
		resultListView.setPullRefreshEnable(false);
		resultListView.setXListViewListener(this, 0);
		resultListView.getDivider().setColorFilter(Color.WHITE, Mode.ADD);
		resultListView.setDividerHeight(10);
//		resultListView.setPadding(0);
		resultListView.setAdapter(adapter);
				
//		resultListView.setOnSwipeListener(new OnSwipeListener() {
//			
//			@Override
//			public void onSwipeStart(int position) {
//			}
//			
//			@Override
//			public void onSwipeEnd(int position) {
//				if (resultListView.isOpened()){
//				}
//			}
//		});
		// create menu and set menu creator to listview
//		CustomSwipeMenuCreator creator = new CustomSwipeMenuCreator(){
//
//			@Override
//			public void create(CustomSwipeMenu menu) {
//				item1 = new CustomSwipeMenuItem(getApplicationContext());
//				item1.setBackground(R.drawable.more_menu_top);
//				item1.setWidth(ListViewUtil.dp2px(60, getResources()));
//				item1.setHeight(ListViewUtil.dp2px(LayoutParams.WRAP_CONTENT, getResources()));
//				item1.setIcon(R.drawable.market_item1);
//				menu.addMenuItem(item1);
//				
//				item2 = new CustomSwipeMenuItem(getApplicationContext());
//				item2.setBackground(R.drawable.more_menu_normal);
//				item2.setWidth(ListViewUtil.dp2px(60, getResources()));
//				item2.setHeight(ListViewUtil.dp2px(LayoutParams.WRAP_CONTENT, getResources()));
//				item2.setIcon(R.drawable.market_item2);
//				menu.addMenuItem(item2);
//				
//				item3 = new CustomSwipeMenuItem(getApplicationContext());
//				item3.setBackground(R.drawable.more_menu_bottom);
//				item3.setWidth(ListViewUtil.dp2px(60, getResources()));
//				item3.setHeight(ListViewUtil.dp2px(LayoutParams.WRAP_CONTENT, getResources()));
//				item3.setIcon(R.drawable.market_item3);
//				menu.addMenuItem(item3);
//			}
//		};
//		resultListView.setMenuCreator(creator);
		
		// set menuitem click listener
//		resultListView.setOnMenuItemClickListener(new OnMenuItemClickListener() {
//			@Override
//			public boolean onMenuItemClick(int position, CustomSwipeMenu menu, int index) {
//				PlayerFilterResultItem data = (PlayerFilterResultItem)adapter.getItem(position);
//				int curUserID = Integer.valueOf(GgApplication.getInstance().getUserId());
//				if (data.getUserID() == curUserID) {
//					Toast.makeText(PlayerMarketActivity.this, getString(R.string.you), Toast.LENGTH_SHORT).show();
//					return false;
//				}
//				switch (index) {
//				case 0:
//					adapter.showTeamMultiSelDialog(PlayFilterResultAdapter.BTN_RECOMMEND, 
//								(PlayerFilterResultItem)adapter.getItem(position));
//					break;
//				case 1:
//					if (!myClubData.isOwner()){
//						Toast.makeText(PlayerMarketActivity.this, getString(R.string.no_manager), Toast.LENGTH_SHORT).show();
//						return false;
//					}
//					adapter.showTeamSelDialog(PlayFilterResultAdapter.BTN_TEMP_INVITE, 
//							(PlayerFilterResultItem)adapter.getItem(position));
//					break;
//				case 2:
//					if (!myClubData.isOwner()){
//						Toast.makeText(PlayerMarketActivity.this, getString(R.string.no_manager), Toast.LENGTH_SHORT).show();
//						return false;
//					}
//					adapter.showTeamMultiSelDialog(PlayFilterResultAdapter.BTN_INVITE, 
//							(PlayerFilterResultItem)adapter.getItem(position));
//					break;
//				}
//				return false;
//			}
//		});
		
		firstUpdate = true;
	}
	
	@Override
	public void onResume() {
		super.onResume();
		
		if (firstUpdate) {
			startAttachPlayers(true);
			firstUpdate = false;
		}
		
		return;
	}

	@Override
	public void onRefresh(int id) {
		adapter.clearData();
		adapter.notifyDataSetChanged();
		if (request == FROM_PLAYER_LIST)
			startAttachPlayers(true);
		else
			startSearchPlayerList(true, param);
		return;
	}

	@Override
	public void onLoadMore(int id) {
		if (request == FROM_PLAYER_LIST)
			startAttachPlayers(false);
		else
			startSearchPlayerList(false, param);
		return;
	}
	
	@Override
	public void onActivityResult (int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		
		if (resultCode != Activity.RESULT_OK)
			return;
		
		switch (requestCode) {
		case FROM_INVITE_GAME:
			invGameId = data.getExtras().getInt(CommonConsts.GAME_ID_TAG);
			startInviteGame(invUserId, invClubId, invGameId);
			break;
		case FROM_PLAYER_SEARCH:
			request = FROM_PLAYER_SEARCH;
			param = new Object[5];
			param[0] = data.getExtras().getInt("min_age");
			param[1] = data.getExtras().getInt("max_age");
			param[2] = data.getExtras().getInt("position");
			param[3] = data.getExtras().getInt("activity_time");
			param[4] = data.getExtras().getString("activity_area");
			request = FROM_PLAYER_SEARCH;
			
			selAgeConds = data.getExtras().getBooleanArray("sel_age");
			selPosConds = data.getExtras().getBooleanArray("sel_pos");
			selDayConds = data.getExtras().getBooleanArray("sel_day");
			selAreaConds = data.getExtras().getBooleanArray("sel_area");
			
			adapter.clearData();
			startSearchPlayerList(true, param);
			break;
		}
	}
	
	public void startAttachPlayers(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(PlayerMarketActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(PlayerMarketActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		SearchPlayerTask task = new SearchPlayerTask(this, adapter);
		task.execute();
	}
	
	public void stopAttachPlayers(boolean hasMore) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
		resultListView.setPullLoadEnable(hasMore);
	}
	
	private int invClubId;
	private int invUserId;
	private int invGameId;
	
	public void selectInviteGame(int clubId, int userId) {
		invClubId = clubId;
		invUserId = userId;
		Intent intent = new Intent(PlayerMarketActivity.this, GameScheduleActivity.class);
		intent.putExtra(CommonConsts.SCHEDULE_FROM_TAG, CommonConsts.SCHEDULE_FROM_INVT);
		intent.putExtra(ChatConsts.CLUB_ID_TAG, clubId);
		startActivityForResult(intent, FROM_INVITE_GAME);
	}
	
	public void startInviteGame(int userId, int clubId, int gameId) {
		if (!NetworkUtil.isNetworkAvailable(PlayerMarketActivity.this))
			return;
		
		dlg = new GgProgressDialog(PlayerMarketActivity.this, getString(R.string.wait));
		dlg.show();
		
		InviteGameTask task = new InviteGameTask(this, userId, clubId, gameId);
		task.execute();
	}
	
	public void stopInviteGame(int result) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		int[] notices = {
			R.string.invite_game_fail, R.string.invite_game_success, R.string.invite_game_repeat, R.string.invite_game_already_member
		};		
		Toast.makeText(PlayerMarketActivity.this, getString(notices[result]), Toast.LENGTH_SHORT).show();
		
		return;
	}
	
	public void startSearchPlayerList(boolean showdlg, Object[] param) {
		if (!NetworkUtil.isNetworkAvailable(this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(this, getString(R.string.wait));
			dlg.show();
		}
		
		SearchPlayerListTask task = new SearchPlayerListTask(this, adapter, param);
		task.execute();
	}
	
	public void stopSearchPlayerList(boolean hasMore) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
		resultListView.setPullLoadEnable(hasMore);
	}
}
