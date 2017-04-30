package com.goalgroup.ui;

import java.util.Calendar;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.Dialog;
import android.app.TimePickerDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.TimePicker;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.GetChallInfoTask;
import com.goalgroup.task.NewGameTask;
import com.goalgroup.task.SendChallTask;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;

public class NewChallengeActivity extends Activity implements OnClickListener {
	
	private static final int DATE_DIALOG_ID = 0;
	private static final int TIME_DIALOG_ID = 1;
    
	private TextView tvTitle;
	private Button btnBack;
	private ImageView imgView;
	private Button btnSave;
	private TextView btnText;
	
	private View areaOwnTeam;
	private View areaOpponentTeam;
	private View areaChallDate;
	private View areaChallTime;
	private View areaPlayerCountMode;
	private View areaStadiumArea;
	private View areaMoneySplitMode;
	
	private TextView tvOpponentTeam;
	private EditText etOpponentTeam;
	private TextView tvClub;
	private TextView tvChallDate;
	private Button btnSend;
	
	private String[] clubName;
	private int[] clubId;
	private int selectedClub = 0;
	private int oc_selected;
//	private String[] all_clubName;
//	private String[] all_clubId;
//	private int selectedOppoClub = 0;
//	private int opc_selected;
	
	private String opponentTeam = "";
	private String opponentID = "";
	
	private int year;
	private int month;
	private int day;
	private String challenge_date;
	
	private TextView tvChallTime;
	private int hour;
	private int min;
	private String challenge_time;
	
	private TextView tvPCMode;	
	private String[] player_count_mode;
	private int pcm_selected = 0;
	
	private TextView tvStadiumArea;
	private EditText etStadiumAddress;
	private String[] distId;
	private String[] distName;
	private String selectedStadiumArea;
	private String stadiumAddress;
	private int s_selected = 0;
	
	private TextView tvMSMode;
	private String[] money_split_mode;
	private int msm_selected = 0;
	
	private int challenge_id;
	private int type;
	private int challType;
	
	private GgProgressDialog dlg;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_new_challenge);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.create_challenge));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				setResult(RESULT_OK, getIntent());
				getIntent().putExtra("CHALL_DATE", challenge_date);
				getIntent().putExtra("CHALL_TIME", challenge_time.concat(":00"));
				getIntent().putExtra("PLAYER_COUNT", (pcm_selected + 5));
				finish();
			}
		});
		
		imgView = (ImageView)findViewById(R.id.top_img);
		btnSave = (Button) findViewById(R.id.btn_view_more);
		imgView.setBackgroundResource(R.drawable.btn_new_chall);
		imgView.setVisibility(View.VISIBLE);
		btnSave.setVisibility(View.VISIBLE);
		btnSave.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				boolean isChall = GgApplication.getInstance().getChallFlag();
				startSendChallenge(true, isChall);
			}
		});
		
		btnText = (TextView)findViewById(R.id.common_action_text);
		btnText.setText(R.string.complete);
		
		challenge_id = 0;
		
		type = CommonConsts.NEW_CHALLENGE;
		challenge_id = 0;
		challType = CommonConsts.CHALL_TYPE_ALL_CHALLENGE;
		
		MyClubData mClubData;
		
		mClubData = new MyClubData();
		
		clubName = mClubData.getOwnerClubNames();
		clubId = mClubData.getOwnerClubIDs();
		
		
		areaOwnTeam = findViewById(R.id.area_own_team);
		areaOwnTeam.setOnClickListener(this);
		
		areaOpponentTeam = findViewById(R.id.area_opponent_team);
