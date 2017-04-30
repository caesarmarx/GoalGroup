package com.goalgroup.ui.fragment;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
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
import com.goalgroup.ui.AddBBSActivity;
import com.goalgroup.ui.ClubMarketActivity;
import com.goalgroup.ui.CreateClubActivity;
import com.goalgroup.ui.InvGameActivity;
import com.goalgroup.ui.InvitationActivity;
import com.goalgroup.ui.NewChallengeActivity;
import com.goalgroup.ui.NewsAlarmActivity;
import com.goalgroup.ui.PlayerMarketActivity;
import com.goalgroup.ui.SettingsActivity;

public class SearchFragment extends BaseFragment implements OnClickListener {
	private final int TEMP_INV = 1;
	private final int INV = 0;
	
	private View viewPlayerMarket;
	private View viewClubMarker;
	private View viewInviation;
	private TextView invCount;
	private View viewInviteGames;
	private TextView tempInvCount;
	private TextView calloutCount;
	
	private TextView tvTitle;
	private Button btnViewMore;
	private LinearLayout popupMenu;
	private RelativeLayout newAlarm;
	
	private MyClubData myClbData;
	private Button mnuAddBBS;
	private Button mnuNewChallenge;
	private Button mnuCreateClub;
	private Button mnuSettings;
	
	private Button btnViewAlarms;

	
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
	}
	
	@Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		View mainView = inflater.inflate(R.layout.layout_search, null);
		
		tvTitle = (TextView)mainView.findViewById(R.id.top_title);
		tvTitle.setText(R.string.search);
		
		viewPlayerMarket = mainView.findViewById(R.id.player_market_ly);
		viewPlayerMarket.setOnClickListener(this);
		viewClubMarker = mainView.findViewById(R.id.club_market_ly);
		viewClubMarker.setOnClickListener(this);
		viewInviation = mainView.findViewById(R.id.invitation_list_ly);
		viewInviation.setOnClickListener(this);
		invCount = (TextView)mainView.findViewById(R.id.inv_count);
		if (GgApplication.getInstance().getInvCount() == 0)
			invCount.setVisibility(View.GONE);
		invCount.setText(
				String.valueOf(GgApplication.getInstance().getInvCount()));
		viewInviteGames = mainView.findViewById(R.id.temp_inv_list_ly);
		viewInviteGames.setOnClickListener(this);
		tempInvCount = (TextView)mainView.findViewById(R.id.temp_inv_count);
		if (GgApplication.getInstance().getTempInvCount()== 0)
			tempInvCount.setVisibility(View.GONE);
		tempInvCount.setText(
				String.valueOf(GgApplication.getInstance().getTempInvCount()));
		
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
		
		newAlarm = (RelativeLayout)mainView.findViewById(R.id.top_challenge_view_alarm_new);
		calloutCount = (TextView)mainView.findViewById(R.id.callout_number_view);
		myClbData = new MyClubData();
		
		onRunTimeRefresh();
		
		return mainView;
	}
	
	public void onRefresh(int id) {
		if (GgApplication.getInstance().getInvCount() == 0)
			invCount.setVisibility(View.GONE);
		else
			invCount.setVisibility(View.VISIBLE);
		if (GgApplication.getInstance().getTempInvCount()== 0)
			tempInvCount.setVisibility(View.GONE);
		else
			tempInvCount.setVisibility(View.VISIBLE);
		
		invCount.setText(
				String.valueOf(GgApplication.getInstance().getInvCount()));
		tempInvCount.setText(
				String.valueOf(GgApplication.getInstance().getTempInvCount()));
		return;
	}

	public void onRunTimeRefresh() {
		onRefresh(0);
		
		String unreadCount = String.valueOf(GgApplication.getInstance().getChatInfo().getUnreadNewsCount());
		if (Integer.valueOf(unreadCount) == 0)
			newAlarm.setVisibility(View.GONE);
		else
			newAlarm.setVisibility(View.VISIBLE);
		calloutCount.setText(unreadCount);
	}
	
	@Override
	public void onClick(View view) {
		Intent intent;
		
		switch (view.getId()) {
		case R.id.player_market_ly:
			intent = new Intent(getActivity(), PlayerMarketActivity.class);
			startActivity(intent);
			break;
		case R.id.club_market_ly:
			intent = new Intent(getActivity(), ClubMarketActivity.class);
			startActivity(intent);
			break;
		case R.id.invitation_list_ly:
			intent = new Intent(getActivity(), InvitationActivity.class);
			startActivityForResult(intent, INV);
			break;
		case R.id.temp_inv_list_ly:
			intent = new Intent(getActivity(), InvGameActivity.class);
			startActivityForResult(intent, TEMP_INV);
			break;
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
	
	public void onActivityResult (int requestCode, int resultCode, Intent data) {
		if (resultCode != Activity.RESULT_OK)
			return;
		
		switch(requestCode) {
		case TEMP_INV: 
			GgApplication.getInstance().setTempInvCount(0);
			onRefresh(0);
			break;
		case INV:
			GgApplication.getInstance().setInvCount(0);
			onRefresh(0);
			break;
		}
	}
	
	public void hideMenu(){
		popupMenu.setVisibility(View.GONE);
	}
}
