package com.goalgroup.ui;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import com.goalgroup.R;
import com.goalgroup.task.GetAdminNewsTask;
import com.goalgroup.ui.adapter.ManagerNewsListAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.GgListView;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.utils.NetworkUtil;

public class ManagerNewsActivity extends Activity implements XListView.IXListViewListener {
	
	private TextView tvTitle;
	private Button btnBack;
	
	private GgListView resultListView;
	private ManagerNewsListAdapter adapter;
	private GgProgressDialog dlg;
	
	private boolean firstUpdate;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_news_list);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.manager_notices));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				setResult(RESULT_OK, getIntent());
				finish();
			}
		});
				
		adapter = new ManagerNewsListAdapter(this);
		
		resultListView = (GgListView)findViewById(R.id.news_listview);
		resultListView.setPullLoadEnable(true);
		resultListView.setPullRefreshEnable(false);
		resultListView.setXListViewListener(this, 0);
		resultListView.setAdapter(adapter);
				
		firstUpdate = true;
	}

	@Override
	public void onResume() {
		super.onResume();
		if (firstUpdate) {
			startGetManagerNews(true);
			firstUpdate = false;
		}
		return;
	}

	@Override
	public void onRefresh(int id) {
		adapter.clearData();
		adapter.notifyDataSetChanged();
		
		startGetManagerNews(true);
		return;
	}

	@Override
	public void onLoadMore(int id) {
		startGetManagerNews(false);
	}
	
	public void startGetManagerNews(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(ManagerNewsActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ManagerNewsActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetAdminNewsTask task = new GetAdminNewsTask(this, adapter);
		task.execute();
	}
	
	public void stopGetManagerNews(boolean hasMore) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
		resultListView.setPullLoadEnable(hasMore);
	}	
}
