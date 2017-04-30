package com.goalgroup.ui;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.PorterDuff.Mode;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.goalgroup.R;
import com.goalgroup.task.SearchClubListTask;
import com.goalgroup.task.SearchClubTask;
import com.goalgroup.ui.adapter.ClubFilterResultAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.GgListView;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.utils.NetworkUtil;

import cn.jpush.android.api.JPushInterface;

public class ClubMarketActivity extends Activity implements XListView.IXListViewListener {
	private final int CLUB_INFO = 0;
	private final int SEARCH = 1;
	
	private boolean selAgeConds[];
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
	private ClubFilterResultAdapter adapter;
	private GgProgressDialog dlg;
	
	private boolean firstUpdate;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_club_market);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.club_market));
		
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
		selDayConds = new boolean[0];
		selAreaConds = new boolean[0];
		
		request = CLUB_INFO;
		
		btnSearch = (Button)findViewById(R.id.btn_view_more);
		btnSearchImg = (ImageView)findViewById(R.id.top_img);
		btnSearch.setVisibility(View.VISIBLE);
		btnSearchImg.setVisibility(View.VISIBLE);
//		btnSearch.setText(R.string.filter);
		btnSearchImg.setBackgroundResource(R.drawable.search_ico);
		btnSearch.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View view) {
				Intent intent = new Intent(ClubMarketActivity.this, ClubMarketSearchActivity.class);
				intent.putExtra("sel_age", selAgeConds);
				intent.putExtra("sel_day", selDayConds);
				intent.putExtra("sel_area", selAreaConds);
				startActivityForResult(intent, SEARCH);
			}
		});
		
		adapter = new ClubFilterResultAdapter(this);
		
		resultListView = (GgListView)findViewById(R.id.result_listview);
		resultListView.setPullLoadEnable(true);
		resultListView.setPullRefreshEnable(false);
		resultListView.setXListViewListener(this, 0);
		resultListView.getDivider().setColorFilter(Color.WHITE, Mode.ADD);
		resultListView.setDividerHeight(10);
//		resultListView.setPadding(0);
		resultListView.setAdapter(adapter);
		
		// create menu and set menu creator to listview
//		CustomSwipeMenuCreator creator = new CustomSwipeMenuCreator(){
//
//			@Override
//			public void create(CustomSwipeMenu menu) {
//				CustomSwipeMenuItem item = new CustomSwipeMenuItem(getApplicationContext());
//				item.setBackground(R.drawable.more_menu_top);
//				item.setWidth(ListViewUtil.dp2px(60, getResources()));
//				item.setIcon(R.drawable.market_club1);
//				menu.addMenuItem(item);
//				
//				item = new CustomSwipeMenuItem(getApplicationContext());
//				item.setBackground(R.drawable.more_menu_bottom);
//				item.setWidth(ListViewUtil.dp2px(60, getResources()));
//				item.setIcon(R.drawable.market_club2);
//				menu.addMenuItem(item);
//			}
//		};
//		resultListView.setMenuCreator(creator);
		
		// set menuitem click listener
//		resultListView.setOnMenuItemClickListener(new OnMenuItemClickListener() {
//			@Override
//			public boolean onMenuItemClick(int position, CustomSwipeMenu menu, int index) {
//				ClubFilterResultItem selectedItem = (ClubFilterResultItem)adapter.getItem(position);
//				switch (index) {
//				case 0:
//					Object[] registerInfo = new Object[2];
//					registerInfo[0] = GgApplication.getInstance().getUserId();
//					registerInfo[1] = String.valueOf(selectedItem.getClubID());
//					adapter.startRegisterUserToClub(true, registerInfo);
//					break;
//				case 1:
//					MyClubData mClubData = new MyClubData();
//					GgApplication.getInstance().setChallFlag(false);
//					if (!mClubData.isOwner()){
//						Toast.makeText(ClubMarketActivity.this, ClubMarketActivity.this.getString(R.string.no_manager), Toast.LENGTH_LONG).show();
//						break;
//					}
//					if (!mClubData.isManagerOfClub(selectedItem.getClubID())) {
//						Intent intent = new Intent(ClubMarketActivity.this, NewChallengeActivity.class);
//						intent.putExtra(GgIntentParams.CLUB_NAME, selectedItem.getName());
//						intent.putExtra(GgIntentParams.CLUB_ID, String.valueOf(selectedItem.getClubID()));
//						intent.putExtra("type", CommonConsts.NEW_CHALLENGE);
//						intent.putExtra("challType", CommonConsts.PROCLAIM_GAME);
//						ClubMarketActivity.this.startActivity(intent);
//					} else {
//						Toast.makeText(ClubMarketActivity.this, ClubMarketActivity.this.getString(R.string.own_club), Toast.LENGTH_LONG).show();
//					}
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
			startAttachClubs(true);
			firstUpdate = false;
		}
		return;
	}

	@Override
	public  void onStop() {
		super.onStop();
		if (isFinishing()) {
			Log.d("onStop", "Finishing...");
			JPushInterface.clearAllNotifications(getApplicationContext());
			JPushInterface.stopPush(getApplicationContext());
		}
	}
	@Override
	public void onRefresh(int id) {
		adapter.clearData();
		adapter.notifyDataSetChanged();
		
		if (request == CLUB_INFO)
			startAttachClubs(true);
		else
			startSearchClubList(true, param);
		return;
	}

	@Override
	public void onLoadMore(int id) {
		if (request == CLUB_INFO)
			startAttachClubs(false);
		else
			startSearchClubList(false, param);
	}
	
	public void startAttachClubs(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(ClubMarketActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ClubMarketActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		SearchClubTask task = new SearchClubTask(this, adapter);
		task.execute();
	}
	
	public void stopAttachClubs(boolean hasMore) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
		resultListView.setPullLoadEnable(hasMore);
	}
	
	public void onActivityResult (int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		
		if(resultCode != RESULT_OK)
			return ;
		
		switch(requestCode) {
		case SEARCH:
			param = new Object[4];
			param[0] = data.getExtras().getInt("min_age");
			param[1] = data.getExtras().getInt("max_age");
			param[2] = data.getExtras().getInt("activity_time");
			param[3] = data.getExtras().getString("activity_area");
			request = SEARCH;
			
			selAgeConds = data.getExtras().getBooleanArray("sel_age");
			selDayConds = data.getExtras().getBooleanArray("sel_day");
			selAreaConds = data.getExtras().getBooleanArray("sel_area");
			
			adapter.clearData();
			adapter.notifyDataSetChanged();
			startSearchClubList(true, param);
			break;
		case CLUB_INFO:
			request = CLUB_INFO;
			adapter.clearData();
			adapter.notifyDataSetChanged();
			startAttachClubs(true);
			break;
		}
	}
	
	public void startSearchClubList(boolean showdlg, Object[] param) {
		if (!NetworkUtil.isNetworkAvailable(this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(this, getString(R.string.wait));
			dlg.show();
		}
		
		SearchClubListTask task = new SearchClubListTask(this, adapter, param);
		task.execute();
	}
	
	public void stopSearchClubList(boolean hasMore) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
		resultListView.setPullLoadEnable(hasMore);
	}
	
}
