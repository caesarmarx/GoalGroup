package com.goalgroup.ui;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.R;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.DeleteChallTask;
import com.goalgroup.task.GetClubChallTask;
import com.goalgroup.ui.adapter.ClubChallengeAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.CustomSwipeListView;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.utils.NetworkUtil;

import cn.jpush.android.api.JPushInterface;

public class ClubChallengesActivity extends Activity 
	implements OnClickListener, XListView.IXListViewListener{
	
	private TextView tvTitle;
	private Button btnBack;
	
	private XListView challListView;
	private ClubChallengeAdapter adapter;
	private GgProgressDialog dlg;
	private MyClubData myClubData;
	
	private boolean firstUpdate;
	
	private int clubId;
	public int challType;
	private int startType;
	private int delType;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_club_challenges);
		
		myClubData = new MyClubData();
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.challenge));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		firstUpdate = true;
		
		clubId = getIntent().getExtras().getInt(ChatConsts.CLUB_ID_TAG);
		challType = getIntent().getExtras().getInt(CommonConsts.CHALL_TYPE_TAG);
		startType = getIntent().getExtras().getInt(CommonConsts.PROCLAIM_START_TYPE);
		 
		adapter = new ClubChallengeAdapter(ClubChallengesActivity.this, clubId);
		
		challListView = (XListView)findViewById(R.id.challge_listview);
		challListView.setPullLoadEnable(true);
		challListView.setPullRefreshEnable(false);
//		challListView.setXListViewListener(this, 0);
		challListView.setAdapter(adapter);
		
		// create menu and set menu creator to listview
//		CustomSwipeMenuCreator creator = new CustomSwipeMenuCreator(){
//
//			@Override
//			public void create(CustomSwipeMenu menu) {
//				CustomSwipeMenuItem item = new CustomSwipeMenuItem(getApplicationContext());
//				item.setBackground(new ColorDrawable(Color.rgb(0xFF, 0xFF,0xFF)));
//				item.setWidth(ListViewUtil.dp2px(60, getResources()));
//				item.setIcon(R.drawable.invitiation_delete);
//				menu.addMenuItem(item);
//			}
//		};
//		challListView.setMenuCreator(creator);
//		
//		// set menuitem click listener
//		challListView.setOnMenuItemClickListener(new OnMenuItemClickListener() {
//			@Override
//			public boolean onMenuItemClick(int position, CustomSwipeMenu menu, int index) {
//				ClubChallengeItem data = (ClubChallengeItem) adapter.getItem(position);
//				if (!myClubData.isOwner(Integer.valueOf(data.getClubId01()))){
//					Toast.makeText(ClubChallengesActivity.this, getString(R.string.no_manager), Toast.LENGTH_SHORT).show();
//					return false;
//				}
//				switch (index) {
//				case 0:
//					adapter.procDelete(position);
//					break;
//				}
//				return false;
//			}
//		});
		
		if (challType == CommonConsts.CHALL_TYPE_MY_CHALLENGE){
			delType = CommonConsts.CHALL_TYPE_ALL_CHALLENGE;
			tvTitle.setText(myClubData.getNameFromID(clubId) + "发布的" + getString(R.string.challenge));
		}
		else if (challType == CommonConsts.CHALL_TYPE_ALL_PROCLAIM){
			delType = challType;
			tvTitle.setText(myClubData.getNameFromID(clubId) + "的" + getString(R.string.official_note));
		}
	}
	
	@Override
	public void onResume() {
		super.onResume();
		
		if (firstUpdate) {
			startAttachChallenges(true);
			firstUpdate = false;
		}
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
	public void onClick(View view) {		
	}

	@Override
	public void onRefresh(int id) {
	}

	@Override
	public void onLoadMore(int id) {
		startAttachChallenges(false);
		return;
	}
	
	public void startAttachChallenges(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(ClubChallengesActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ClubChallengesActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetClubChallTask task = new GetClubChallTask(ClubChallengesActivity.this, adapter, challType, startType, Integer.toString(clubId));
		task.execute();
	}
	
	public void stopAttachChallenges(boolean hasMore) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
		adapter.setChallType(challType);
		challListView.setPullLoadEnable(hasMore);
	}
	
	private int selIndex;
	public void startDeleteChallenge(boolean showdlg, int index, int gameId) {
		if (!NetworkUtil.isNetworkAvailable(ClubChallengesActivity.this))
			return;
		
		selIndex = index;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ClubChallengesActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		DeleteChallTask task = new DeleteChallTask(ClubChallengesActivity.this, delType, clubId, gameId);
		task.execute();
	}
	
	public void stopDeleteChallenge(int data) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (data == GgHttpErrors.HTTP_POST_FAIL) {
			Toast.makeText(ClubChallengesActivity.this, R.string.delete_fail, Toast.LENGTH_SHORT).show();
			return;
		}
		
		Toast.makeText(ClubChallengesActivity.this, R.string.delete_success, Toast.LENGTH_SHORT).show();

		adapter.deleteData(selIndex);
		adapter.notifyDataSetChanged();
	}
}
