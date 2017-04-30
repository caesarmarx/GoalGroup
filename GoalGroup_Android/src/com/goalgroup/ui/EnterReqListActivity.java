package com.goalgroup.ui;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

import com.goalgroup.R;
import com.goalgroup.ui.view.CustomSwipeListView.OnMenuItemClickListener;
import com.goalgroup.model.MyClubData;
import com.goalgroup.ui.view.CustomSwipeListView;
import com.goalgroup.ui.view.CustomSwipeMenu;
import com.goalgroup.ui.view.CustomSwipeMenuCreator;
import com.goalgroup.ui.view.CustomSwipeMenuItem;
import com.goalgroup.ui.view.GgListView;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.task.GetReqListTask;
import com.goalgroup.ui.adapter.EnterReqListAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.ListViewUtil;
import com.goalgroup.utils.NetworkUtil;

public class EnterReqListActivity extends Activity implements XListView.IXListViewListener {
	
	private TextView tvTitle;
	private Button btnBack;
	
	private GgListView enterReqListView;
	private EnterReqListAdapter adapter;
	private GgProgressDialog dlg;
	private MyClubData myClubData;
	
	private int club_id;
	
	private boolean firstUpdate;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		club_id = getIntent().getExtras().getInt("CLUB_ID");
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_enter_req_list);
		myClubData = new MyClubData();
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(myClubData.getNameFromID(club_id) + "-" + getString(R.string.enter_request_list));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		adapter = new EnterReqListAdapter(this, club_id);
		
		enterReqListView = (GgListView)findViewById(R.id.enter_req_listview);
		enterReqListView.setPullLoadEnable(true);
		enterReqListView.setPullRefreshEnable(false);
		enterReqListView.setXListViewListener(this, 0);
		enterReqListView.setAdapter(adapter);
		
		// create menu and set menu creator to listview
		/*CustomSwipeMenuCreator creator = new CustomSwipeMenuCreator(){

			@Override
			public void create(CustomSwipeMenu menu) {
				CustomSwipeMenuItem item = new CustomSwipeMenuItem(getApplicationContext());
				item.setBackground(R.color.gray);
				item.setWidth(ListViewUtil.dp2px(70, getResources()));
				item.setIcon(R.drawable.invitiation_delete);
				menu.addMenuItem(item);
			}
		};
		enterReqListView.setMenuCreator(creator);
		
		// set menuitem click listener
		enterReqListView.setOnMenuItemClickListener(new OnMenuItemClickListener() {
			@Override
			public boolean onMenuItemClick(int position, CustomSwipeMenu menu, int index) {
				switch (index) {
				case 0:
					adapter.procEject(position);
					break;
				}
				return false;
			}
		});
		*/
		firstUpdate = true;
	}
	
	public void onResume() {
		super.onResume();
		
		if (firstUpdate) {
			startAttachReqList(true);
			firstUpdate = false;
		}
	}

	@Override
	public void onRefresh(int id) {
		startAttachReqList(true);
	}

	@Override
	public void onLoadMore(int id) {
		startAttachReqList(false);	
	}
	
	public void RemoveItem(int index) {
		adapter.deleteData(index);
		adapter.notifyDataSetChanged();
	}
	
	public void startAttachReqList(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(EnterReqListActivity.this))
			return;
		
		if(showdlg) {
			dlg = new GgProgressDialog(EnterReqListActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetReqListTask task = new GetReqListTask(EnterReqListActivity.this, adapter, club_id);
		task.execute();
	}
	
	public void stopAttachReqList(boolean hasMore){
		if(dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		adapter.notifyDataSetChanged();
		if (adapter.getCount() == 0)
			enterReqListView.setVisibility(View.GONE);
		enterReqListView.setPullLoadEnable(hasMore);
	}

}
