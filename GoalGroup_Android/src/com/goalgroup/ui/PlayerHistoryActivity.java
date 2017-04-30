package com.goalgroup.ui;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.GetPlayerHistoryTask;
import com.goalgroup.ui.adapter.PlayerHistoryAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.NetworkUtil;

public class PlayerHistoryActivity extends Activity {
	
	private TextView tvTitle;
	private Button btnBack;
	
	private ListView historyListView;
	private PlayerHistoryAdapter adapter;
	private GgProgressDialog dlg;
	private MyClubData myClubData;
	
	private int club_id;
	private boolean firstUpdate;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_player_history);
		myClubData = new MyClubData();
		
		club_id = getIntent().getExtras().getInt(ChatConsts.CLUB_ID_TAG);
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(myClubData.getNameFromID(club_id) + "-" + getString(R.string.player_history));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		adapter = new PlayerHistoryAdapter(this);
		
		historyListView = (ListView)findViewById(R.id.history_listview);
		historyListView.setDividerHeight(0);
		historyListView.setAdapter(adapter);
		
		firstUpdate = true;
	}
	
	@Override
	public void onResume() {
		super.onResume();
		
		if (firstUpdate) {
			startAttachPlayerHistory(true);
			firstUpdate = false;
			return;
		}
	}
	
	public void startAttachPlayerHistory(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(PlayerHistoryActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(PlayerHistoryActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		String playerId = GgApplication.getInstance().getUserId();
		GetPlayerHistoryTask task = new GetPlayerHistoryTask(PlayerHistoryActivity.this, adapter, playerId, club_id);
		task.execute();
	}
	
	public void stopAttachPlayerHistory() {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
	}
}
