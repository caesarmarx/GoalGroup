package com.goalgroup.ui;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.task.AcceptInvGameTask;
import com.goalgroup.task.GetInvGameTask;
import com.goalgroup.ui.adapter.InviteGameAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.GgListView;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;

public class InvGameActivity extends Activity implements XListView.IXListViewListener {
	
	private TextView tvTitle;
	private Button btnBack;
	
	private GgListView invListView;
	private InviteGameAdapter adapter;
	private GgProgressDialog dlg;
	
	private boolean firstUpdate;
	private int position;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_inv_game);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.temp_invitation));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				setResult(RESULT_OK, getIntent());
				finish();
			}
		});
		
		adapter = new InviteGameAdapter(this);
		
		invListView = (GgListView)findViewById(R.id.inv_game_listview);
		invListView.setPullLoadEnable(true);
		invListView.setPullRefreshEnable(false);
		invListView.setXListViewListener(this, 0);
		invListView.setDividerHeight(10);
		invListView.setAdapter(adapter);
		
		firstUpdate = true;
	}

	public void onResume() {
		super.onResume();
		
		if (firstUpdate) {
			startAttachInvs(true);
			firstUpdate = false;
		}
	}
	
	@Override
	public void onRefresh(int id) {
	}

	@Override
	public void onLoadMore(int id) {
		startAttachInvs(false);
	}
	
	public void startAttachInvs(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(InvGameActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(InvGameActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetInvGameTask task = new GetInvGameTask(this, adapter);
		task.execute();
	}
	
	public void stopAttachInvs(boolean hasMore) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
		invListView.setPullLoadEnable(hasMore);
	}
	
	private int acceptType;

	public void startProcInvGame(int type, int clubId, int gameId) {
		if (!NetworkUtil.isNetworkAvailable(InvGameActivity.this))
			return;
		
		dlg = new GgProgressDialog(InvGameActivity.this, getString(R.string.wait));
		dlg.show();
		
		acceptType = type - 1;
		AcceptInvGameTask task = new AcceptInvGameTask(this, clubId, gameId, type);
		task.execute();
	}
	
	public void stopProcInvGame(int result, String data) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		int[] notice_succ_ids = {
			R.string.inv_game_accept_succ, R.string.inv_game_delete_succ
		};
		
		int[] notice_fail_ids = {
			R.string.inv_game_accept_fail, R.string.inv_game_delete_fail
		};
		
		String notice = "";
		if (result == 1) {
			notice = getString(notice_succ_ids[acceptType]);
			if (acceptType == 0 && !StringUtil.isEmpty(data)) {
				
				GgApplication.getInstance().addClubInfo(JSONUtil.getValue(data, "club_id"), JSONUtil.getValue(data, "club_name"), 8);
				GgApplication.getInstance().getChatInfo().addClubChatRoom(
						JSONUtil.getValueInt(data, "club_id"),
						JSONUtil.getValue(data, "club_name"),
						JSONUtil.getValueInt(data, "room_id"), 
						ChatConsts.CHAT_ROOM_MEETING);
			}
			adapter.deleteData(position);
			adapter.notifyDataSetChanged();
			int count = GgApplication.getInstance().getTempInvCount();
//			GgApplication.getInstance().setTempInvCount(count - 1);
		} else {
			notice = getString(notice_fail_ids[acceptType]);
		}
		
		Toast.makeText(InvGameActivity.this, notice, Toast.LENGTH_SHORT).show();
//		String notice = (result == 1) ? getString(notice_succ_ids[acceptType]) : getString(notice_fail_ids[acceptType]);
		
	}
}