//		areaOpponentTeam.setOnClickListener(this);
//		ImageView chall02_arrow = (ImageView)findViewById(R.id.new_chall_info_02_move_next);
//		chall02_arrow.setVisibility(View.INVISIBLE);
		tvOpponentTeam = (TextView)findViewById(R.id.new_chall_info_02_value);
		etOpponentTeam = (EditText)findViewById(R.id.new_game_oppo_team);
		if (GgApplication.getInstance().getChallFlag() == false) {
			opponentTeam = getIntent().getExtras().getString(GgIntentParams.CLUB_NAME);
			opponentID = getIntent().getExtras().getString(GgIntentParams.CLUB_ID);
			tvOpponentTeam.setText(opponentTeam);
		} else {
			tvOpponentTeam.setText("");
		}
		
		areaChallDate = findViewById(R.id.area_chall_date);
		areaChallDate.setOnClickListener(this);
		areaChallTime = findViewById(R.id.area_chall_time);
		areaChallTime.setOnClickListener(this);
		areaPlayerCountMode = findViewById(R.id.area_player_count_mode);
		areaPlayerCountMode.setOnClickListener(this);
		areaStadiumArea = findViewById(R.id.area_stadium_area);
		areaStadiumArea.setOnClickListener(this);
		areaMoneySplitMode = findViewById(R.id.area_money_split_mode);
		areaMoneySplitMode.setOnClickListener(this);
		
		tvClub = (TextView)findViewById(R.id.new_chall_info_01_value);
		tvClub.setText(clubName[0]);
		selectedClub = clubId[0];
		tvChallDate = (TextView)findViewById(R.id.chall_date);
		final Calendar c = Calendar.getInstance();
        year = c.get(Calendar.YEAR);
        month = c.get(Calendar.MONTH);
        day = c.get(Calendar.DAY_OF_MONTH);
        updateDate();
        
        tvChallTime = (TextView)findViewById(R.id.chall_time);
        hour = c.get(Calendar.HOUR_OF_DAY);
        min = c.get(Calendar.MINUTE);
        updateTime();
        
        tvPCMode = (TextView)findViewById(R.id.player_count_mode);
        tvStadiumArea = (TextView)findViewById(R.id.chall_stadium_area);
        etStadiumAddress = (EditText)findViewById(R.id.chall_stadium_address);
        tvMSMode = (TextView)findViewById(R.id.money_split_mode);
        
        player_count_mode = new String[7];
		player_count_mode[0] = "5个制";
		player_count_mode[1] = "6个制";
		player_count_mode[2] = "7个制";
		player_count_mode[3] = "8个制";
		player_count_mode[4] = "9个制";
		player_count_mode[5] = "10个制";
		player_count_mode[6] = "11个制";
		
        money_split_mode = new String[3];
		money_split_mode[0] = "主队支付";
		money_split_mode[1] = "客队支付";
		money_split_mode[2] = "AA制";
		
//        club_id = getIntent().getExtras().getString(GgIntentParams.CLUB_ID);
		challType = getIntent().getExtras().getInt("challType");
		if (challType == CommonConsts.CHALLENGE_GAME)
			tvTitle.setText(getString(R.string.create_challenge));
		else if (challType == CommonConsts.PROCLAIM_GAME)
			tvTitle.setText(getString(R.string.create_proclaim));
        
        type = getIntent().getExtras().getInt("type");
        
        btnSend = (Button)findViewById(R.id.send_challenge);
		btnSend.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				boolean isChall = GgApplication.getInstance().getChallFlag();
				startSendChallenge(true, isChall);
			}
		});
