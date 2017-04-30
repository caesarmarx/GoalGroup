package com.goalgroup.ui.fragment;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.GetMyClubsTask;
import com.goalgroup.task.RunTimeDetailTask;
import com.goalgroup.ui.AddBBSActivity;
import com.goalgroup.ui.ChatActivity;
import com.goalgroup.ui.CreateClubActivity;
import com.goalgroup.ui.NewChallengeActivity;
import com.goalgroup.ui.NewsAlarmActivity;
import com.goalgroup.ui.SettingsActivity;
import com.goalgroup.ui.adapter.ClubListAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.GgListView;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.utils.NetworkUtil;

public class ClubFragment extends BaseFragment
	implements OnClickListener, XListView.IXListViewListener{
	
	private final int FROM_CLUB_MEET = 0;
	private final int FROM_CLUB_INFO = 1;

	private TextView tvTitle;
	private TextView calloutCount;
	private MyClubData myClbData;
	private GgListView clubsListView;
	private ClubListAdapter adapter;
	private GgProgressDialog dlg;
	
	private Button btnViewMore;
	private LinearLayout popupMenu;
	private RelativeLayout newAlarm;
	
	private Button mnuAddBBS;
	private Button mnuNewChallenge;
	private Button mnuCreateClub;
	private Button mnuSettings;
	
	private Button btnViewAlarms;
	private boolean mConnected = false;
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        ConnectivityManager connectivity = (ConnectivityManager) getActivity().getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = connectivity.getActiveNetworkInfo();
		mConnected = info.isAvailable() && info.isConnected();
	}
	
	@Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		View mainView = inflater.inflate(R.layout.layout_clubs, null);

		tvTitle = (TextView)mainView.findViewById(R.id.top_title);
		tvTitle.setText(R.string.club);
		
		adapter = new ClubListAdapter(getActivity(), this);
				
		clubsListView = (GgListView)mainView.findViewById(R.id.clubs_listview);
		clubsListView.setPullLoadEnable(true);
		clubsListView.setPullRefreshEnable(false);
		clubsListView.setXListViewListener(this, 0);
		
		clubsListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				Intent intent = new Intent(getActivity(), ChatActivity.class);
				intent.putExtra(ChatConsts.CHAT_TYPE_TAG, ChatConsts.FROM_MEETING);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, adapter.getClubId(position));
				startActivityForResult(intent, FROM_CLUB_MEET);
			}
		});
		
		clubsListView.setAdapter(adapter);
		
		setPopupMenu(popupMenu = (LinearLayout)mainView.findViewById(R.id.popup_menu));
		popupMenu.setVisibility(View.GONE);
		
		btnViewMore = (Button)mainView.findViewById(R.id.top_view_more);
		btnViewMore.setOnClickListener(this);
		
		mnuAddBBS = (Button)mainView.findViewById(R.id.social_mnu_add_bbs);
		mnuAddBBS.setOnClickListener(this);
		mnuNewChallenge = (Button)mainView.findViewById(R.id.social_mnu_new_challenge);
		mnuNewChallenge.setOnClickListener(this);
		mnuCreateClub = (Button)mainView.findViewById(R.id.social_mnu_create_club);
		mnuCreateClub.setOnClickListener(this);
		mnuSettings = (Button)mainView.findViewById(R.id.social_mnu_settings);
		mnuSettings.setOnClickListener(this);
		
		btnViewAlarms = (Button)mainView.findViewById(R.id.top_view_alarmas);
		btnViewAlarms.setOnClickListener(this);
		
		myClbData = new MyClubData();
		
		newAlarm = (RelativeLayout)mainView.findViewById(R.id.top_challenge_view_alarm_new);
        calloutCount = (TextView)mainView.findViewById(R.id.callout_number_view);
        
		return mainView;
	}
	
	@Override
	public void onResume() {
		super.onResume();
		
		IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        getActivity().registerReceiver(broadcastReceiver, intentFilter);  
        
//		if (firstUpdate) {
//			startAttachClubs(true);
//			firstUpdate = false;
//		}
		refreshClubData();
		
		return;
		
	}
	
	public void refreshClubData() 
	{
		onRunTimeRefresh();
		if (GgApplication.getInstance().getLastNotifyRoomType() == ChatConsts.CHAT_ROOM_MEETING) {
			GgApplication.getInstance().getChatEngine().hideNotification();
		}
		
		adapter.clearData();
		adapter.notifyDataSetChanged();
		
		startAttachClubs(true);	
	}
	
	@Override
    public void onPause()
    {
        super.onPause();
       // getActivity().unregisterReceiver(broadcastReceiver);
    }
	
	public void onRunTimeRefresh() {
		String unreadCount = String.valueOf(GgApplication.getInstance().getChatInfo().getUnreadNewsCount());
		if (Integer.valueOf(unreadCount) == 0)
			newAlarm.setVisibility(View.GONE);
		else
			newAlarm.setVisibility(View.VISIBLE);
		calloutCount.setText(unreadCount);
		
//		if (GgApplication.getInstance().getLastNotifyRoomType() == ChatConsts.CHAT_ROOM_MEETING) {
//			GgApplication.getInstance().getChatEngine().hideNotification();
//		}
		
		adapter.rebuildClubData();
		adapter.notifyDataSetChanged();
	}
	
	@Override
	public void onRefresh(int id) {
		adapter.clearData();
		adapter.notifyDataSetChanged();
		
		startAttachClubs(true);
		return;
	}

	@Override
	public void onLoadMore(int id) {
		startAttachClubs(false);
		return;
	}

	@Override
	public void onClick(View view) {
		Intent intent;
		
		switch (view.getId()) {
		case R.id.top_view_more:
			popupMenu.setVisibility(popupMenu.getVisibility() == View.GONE ? View.VISIBLE : View.GONE);
			//imgViewMore.setBackgroundResource(popupMenu.getVisibility() == View.GONE ? R.drawable.view_more : R.drawable.hide_more);
			break;
		case R.id.social_mnu_add_bbs:
			intent = new Intent(getActivity(), AddBBSActivity.class);
			startActivity(intent);
			break;
		case R.id.social_mnu_new_challenge:
			if (!myClbData.isOwner()) {
				Toast.makeText(getActivity(), getString(R.string.no_manager), Toast.LENGTH_SHORT).show();
			} else {
				GgApplication.getInstance().setChallFlag(true);
				intent = new Intent(getActivity(), NewChallengeActivity.class);
				intent.putExtra("type", CommonConsts.NEW_CHALLENGE);
				intent.putExtra("challType", CommonConsts.CHALLENGE_GAME);
				startActivity(intent);
			}
			break;
		case R.id.social_mnu_create_club:
			intent = new Intent(getActivity(), CreateClubActivity.class);
			intent.putExtra(CommonConsts.CLUB_TYPE_TAG, CommonConsts.CREATE_CLUB);
			startActivity(intent);
			break;
		case R.id.social_mnu_settings:
			intent = new Intent(getActivity(), SettingsActivity.class);
			startActivity(intent);
			break;
		case R.id.top_view_alarmas:
			intent = new Intent(getActivity(), NewsAlarmActivity.class);
			startActivity(intent);
			break;
		}		
	}
	
	@Override
	public void onActivityResult (int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		
		if (resultCode != Activity.RESULT_OK)
			return;
		
		switch (requestCode) {
		case FROM_CLUB_MEET:
//			if (data.getExtras().getInt(ChatConsts.FINISH_LEAVE_CLUB) == 1  
//				|| data.getExtras().getInt(CommonConsts.BREAKUP_CLUB) == CommonConsts.BREAKED_CLUB) {
//				adapter.clearData();
//				adapter.notifyDataSetChanged();
//				
//				startAttachClubs(false);
//			} else 
			if (data.getExtras().getInt(ChatConsts.FINISH_NEW_DISCUSS) == 1) {
				Intent intent = new Intent(getActivity(), ChatActivity.class);
				intent.putExtra(ChatConsts.CHAT_TYPE_TAG, ChatConsts.FROM_DISCUSS);
				int clubId = data.getExtras().getInt(CommonConsts.CLUB_ID_TAG);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, clubId);
				int oppId = data.getExtras().getInt(CommonConsts.OPP_CLUB_ID_TAG);
				intent.putExtra(ChatConsts.OPP_CLUB_ID_TAG, oppId);
				int gameId = data.getExtras().getInt(CommonConsts.GAME_ID_TAG);
				intent.putExtra(ChatConsts.GAME_ID, gameId);
				intent.putExtra("type", 0);
				startActivity(intent);
			}
			break;
		case FROM_CLUB_INFO:
//			if(data.getExtras().getInt(ChatConsts.BREAKUP_CLUB) == 1) {
//				adapter.clearData();
//				adapter.notifyDataSetChanged();
//				
//				startAttachClubs(true);
//			}
			break;
		default:
			break;
		}
	}
	
	public void startAttachClubs(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(getActivity()))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(getActivity(), getActivity().getString(R.string.wait));
			dlg.show();
		}
		
