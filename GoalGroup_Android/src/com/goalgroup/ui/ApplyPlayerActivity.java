package com.goalgroup.ui;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

import com.goalgroup.R;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.task.GetApplyPlayerTask;
import com.goalgroup.ui.adapter.ApplyPlayerAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.GgListView;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.utils.NetworkUtil;

import cn.jpush.android.api.JPushInterface;

public class ApplyPlayerActivity extends Activity implements XListView.IXListViewListener {
	
	private TextView tvTitle;
	private Button btnBack;
	
	private GgListView scheduleListView;
	private ApplyPlayerAdapter adapter;
	private GgProgressDialog dlg;
	
	private boolean firstUpdate;
	
	private int clubId;
	private int gameId;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_apply_player);
		
		clubId = getIntent().getExtras().getInt(ChatConsts.CLUB_ID_TAG);
		gameId = getIntent().getExtras().getInt(ChatConsts.GAME_ID);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.game_schedule));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		adapter = new ApplyPlayerAdapter(this);
		
		scheduleListView = (GgListView)findViewById(R.id.applyPlayer_listview);
		scheduleListView.setPullLoadEnable(true);
		scheduleListView.setPullRefreshEnable(false);
		scheduleListView.setXListViewListener(this, 0);
		scheduleListView.setAdapter(adapter);
		
		firstUpdate = true;
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
	public void onResume() {
		super.onResume();
		
		if (firstUpdate) {
			startAttachPlayers(true);
			firstUpdate = false;
		}
	}

	@Override
	public void onRefresh(int id) {
		adapter.clearData();
		adapter.notifyDataSetChanged();
		
		startAttachPlayers(true);
		return;
	}

	@Override
	public void onLoadMore(int id) {
		startAttachPlayers(false);
	}
	
	private boolean checkNetworkStatus(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(ApplyPlayerActivity.this))
			return false;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ApplyPlayerActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		return true;
	}
	
	public void startAttachPlayers(boolean showdlg) {
		if (checkNetworkStatus(showdlg) == false)
			return;
		
		GetApplyPlayerTask task = new GetApplyPlayerTask(this, adapter, clubId, gameId, CommonConsts.APPLY_LIST);
		task.execute();
	}
	
	public void stopAttachPlayers(boolean hasMore) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
		scheduleListView.setPullLoadEnable(hasMore);
	}
}
