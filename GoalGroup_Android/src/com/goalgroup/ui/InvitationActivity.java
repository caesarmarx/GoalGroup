package com.goalgroup.ui;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

import com.goalgroup.R;
import com.goalgroup.task.GetInvitationTask;
import com.goalgroup.ui.adapter.InvitationListAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.GgListView;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.utils.ListViewUtil;
import com.goalgroup.utils.NetworkUtil;

public class InvitationActivity extends Activity implements XListView.IXListViewListener {
	private final int CLUB_INFO = 0;
	
	private TextView tvTitle;
	private Button btnBack;
	
	private GgListView invListView;
	private InvitationListAdapter adapter;
	private GgProgressDialog dlg;
	
	private boolean firstUpdate;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_invitation);
		
		firstUpdate = true;
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.invitation));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				setResult(RESULT_OK, getIntent());
				finish();
			}
		});
		
		adapter = new InvitationListAdapter(this);
		
		invListView = (GgListView)findViewById(R.id.invitation_listview);
		invListView.setPullLoadEnable(true);
		invListView.setPullRefreshEnable(false);
		invListView.setXListViewListener(this, 0);
		invListView.setAdapter(adapter);
	}

	public void onResume() {
		super.onResume();
		if (firstUpdate) {
			startAttachInvs(false);
			firstUpdate = false;
		}
	}

	@Override
	public void onRefresh(int id) {	
		adapter.clearData();
		adapter.notifyDataSetChanged();
		
		startAttachInvs(false);
		return;
	}

	@Override
	public void onLoadMore(int id) {
		startAttachInvs(true);
		return;
	}
	
	public void RemoveItem(int index) {
		adapter.deleteData(index);
		adapter.notifyDataSetChanged();
	}
	
	public void startAttachInvs(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(InvitationActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(InvitationActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetInvitationTask task = new GetInvitationTask(this, adapter);
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
	
	public void onActivityResult (int requestCode, int resultCode, Intent data) {
		if (resultCode != Activity.RESULT_OK)
			return;
		
		switch(requestCode) {
		case CLUB_INFO: 
			onRefresh(0);
			break;
		}
	}
}
