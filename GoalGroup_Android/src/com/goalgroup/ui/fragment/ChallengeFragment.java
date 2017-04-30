package com.goalgroup.ui.fragment;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.GetChallTask;
import com.goalgroup.ui.AddBBSActivity;
import com.goalgroup.ui.CreateClubActivity;
import com.goalgroup.ui.NewChallengeActivity;
import com.goalgroup.ui.NewsAlarmActivity;
import com.goalgroup.ui.SettingsActivity;
import com.goalgroup.ui.adapter.ChallengeListAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.GgListView;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.utils.NetworkUtil;

public class ChallengeFragment extends BaseFragment 
	implements OnClickListener, XListView.IXListViewListener {
	private final int FROM_CHALLENGE = 1;
	private final int CLUB_INFO = 0;
	private final int FROM_DISCUSS =2;
	
	private final int TOP_TAB_NUM = 2;
	
	private TextView tvTitle;
	private TextView calloutCount;
	private Button btnViewMore;
	private LinearLayout popupMenu;
	private RelativeLayout newAlarm;
	
	private Button mnuAddBBS;
	private Button mnuNewChallenge;
	private Button mnuCreateClub;
	private Button mnuSettings;
	
	private Button btnViewAlarms;
	
	private View[] challTypeTabs = new View[TOP_TAB_NUM];
	private TextView[] challTypeTVs = new TextView[TOP_TAB_NUM];
	
	private int tabbg_ids[] = {
		R.id.chall_tab_one_bg, R.id.chall_tab_two_bg
	};
	
	private int tabtv_ids[] = {
		R.id.chall_tab_one_tv, R.id.chall_tab_two_tv
	};
	
	private boolean firstUpdate;
	private int lastSelected = -1;	
	
	private MyClubData myClbData;
	private GgListView challListView;
	private ChallengeListAdapter adapter;
	private GgProgressDialog dlg;
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
	}
	
	@Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		View mainView = inflater.inflate(R.layout.layout_challenge, null);
		
		tvTitle = (TextView)mainView.findViewById(R.id.top_title);
		tvTitle.setText(R.string.challenge_list);
		
		for (int i = 0; i < TOP_TAB_NUM; i++) {
			challTypeTabs[i] = mainView.findViewById(tabbg_ids[i]);
			challTypeTabs[i].setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View v) {
					for (int i = 0; i < TOP_TAB_NUM; i++) {
						if (tabbg_ids[i] == v.getId()) {
							onSelectChallType(i);
						}
					}
				}
			});
			
			challTypeTVs[i] = (TextView)mainView.findViewById(tabtv_ids[i]);
		}
		
		adapter = new ChallengeListAdapter(getActivity(), this);
		
		challListView = (GgListView)mainView.findViewById(R.id.challenge_listview);
		challListView.setAdapter(adapter);
		challListView.setPullLoadEnable(true);
		challListView.setPullRefreshEnable(false);
		challListView.setXListViewListener(this, 0);
		
		setPopupMenu(popupMenu = (LinearLayout) mainView.findViewById(R.id.popup_menu));
		
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
        firstUpdate = true;
		
        newAlarm = (RelativeLayout)mainView.findViewById(R.id.top_challenge_view_alarm_new);
        calloutCount = (TextView)mainView.findViewById(R.id.callout_number_view);
		Log.d("MYLOG", "ChallengeFragment_onCreateView");
		
		return mainView;
	}

	@Override
	public void onResume() {
		super.onResume();
		onRunTimeRefresh();
		if (firstUpdate) {
			onSelectChallType((lastSelected == -1) ? 0 : lastSelected);
			firstUpdate = false;
		}
	}
	
	@Override
	public void onRefresh(int id) {
		adapter.clearData();
		adapter.notifyDataSetChanged();
		startAttachChallenges(true);
		return;
	}

	@Override
	public void onLoadMore(int id) {
		startAttachChallenges(false);
		return;
	}
	
	public void onRunTimeRefresh() {
		String unreadCount = String.valueOf(GgApplication.getInstance().getChatInfo().getUnreadNewsCount());
		if (Integer.valueOf(unreadCount) == 0)
			newAlarm.setVisibility(View.GONE);
		else
			newAlarm.setVisibility(View.VISIBLE);
		calloutCount.setText(unreadCount.toString());
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
				startActivityForResult(intent, FROM_CHALLENGE);
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
	
	public void startAttachChallenges(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(getActivity()))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(getActivity(), getActivity().getString(R.string.wait));
			dlg.show();
		}
		
		String clubIds;
		clubIds = getClubIds();
		GetChallTask task = new GetChallTask(this, adapter, lastSelected, CommonConsts.FROM_CHALLENGE, clubIds);
		task.execute();
	}
	
	public void stopAttachChallenges(boolean hasMore) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
		challListView.setPullLoadEnable(hasMore);
	}
	
	private void onSelectChallType(int selected) {
		for (int i = 0; i < TOP_TAB_NUM; i++) {
			challTypeTabs[i].setVisibility(i == selected ? View.INVISIBLE : View.VISIBLE);
			challTypeTVs[i].setTextColor(i == selected ? 0xff000000 : 0xffffffff);
		}
		
		lastSelected = selected;
		
		adapter.clearData();
		adapter.setChallType(selected);
		adapter.notifyDataSetChanged();
		
		startAttachChallenges(true);
	}
	
	private String getClubIds() {
		String result = "";
		String[] clubId = GgApplication.getInstance().getClubId();
		if (clubId.length == 0)
			return result;
		for (int i = 0; i < clubId.length; i++) {
			result = result + clubId[i].toString();
			if (i == clubId.length - 1)
				continue;
			result = result + ":";
		}
		return result;
	}
	
	public void onActivityResult (int requestCode, int resultCode, Intent data) {
		if (resultCode != Activity.RESULT_OK)
			return;
		
		switch(requestCode) {
		case CLUB_INFO: 
			onRefresh(0);
			break;
		case FROM_CHALLENGE:
			onRefresh(0);
			break;
		case FROM_DISCUSS:
			onRefresh(0);
			break;
		}
	}
	
	public void hideMenu(){
		popupMenu.setVisibility(View.GONE);
	}
}
