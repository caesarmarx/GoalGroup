package com.goalgroup.ui;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.GetClubInfoTask;
import com.goalgroup.task.RegisterUserToClubTask;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

import cn.jpush.android.api.JPushInterface;

public class ClubInfoActivity extends Activity {
	
	private TextView tvTitle;
	private Button btnBack;
	private ImageView imgView;
	
	private String club_id;
	
	private MyClubData mClubData;
	private GgProgressDialog dlg;

	private ImageLoader imgLoader;

	private View totalArea;
	private ImageView ivClubMark;
	private TextView tvClubName;
	private TextView tvClubPoints;
	private TextView tvCreatedDate;
	private TextView tvCity;
	private TextView tvPlayDays;
	private TextView tvPlayArea;
	private TextView tvStadiumArea;
	private TextView etStadiumAddress;
	private TextView tvHistory;
	private TextView tvMemberCount;
	private TextView tvSponser;
	private TextView tvIntro;
	private LinearLayout area_history;
	private Button btn_process;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_club_info);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.club_infos));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
//		imgView = (ImageView)findViewById(R.id.top_img);
//		imgView.setBackgroundDrawable(getResources().getDrawable(R.drawable.edit_ico));
//		imgView.setVisibility(View.VISIBLE);
		
		btn_process = (Button)findViewById(R.id.btn_join);
		btn_process.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				Object[] param;
				param = new Object[2];
				param[0] = GgApplication.getInstance().getUserId();
				param[1] = club_id;
				startRegisterUserToClub(true, param);
			}
		});
		
		mClubData = new MyClubData();
		club_id = getIntent().getExtras().getString(GgIntentParams.CLUB_ID);		
		imgLoader = GgApplication.getInstance().getImageLoader();
		
		initUI();
		
		View areaClubScore = this.findViewById(R.id.area_club_score);
		View areaClubMembers = this.findViewById(R.id.area_club_members);