//        ImageView arrow = (ImageView)this.findViewById(R.id.new_chall_info_01_move_next);
        if (type == CommonConsts.EDIT_GAME){
        	tvTitle.setText(getString(R.string.edit_game));
        	btnText.setText(R.string.save_status);
        	challenge_id = getIntent().getExtras().getInt("challenge_id");
//        	arrow.setVisibility(View.GONE);
//        	challType = getIntent().getExtras().getInt("challType");
        	startAttacthChallInfo(true);
        } else if (type == CommonConsts.NEW_GAME){
        	tvTitle.setText(getString(R.string.edit_game));
        	int myClubId = Integer.valueOf(getIntent().getExtras().getString(GgIntentParams.CLUB_ID));
        	selectedClub = myClubId;
        	String myClubName = mClubData.getNameFromID(myClubId);
        	tvClub.setText(myClubName);
//        	arrow.setVisibility(View.GONE);
        	areaOwnTeam.setEnabled(false);
//        	chall02_arrow.setVisibility(View.GONE);
        	tvOpponentTeam.setVisibility(View.GONE);
        	etOpponentTeam.setVisibility(View.VISIBLE);
        	areaMoneySplitMode.setVisibility(View.GONE);
        } else if (type == CommonConsts.SHOW_GAME){
        	challenge_id = getIntent().getExtras().getInt("challenge_id");
        	startAttacthChallInfo(true);
        	tvOpponentTeam.setEnabled(false);
        	etOpponentTeam.setEnabled(false);
        	tvClub.setEnabled(false);
        	areaOpponentTeam.setEnabled(false);
        	areaChallDate.setEnabled(false);
        	areaChallTime.setEnabled(false);
        	areaPlayerCountMode.setEnabled(false);
        	areaStadiumArea.setEnabled(false);
        	tvChallDate.setEnabled(false);
        	etStadiumAddress.setEnabled(false);
        	areaOwnTeam.setEnabled(false);
        	areaMoneySplitMode.setEnabled(false);
        	btnSend.setVisibility(View.GONE);
        	btnSave.setVisibility(View.GONE);
        	imgView.setVisibility(View.GONE);
        	btnText.setVisibility(View.GONE);
        }
	}
	
	public void setUI(String infos) {
		tvTitle.setText(getString(R.string.edit_game));
		
		tvClub.setText(JSONUtil.getValue(infos, "club_name_01"));
		selectedClub = JSONUtil.getValueInt(infos, "club_id_01");
    	areaOwnTeam.setEnabled(false);
    	opponentTeam = JSONUtil.getValue(infos, "club_name_02");
    	tvOpponentTeam.setText(opponentTeam);
    	opponentID = JSONUtil.getValue(infos, "club_id_02");
    	areaOpponentTeam.setEnabled(false);
    	String date = JSONUtil.getValue(infos, "game_date");
    	String[] arrDateTime = date.split("-");
    	year = Integer.valueOf(arrDateTime[0]);
    	month = Integer.valueOf(arrDateTime[1]) - 1;
    	day = Integer.valueOf(arrDateTime[2]);
    	updateDate();
    	String time = JSONUtil.getValue(infos, "game_time");
    	arrDateTime = new String[2];
    	arrDateTime = time.split(":");
    	hour = Integer.valueOf(arrDateTime[0]);
    	min = Integer.valueOf(arrDateTime[1]);
    	updateTime();
    	String player_count = JSONUtil.getValue(infos, "player_count");
    	pcm_selected = Integer.valueOf(player_count) - 5;
    	tvPCMode.setText(player_count_mode[pcm_selected]);
    	String stadium_area = JSONUtil.getValue(infos, "stadium_area");
    	tvStadiumArea.setText(stadium_area);
    	selectedStadiumArea = GgApplication.getInstance().getIDFromName(stadium_area,CommonConsts.DISTRICT);
    	String stadium_address = JSONUtil.getValue(infos, "stadium_address");
    	etStadiumAddress.setText(stadium_address);
    	s_selected = Integer.valueOf(selectedStadiumArea) - 1; 
    	String money_split = JSONUtil.getValue(infos, "money_split");
    	msm_selected = Integer.valueOf(money_split);
		tvMSMode.setText(money_split_mode[msm_selected]);
	}
	
	@Override
	public void onResume() {
		super.onResume();
	}
	
	@Override
	public void onClick(View view) {
		AlertDialog dialog;
		switch (view.getId()) {
		case R.id.area_own_team:
			dialog = new AlertDialog.Builder(NewChallengeActivity.this)
			.setTitle(getString(R.string.team_host))
			.setCancelable(true)
			.setSingleChoiceItems(clubName, oc_selected, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int item) {
					oc_selected = item;
	            }
			})
			.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					String value = clubName[oc_selected];
					tvClub.setText(value);
					selectedClub = clubId[oc_selected];
				}
			}).create();
			
			dialog.show();
			break;
