package com.goalgroup.ui;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.model.PlayerResultItem;
import com.goalgroup.task.GetApplyPlayerTask;
import com.goalgroup.task.SetUserPointTask;
import com.goalgroup.ui.adapter.PlayerResultAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.GgListView;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.utils.DateUtil;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class GameDetailActivity extends Activity 
	implements OnClickListener, XListView.IXListViewListener {
	
	private TextView tvTitle;
	private Button btnBack;
	
	private TextView tvPlayerCount;
	private TextView tvGameDate;
	private TextView tvGameRemainTime;
	private TextView tvGameTime;
	private ImageView ivClubMark01;
	private TextView tvClubName01;
	private ImageView ivClubMark02;
	private TextView tvClubName02;
	private TextView tvStadium;
	private ImageLoader imgLoader;
	private Button btnUpdate;
	
	private boolean firstUpdate;
	
	int game_id;
	int club_id;
	int state;
	private GgListView playerListView;
	private PlayerResultAdapter adapter;
	private GgProgressDialog dlg;
	private MyClubData myClubData;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_game_detail);
		
		firstUpdate = true;
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.game_detail));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		myClubData = new MyClubData();
		
		game_id =getIntent().getExtras().getInt("game_id");
		club_id =getIntent().getExtras().getInt("club_id");
		state = getIntent().getExtras().getInt("state");
		
		tvPlayerCount = (TextView)findViewById(R.id.player_number);
		tvGameDate = (TextView)findViewById(R.id.game_date);
		tvGameRemainTime = (TextView)findViewById(R.id.game_remain_time);
		tvGameTime = (TextView)findViewById(R.id.game_time);
		ivClubMark01 = (ImageView)findViewById(R.id.club_mark_01);
		tvClubName01 = (TextView)findViewById(R.id.club_name_01);
		ivClubMark02 = (ImageView)findViewById(R.id.club_mark_02);
		tvClubName02 = (TextView)findViewById(R.id.club_name_02);
		tvStadium = (TextView)findViewById(R.id.stadium);
		imgLoader = GgApplication.getInstance().getImageLoader();
		btnUpdate = (Button)findViewById(R.id.update);
		
		final MyClubData myClubData = new MyClubData();
		if (!myClubData.isInstructorOfClub(club_id) || state != CommonConsts.GAME_STATE_FINISHED)
			btnUpdate.setVisibility(View.GONE);
		btnUpdate.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				int count = adapter.getCount();
				Object[] param = new Object[6];
				param[0] = game_id;
				param[1] = club_id;
				String user_id = "";
				String goal = "";
				String assist = "";
				String point = "";
				for (int i = 0; i < count; i ++){
					PlayerResultItem player_data = (PlayerResultItem)adapter.getItem(i);
					if (i != 0) {
						user_id = user_id.concat(",");
						goal = goal.concat(",");
						assist = assist.concat(",");
						point = point.concat(",");
					}
					user_id = user_id.concat(String.valueOf(player_data.getUserID()));
					goal = goal.concat(String.valueOf(player_data.getGoal()));
					assist = assist.concat(String.valueOf(player_data.getAssist()));
					point = point.concat(String.valueOf(player_data.getPoint()));
				}
				param[2] = user_id;
				param[3] = goal;
				param[4] = assist;
				param[5] = point;
				
				startSetUsersPoint(true, param);
			}
		});
		
		setGameUI();
		
		ivClubMark01.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				clubInfo(Integer.valueOf(getIntent().getExtras().getString("club01_id")));
			}
		});
		
		ivClubMark02.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				clubInfo(Integer.valueOf(getIntent().getExtras().getString("club02_id")));
			}
		});
		
		adapter = new PlayerResultAdapter(GameDetailActivity.this);
		
		playerListView = (GgListView)findViewById(R.id.player_listview);
		playerListView.setPullLoadEnable(true);
		playerListView.setPullRefreshEnable(false);
		playerListView.setXListViewListener(this, 0);
		playerListView.setAdapter(adapter);
		
		playerListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {	
				if (myClubData.isInstructorOfClub(club_id) && state == CommonConsts.GAME_STATE_FINISHED) {
					final PlayerResultItem data = (PlayerResultItem)adapter.getItem(position-1);
					
					final View dlg_view;
					LayoutInflater mInflater = LayoutInflater.from(GameDetailActivity.this); 
					dlg_view = mInflater.inflate(R.layout.dlg_player_point, null);
					
					AlertDialog dialog;
					
					final TextView tv_goal = (TextView)dlg_view.findViewById(R.id.player_goal);
					final TextView tv_assist = (TextView)dlg_view.findViewById(R.id.player_assist);
					final TextView tv_point = (TextView)dlg_view.findViewById(R.id.player_point);
					tv_goal.setText(String.valueOf(data.getGoal()));
					tv_assist.setText(String.valueOf(data.getAssist()));
					tv_point.setText(String.valueOf(data.getPoint()));
					
					
					dialog = new AlertDialog.Builder(GameDetailActivity.this)
					.setTitle(data.getUserName())
					.setView(dlg_view)
					.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
						
						@Override
						public void onClick(DialogInterface dialog, int arg1) {
							if (Integer.valueOf(tv_goal.getText().toString()) > 99 ||
									Integer.valueOf(tv_assist.getText().toString()) > 99 ||
									Integer.valueOf(tv_point.getText().toString()) > 99) {
								Toast.makeText(GameDetailActivity.this, R.string.player_point_error, Toast.LENGTH_SHORT).show();
								return;
							}
							data.setGoal(Integer.valueOf(tv_goal.getText().toString()));
							data.setAssist(Integer.valueOf(tv_assist.getText().toString()));
							data.setPoint(Integer.valueOf(tv_point.getText().toString()));
							
							adapter.notifyDataSetChanged();
						}
					})
					.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
				
						@Override
						public void onClick(DialogInterface dialog, int item) {
							dialog.dismiss();
						}
					})
					.create();
					
					dialog.show();
				} else {
					Toast.makeText(GameDetailActivity.this, getString(R.string.no_instructor), Toast.LENGTH_SHORT).show();
				}
			}
		} );
	}
	
	private Handler timerHandler;
	private Runnable timerRunnable;
	
	private String org_game_datetime;
	
	private void startCountDown() {
		
		timerRunnable = new Runnable() {
			
			@Override
			public void run() {
				String countdown = DateUtil.getDiffTime(org_game_datetime);
				if(countdown.split(":")[2].startsWith("-"))
				{
					countdown = "00:00:00";
					System.out.println("Remain_Time:" + countdown);
					stopCountDown();
				}
				tvGameRemainTime.setText(countdown);
				
				timerHandler.postDelayed(timerRunnable, 1000);
			}
		};
		
		timerHandler = new Handler();
		timerHandler.post(timerRunnable);
	}
	
	private void stopCountDown() {
		if (timerHandler == null)
			return;
		timerHandler.removeCallbacks(timerRunnable);
		timerHandler = null;
	}
	
	public void setGameUI(){
		imgLoader.displayImage(getIntent().getExtras().getString("club01_mark"), ivClubMark01, GgApplication.img_opt_club_mark);
		tvClubName01.setText(getIntent().getExtras().getString("club01_name"));
		imgLoader.displayImage(getIntent().getExtras().getString("club02_mark"), ivClubMark02, GgApplication.img_opt_club_mark);
		tvClubName02.setText(getIntent().getExtras().getString("club02_name"));
		tvPlayerCount.setText(String.format("%s%s", getIntent().getExtras().getInt("player_count"), getString(R.string.player_number)));
		String date = getIntent().getExtras().getString("game_date");
		date = date.concat("/");
		date = date.concat(StringUtil.getWeekDay(getIntent().getExtras().getString("game_wday")));
		tvGameDate.setText(date);
		if (state == CommonConsts.GAME_STATE_FINISHED || state == CommonConsts.GAME_STATE_CANCELED) {
			tvGameTime.setText(getIntent().getExtras().getString("result"));
			tvGameRemainTime.setVisibility(View.GONE);
		} else 
			tvGameTime.setText(getIntent().getExtras().getString("game_time"));
		tvStadium.setText(getIntent().getExtras().getString("stadium"));
		org_game_datetime = DateUtil.getCurrentYear() + "-" + getIntent().getExtras().getString("game_date")
				+ " " + getIntent().getExtras().getString("game_time") + ":00";
//		startCountDown();
	}

	@Override
	public void onClick(View view) {
	}
	
	public void onResume() {
		super.onResume();
		
		if (firstUpdate){
			startAttachPlayerList(true);
			firstUpdate = false;
		}
	}

	@Override
	public void onRefresh(int id) {
		adapter.clearData();
		adapter.notifyDataSetChanged();
		
		startAttachPlayerList(true);
		return;
	}

	@Override
	public void onLoadMore(int id) {
		startAttachPlayerList(false);
	}
	
	private void startAttachPlayerList(boolean showdlg) {
		if(!NetworkUtil.isNetworkAvailable(GameDetailActivity.this))
			return;
		
		if (showdlg){
			dlg = new GgProgressDialog(GameDetailActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetApplyPlayerTask task = new GetApplyPlayerTask(GameDetailActivity.this, adapter, club_id, game_id, CommonConsts.GAME_DETAIL);
		task.execute();
	}
	
	public void stopAttachPlayerList(boolean hasMore) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		adapter.notifyDataSetChanged();
		playerListView.setPullLoadEnable(hasMore);
	}
	
	public void startSetUsersPoint(boolean showdlg, Object[] param){
		if (!NetworkUtil.isNetworkAvailable(GameDetailActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(GameDetailActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		SetUserPointTask task = new SetUserPointTask(GameDetailActivity.this, param);
		task.execute();
	}
	
	public void stopSetUsersPoint(int data_result) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (data_result == 0) {
			Toast.makeText(GameDetailActivity.this, getString(R.string.update_failed), Toast.LENGTH_SHORT).show();
			return;
		} else {
			Toast.makeText(GameDetailActivity.this, getString(R.string.update_success), Toast.LENGTH_SHORT).show();
		}
	}
	
	public void clubInfo(int clubId){
		if (myClubData.isManagerOfClub(Integer.valueOf(clubId))){
			Intent intent = new Intent(GameDetailActivity.this, CreateClubActivity.class);
			intent.putExtra(CommonConsts.CLUB_ID_TAG, clubId);
			intent.putExtra(CommonConsts.CLUB_TYPE_TAG, CommonConsts.EDIT_CLUB);
			startActivity(intent);
			return;
		}
		Intent intent = new Intent(GameDetailActivity.this, ClubInfoActivity.class);
		intent.putExtra(GgIntentParams.CLUB_ID, String.valueOf(clubId));
		startActivity(intent);
	}
}