//		ImageView historyArrow = (ImageView)this.findViewById(R.id.club_history_arrow);
//		ImageView memberCountArrow = (ImageView)this.findViewById(R.id.member_count_arrow);
		
		if (mClubData.isOwnClub(Integer.valueOf(club_id))){
			btn_process.setVisibility(View.GONE);
			areaClubScore.setOnClickListener(new View.OnClickListener() {
				/**
				 * the method when click 俱乐部资料/成绩
				 */
				public void onClick(View arg0) {
					Intent intent = new Intent(ClubInfoActivity.this, ClubHistoryActivity.class);
					intent.putExtra(ChatConsts.CLUB_ID_TAG, Integer.valueOf(club_id));
					startActivity(intent);
				}
			});
			areaClubMembers.setOnClickListener(new View.OnClickListener() {
				/**
				 * the method when click 俱乐部资料/成员数
				 */
				public void onClick(View arg0) {
					Intent intent = new Intent(ClubInfoActivity.this, ClubMembersActivity.class);
					intent.putExtra(ChatConsts.CLUB_ID_TAG, Integer.valueOf(club_id));
					startActivity(intent);
				}
			});
		} else if (getIntent().getExtras().getInt("join_type") == CommonConsts.JOIN_CLUB){
			btn_process.setVisibility(View.VISIBLE);
//			historyArrow.setVisibility(View.GONE);
//			memberCountArrow.setVisibility(View.GONE);
		} else {
			btn_process.setVisibility(View.GONE);
//			historyArrow.setVisibility(View.GONE);
//			memberCountArrow.setVisibility(View.GONE);
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
	@Override
	public void onResume() {
		super.onResume();
		startAttachClubInfo(true);
	}
	
	public void startAttachClubInfo(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(ClubInfoActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ClubInfoActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetClubInfoTask task = new GetClubInfoTask(this, club_id, CommonConsts.CLUB_INFO);
		task.execute();
	}
	
	public void stopAttachClubInfo(String infos) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (StringUtil.isEmpty(infos)) {
			Toast.makeText(ClubInfoActivity.this, getString(R.string.none_club_data), Toast.LENGTH_SHORT).show();
			finish();
			return;
		}
		
		setUI(infos);
	}
	
	private void initUI() {
		totalArea = findViewById(R.id.total_area);
		totalArea.setVisibility(View.INVISIBLE);
		
		ivClubMark = (ImageView)findViewById(R.id.img_club_mark);
		tvClubName = (TextView)findViewById(R.id.club_name);
//		tvClubName.setText("");
		tvClubPoints = (TextView)findViewById(R.id.club_points);
//		tvClubPoints.setText("");
		tvCreatedDate = (TextView)findViewById(R.id.club_created_date);
//		tvCreatedDate.setText("");
		tvCity = (TextView)findViewById(R.id.club_city);
//		tvCity.setText("");
		tvPlayDays = (TextView)findViewById(R.id.play_days);
//		tvPlayDays.setText("");
		tvPlayArea = (TextView)findViewById(R.id.play_area);
//		tvPlayArea.setText("");
		tvStadiumArea = (TextView)this.findViewById(R.id.tv_main_stadium_area);
//		tvStadiumArea.setText("");
		etStadiumAddress = (TextView)this.findViewById(R.id.tv_main_stadium_address);
//		etStadiumAddress.setText("");
		area_history = (LinearLayout)findViewById(R.id.area_history);
		tvHistory = (TextView)findViewById(R.id.club_history);
//		tvHistory.setText("");
		tvMemberCount = (TextView)findViewById(R.id.member_count);
//		tvMemberCount.setText("");
		
		tvSponser = (TextView)findViewById(R.id.sponser);
//		tvSponser.setText("");
		tvIntro = (TextView)findViewById(R.id.introduction);
//		tvIntro.setText("");
	}
	
	private void setUI(String infos) {
		totalArea.setVisibility(View.VISIBLE);
		
		int city = 0;
		String mark_pic_url = JSONUtil.getValue(infos, "mark_pic_url");
		imgLoader.displayImage(mark_pic_url, ivClubMark, GgApplication.img_opt_club_mark);
		tvClubName.setText(JSONUtil.getValue(infos, "club_name"));
		tvClubPoints.setText(getString(R.string.action_point).concat(": ").concat(JSONUtil.getValue(infos, "point")));
		tvCreatedDate.setText(JSONUtil.getValue(infos, "found_date"));
		if (!StringUtil.isEmpty(JSONUtil.getValue(infos, "city"))){
			tvCity.setText(JSONUtil.getValue(infos, "city"));
			city = Integer.valueOf(GgApplication.getInstance().getIDFromName(JSONUtil.getValue(infos, "city"),CommonConsts.CITY));
		}
		tvPlayDays.setText(StringUtil.getStrFromSelValue(JSONUtil.getValueInt(infos, "act_time"), CommonConsts.ACT_DAY));
		if (!StringUtil.isEmpty(JSONUtil.getValue(infos, "act_area")))
		{
			String edit_playArea = JSONUtil.getValue(infos, "act_area");
			String[] selArea = edit_playArea.split(",");
			
			String[][] sub_distInfo = GgApplication.getInstance().getDistfromCity(String.valueOf(city));
			String[] districtNames = sub_distInfo[2]; 
			String[] districtIds = sub_distInfo[0];
			boolean[] location_selected = new boolean[districtNames.length];
			
			String value = "";
			for (int i = 0, cnt = 0; i < districtNames.length; i++) {
				location_selected[i] = false;
				for (int j = 0; j < selArea.length; j++) {
					if (districtIds[i].equals(selArea[j])){
						location_selected[i] = true;
						continue;
					}
				}
				if (!location_selected[i])
					continue;
				if (cnt != 0)
					value = value.concat(",\n");
				value = value.concat(districtNames[i]);
				cnt++;
			}
			tvPlayArea.setText(value);
		}
		if (!StringUtil.isEmpty(JSONUtil.getValue(infos, "home_stadium_area")))
			tvStadiumArea.setText(JSONUtil.getValue(infos, "home_stadium_area"));
		String stadiumAddress = JSONUtil.getValue(infos, "home_stadium_address");
		if (!StringUtil.isEmpty(stadiumAddress))
			etStadiumAddress.setText(stadiumAddress);
		
		String history = String.format("%s胜 %s平 %s负", 
				JSONUtil.getValueInt(infos, "victor_game"), 
				JSONUtil.getValueInt(infos, "draw_game"), 
				JSONUtil.getValueInt(infos, "lose_game"));
		tvHistory.setText(history);
		String member_count = String.format("%d人", JSONUtil.getValueInt(infos, "member_count"));
		tvMemberCount.setText(member_count);
		if (mClubData.isOwnClub(Integer.valueOf(club_id))){
			area_history.setVisibility(View.VISIBLE);
		}
		tvSponser.setText(JSONUtil.getValue(infos, "sponsor"));
		tvIntro.setText(JSONUtil.getValue(infos, "introduction"));
	}
	
	public void startRegisterUserToClub(boolean showdlg, Object[] registerInfo) {
		if (!NetworkUtil.isNetworkAvailable(ClubInfoActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ClubInfoActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		RegisterUserToClubTask task = new RegisterUserToClubTask(ClubInfoActivity.this, registerInfo);
		task.execute();
	}
	
	public void stopRegisterUserToClub(int data) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		switch (data) {
		case 0:
			Toast.makeText(ClubInfoActivity.this, getString(R.string.register_user_club_failed), Toast.LENGTH_LONG).show();
			break;
		case 1:
			Toast.makeText(ClubInfoActivity.this, getString(R.string.register_user_club_success), Toast.LENGTH_LONG).show();
			break;
		case 2:
			Toast.makeText(ClubInfoActivity.this, getString(R.string.user_club_exist), Toast.LENGTH_LONG).show();
			break;
		default:
			break;
		}
	}	
	
//	public void startBreakUpClub(boolean showdlg, Object[] param) {
//		if (!NetworkUtil.isNetworkAvailable(ClubInfoActivity.this))
//			return;
//		
//		if (showdlg) {
//			dlg = new GgProgressDialog(ClubInfoActivity.this, getString(R.string.wait));
//			dlg.show();
//		}
//		
//		BreakUpClubTask task = new BreakUpClubTask(ClubInfoActivity.this, param);
//		task.execute();
//	}
//	
//	public void stopBreakUpClub(int data) {
//		if (dlg != null) {
//			dlg.dismiss();
//			dlg = null;
//		}
//		
//		GoalGroupApplication.getInstance().popClubID(club_id);
//		
//		if (data == 1) {
//			Toast.makeText(ClubInfoActivity.this, getString(R.string.breakup_success), Toast.LENGTH_LONG).show();
//			getIntent().putExtra(ChatConsts.BREAKUP_CLUB, 1);
//			setResult(RESULT_OK, getIntent());
//			finish();
//		} else
//			Toast.makeText(ClubInfoActivity.this, getString(R.string.breakup_failed), Toast.LENGTH_LONG).show();
//	}
}