/*		case R.id.area_opponent_team:
			if (type == CommonConsts.NEW_GAME) {
				all_clubName = GgApplication.getInstance().getAllClubName();
				all_clubId = GgApplication.getInstance().getAllClubId();
				dialog = new AlertDialog.Builder(NewChallengeActivity.this)
				.setTitle(getString(R.string.team_invt))
				.setCancelable(true)
				.setSingleChoiceItems(all_clubName, opc_selected, new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int item) {
						opc_selected = item;
		            }
				})
				.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						String value = all_clubName[opc_selected];
						tvOpponentTeam.setText(value);
						selectedOppoClub = Integer.valueOf(all_clubId[opc_selected]);
					}
				}).create();
				
				dialog.show();
			}
			break;*/
		case R.id.area_chall_date:
			showDialog(DATE_DIALOG_ID);
			break;
		case R.id.area_chall_time:
			showDialog(TIME_DIALOG_ID);
			break;
		case R.id.area_player_count_mode:
			
			dialog = new AlertDialog.Builder(NewChallengeActivity.this)
			.setTitle(getString(R.string.players_mode))
			.setCancelable(true)
			.setSingleChoiceItems(player_count_mode, pcm_selected, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int item) {
					pcm_selected = item;
	            }
			})
			.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					String value = player_count_mode[pcm_selected];
					tvPCMode.setText(value);
				}
			}).create();
			
			dialog.show();
			break;
		case R.id.area_stadium_area:
			distName = GgApplication.getInstance().getDistrictName();
			distId = GgApplication.getInstance().getDistrictID();
			if (distId.length < 1) {
				Toast.makeText(NewChallengeActivity.this, getString(R.string.none_area_data), Toast.LENGTH_SHORT).show();
				return;
			}
			dialog = new AlertDialog.Builder(NewChallengeActivity.this)
			.setTitle(getString(R.string.game_stadium))
			.setCancelable(true)
			.setSingleChoiceItems(distName, s_selected, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int item) {
					s_selected = item;
	            }
			})
			.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					String value = distName[s_selected];
					tvStadiumArea.setText(value);
					selectedStadiumArea = distId[s_selected];
				}
			}).create();
			
			dialog.show();
			break;
		case R.id.area_money_split_mode:
			
			dialog = new AlertDialog.Builder(NewChallengeActivity.this)
			.setTitle(getString(R.string.payment_mode))
			.setCancelable(true)
			.setSingleChoiceItems(money_split_mode, msm_selected, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int item) {
					msm_selected = item;
	            }
			})
			.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					String value = money_split_mode[msm_selected];
					tvMSMode.setText(value);
				}
			}).create();
			
			dialog.show();
			break;
		}
	}
	
	@Override
    protected Dialog onCreateDialog(int id) {
        switch (id) {
        case DATE_DIALOG_ID:
            return new DatePickerDialog(this, mDateSetListener, year, month, day);
        case TIME_DIALOG_ID:
            return new TimePickerDialog(this, mTimeSetListener, hour, min, false);
        }
        return null;
    }
	
	private DatePickerDialog.OnDateSetListener mDateSetListener =
            new DatePickerDialog.OnDateSetListener() {

                public void onDateSet(DatePicker view, int yearValue, int monthOfYear,
                        int dayOfMonth) {
                    year = yearValue;
                    month = monthOfYear;
                    day = dayOfMonth;
                    updateDate();
                }
            };

    private TimePickerDialog.OnTimeSetListener mTimeSetListener =
	        new TimePickerDialog.OnTimeSetListener() {
	
	            public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
	                hour = hourOfDay;
	                min = minute;
	                updateTime();
	            }
	        };
	
	private void updateDate() {
		tvChallDate.setText(
			new StringBuilder().append(year).append("-").
				append(pad(month+1)).append("-").
				append(pad(day)));
		challenge_date = tvChallDate.getText().toString();
	}
	
	private void updateTime() {
		tvChallTime.setText(
			new StringBuilder().
				append(pad(hour)).append(":").
				append(pad(min)));
		challenge_time = tvChallTime.getText().toString();
	}
	
	private String pad(int c) {
        if (c >= 10)
            return String.valueOf(c);
        else
            return "0" + String.valueOf(c);
    }
	
	public void startSendChallenge(boolean showdlg, boolean isChall) {
		if(challType == CommonConsts.CUSTOM_GAME){
			opponentTeam = etOpponentTeam.getText().toString();
			
		} else
			opponentTeam = tvOpponentTeam.getText().toString();
		stadiumAddress = etStadiumAddress.getText().toString();
		if(selectedClub == 0) {
			Toast.makeText(NewChallengeActivity.this, getString(R.string.select_own_club), Toast.LENGTH_SHORT).show();
			return;
		} else if(type == CommonConsts.NEW_GAME && StringUtil.isEmpty(opponentTeam)) {
			Toast.makeText(NewChallengeActivity.this, getString(R.string.input_oppo_club), Toast.LENGTH_SHORT).show();
			return;
		} else if (!StringUtil.dateCompare4(year, month, day, hour)) {
			Toast.makeText(NewChallengeActivity.this, getString(R.string.error_select_date), Toast.LENGTH_SHORT).show();
			return;
		} else if (tvPCMode.getText().equals(null) || tvPCMode.getText().equals("无")) {
			Toast.makeText(NewChallengeActivity.this, getString(R.string.select_players), Toast.LENGTH_SHORT).show();
			return;
		} else if (selectedStadiumArea == null) {
			Toast.makeText(NewChallengeActivity.this, getString(R.string.new_chall_stadium_error), Toast.LENGTH_SHORT).show();
			return;
		} else if (StringUtil.isEmpty(stadiumAddress)){
			Toast.makeText(NewChallengeActivity.this, getString(R.string.new_chall_stadium_address_error), Toast.LENGTH_SHORT).show();
			return;
		} else if (containsSpecChar(stadiumAddress)) {
			Toast.makeText(NewChallengeActivity.this, getString(R.string.register_input_invalid), Toast.LENGTH_SHORT).show();
			return;
		} else {
			if (!NetworkUtil.isNetworkAvailable(NewChallengeActivity.this))
				return;
			
			if (showdlg) {
				dlg = new GgProgressDialog(NewChallengeActivity.this, getString(R.string.wait));
				dlg.show();
			}
			
			if (type == CommonConsts.NEW_GAME) {
				Object[] gameInfo;
				gameInfo = new Object[8];
				gameInfo[0] = selectedClub;
				gameInfo[1] = challenge_date;
				gameInfo[2] = challenge_time.concat(":00");
				gameInfo[3] = String.valueOf(pcm_selected + 5);
				gameInfo[4] = selectedStadiumArea;
				gameInfo[5] = stadiumAddress;
				gameInfo[6] = String.valueOf(msm_selected);
				gameInfo[7] = opponentTeam;
				
				NewGameTask task = new NewGameTask(this, gameInfo);
				task.execute();
				
			} else {
				Object[] challInfo;
				challInfo = new Object[11];
				challInfo[0] = selectedClub;
				challInfo[1] = challenge_date;
				challInfo[2] = challenge_time.concat(":00");
				challInfo[3] = String.valueOf(pcm_selected + 5);
				challInfo[4] = selectedStadiumArea;
				challInfo[5] = stadiumAddress;
				challInfo[6] = String.valueOf(msm_selected);
				challInfo[7] = opponentID;
				if (StringUtil.isEmpty(opponentTeam)) {
					challInfo[8] = 0;
				} else {
					challInfo[8] = 1;
				}
				challInfo[9] = type;
				challInfo[10] = challenge_id;
				SendChallTask task = new SendChallTask(this, challInfo);
				task.execute();
			}
		}
	}
	
	public void stopSendChallenge(int result) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (result == 0) {
			Toast.makeText(NewChallengeActivity.this, getString(R.string.register_failed), Toast.LENGTH_SHORT).show();
			return;
		}
		
		if (type == CommonConsts.NEW_CHALLENGE) {
			if (GgApplication.getInstance().getChallFlag() == true) {
				Toast.makeText(NewChallengeActivity.this, getString(R.string.challenge_success), Toast.LENGTH_SHORT).show();
			} else {
				Toast.makeText(NewChallengeActivity.this, getString(R.string.proclaim_success), Toast.LENGTH_SHORT).show();
			}
			setResult(RESULT_OK, getIntent());
			finish();
		} else if (type == CommonConsts.NEW_GAME) {
			Toast.makeText(NewChallengeActivity.this, getString(R.string.register_success), Toast.LENGTH_SHORT).show();
			finish();
		} else 
			Toast.makeText(NewChallengeActivity.this, getString(R.string.edit_succeed), Toast.LENGTH_SHORT).show();
	}
	
	private void startAttacthChallInfo(boolean showdlg){
		if(!NetworkUtil.isNetworkAvailable(NewChallengeActivity.this))
			return;
		
		if(showdlg) {
			dlg = new GgProgressDialog(NewChallengeActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetChallInfoTask task = new GetChallInfoTask(NewChallengeActivity.this, challenge_id, challType);
		task.execute();
	}
	
	public void stopAttachChallInfo(String infos) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (StringUtil.isEmpty(infos)) {
			Toast.makeText(NewChallengeActivity.this, getString(R.string.none), Toast.LENGTH_LONG).show();
			finish();
			return;
		}
		
		setUI(infos);
	}
	public boolean containsSpecChar(String username) {
		String regEx="[`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？\t\f\n\r[[:space:]]]"; 
        Pattern p = Pattern.compile(regEx); 
        Matcher m = p.matcher(username);
        
        return m.find();
        
	}
}
