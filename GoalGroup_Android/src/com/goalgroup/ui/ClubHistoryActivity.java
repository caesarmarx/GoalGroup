package com.goalgroup.ui;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import com.goalgroup.R;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.GetClubHistoryTask;
import com.goalgroup.ui.adapter.ClubHistoryAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.NetworkUtil;

import cn.jpush.android.api.JPushInterface;

public class ClubHistoryActivity extends Activity {
	
	private TextView tvTitle;
	private Button btnBack;
	
	private ListView historyListView;
	private ClubHistoryAdapter adapter;	
	private GgProgressDialog dlg;
	private MyClubData myClubData;
	
	private int clubIds;
	private boolean firstUpdate;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_club_history);
		myClubData = new MyClubData();
		
		clubIds = getIntent().getExtras().getInt(ChatConsts.CLUB_ID_TAG);
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(myClubData.getNameFromID(clubIds) + "-"
				+ getString(R.string.club_history));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		adapter = new ClubHistoryAdapter(this);
		
		historyListView = (ListView)findViewById(R.id.history_listview);
		historyListView.setDividerHeight(0);
		historyListView.setAdapter(adapter);
		
		firstUpdate = true;
	}
	
	@Override
	public void onResume() {
		super.onResume();
		
		if (firstUpdate) {
			startAttachClubHistory(true);
			firstUpdate = false;
			return;
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
	public void startAttachClubHistory(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(ClubHistoryActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ClubHistoryActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetClubHistoryTask task = new GetClubHistoryTask(ClubHistoryActivity.this, adapter, String.valueOf(clubIds));
		task.execute();
	}
	
	public void stopAttachClubHistory() {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
	}
}