//		if (adapter != null) {
//			adapter.clearData();
//			adapter.notifyDataSetChanged();
//		}
		
//		adapter = new ClubListAdapter(getActivity(), this);
//		clubsListView.setAdapter(adapter);
		
		RunTimeDetailTask runDetailTask = new RunTimeDetailTask();
		
		String[] clubs= GgApplication.getInstance().getClubId();
		String clubIds = "";
		
		if (clubs != null) {
			for (int i = 0;i < clubs.length; i++) {
				if (clubIds.equals("")) {
					clubIds = clubs[i];
				}
				else {
					clubIds = clubIds + "," + clubs[i];
				}
			}
		}
		runDetailTask.execute(GgApplication.getInstance().getUserId(), clubIds);
		
		GetMyClubsTask task = new GetMyClubsTask(this, adapter);
		task.execute();
	}
	
	public void stopAttachClubs(boolean hasMore) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
		clubsListView.setPullLoadEnable(hasMore);
	}
	
	public void hideMenu(){
		popupMenu.setVisibility(View.GONE);
	}

	private final BroadcastReceiver broadcastReceiver = new BroadcastReceiver()
    {
		@Override
		public void onReceive(Context context, Intent intent)
        {
			ConnectivityManager connectivity = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
			NetworkInfo info = connectivity.getActiveNetworkInfo();
			
			if (info != null)
            {
				boolean connected =  info.isAvailable() && info.isConnected();
				
				if (mConnected == connected) return;				
				mConnected = connected;
				
				if (mConnected)
				{
					refreshClubData();
				}
            }
			else
			{
				mConnected = false;
			}
        }
    };
}
