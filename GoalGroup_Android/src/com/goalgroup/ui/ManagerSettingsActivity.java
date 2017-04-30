package com.goalgroup.ui;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.info.history.ChatHistoryDB;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.task.GetUserClubSettingTask;
import com.goalgroup.task.SetUserClubSettingTask;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;

public class ManagerSettingsActivity extends Activity implements OnClickListener {
	
	private TextView tvTitle;
	private Button btnBack;
	private ImageView imgView;
	private Button btnSave;
	private TextView btnText;
	
	private boolean m_fClean = false;
	
	private GgProgressDialog dlg;
	
	private ImageView imgHealth;
	private ImageView imgNewMsg;
	private ImageView imgMatch;
	private ImageView imgOffNotice;
	private ImageView imgEnterReq;
	private ImageView imgServer;
	private ImageView imgAccept;
	private TextView tvAccept;
	private RelativeLayout acceptArea;
	
	private View clearHistory;
	private View report;
	
	private int club_id;
	private int user_id;
	private int user_status = 0;
	
	private ChatHistoryDB historyDB;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_manager_settings);
		
		Bundle bdExtra = getIntent().getExtras();
		club_id = bdExtra.getInt(ChatConsts.CLUB_ID_TAG);
		user_id = bdExtra.getInt(ChatConsts.REQ_USER_ID);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.manager_settings_title));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(this);
		
		
		imgView = (ImageView)findViewById(R.id.top_img);
		imgView.setBackgroundResource(R.drawable.save_ico);
		btnSave = (Button)findViewById(R.id.btn_view_more);
		
		imgView.setVisibility(View.GONE);
		btnSave.setVisibility(View.GONE);
		
//		btnSave = (Button)findViewById(R.id.btn_save_setting);
		btnSave.setOnClickListener(this);
		
		btnText = (TextView) findViewById(R.id.common_action_text);
		btnText.setText(R.string.save_status);
		btnText.setVisibility(View.GONE);
		
		imgHealth = (ImageView)findViewById(R.id.switch_health);
		imgHealth.setOnClickListener(this);
		imgNewMsg = (ImageView)findViewById(R.id.switch_new_msg);
		imgNewMsg.setOnClickListener(this);
		imgMatch = (ImageView)findViewById(R.id.switch_match);
		imgMatch.setOnClickListener(this);
		imgOffNotice = (ImageView)findViewById(R.id.switch_off_notice);
		imgOffNotice.setOnClickListener(this);
		imgEnterReq = (ImageView)findViewById(R.id.switch_enter_req);
		imgEnterReq.setOnClickListener(this);
		imgServer = (ImageView)findViewById(R.id.switch_server);
		imgServer.setOnClickListener(this);
		imgAccept = (ImageView)findViewById(R.id.switch_accept);
		imgAccept.setOnClickListener(this);
		tvAccept = (TextView)findViewById(R.id.tv_switch_accept);
		acceptArea = (RelativeLayout)findViewById(R.id.switch_accept_area);
		
		//Post Check
		String[] club_ids = GgApplication.getInstance().getClubId();
		int index = -1;
		for(int i = 0; i < club_ids.length; i++) {
			if(club_ids[i].equals(String.valueOf(club_id)))
				index = i;
		}
		int post = GgApplication.getInstance().getPost()[index];
		if(post != 1) {
			acceptArea.setVisibility(View.GONE);
		}
			
		
		clearHistory = (RelativeLayout)findViewById(R.id.clear_history);
		clearHistory.setOnClickListener(this);
		report = (RelativeLayout)findViewById(R.id.send_opinion);
		report.setOnClickListener(this);
		
		historyDB = GgApplication.getInstance().getChatInfo().getChatHistDB();
		
		startGetStatus(true);
	}

	@Override
	public void onClick(View view) {
		Intent intent;
		AlertDialog dialog;
		switch (view.getId()) {
		case R.id.btn_view_more:
			startSettingStatus(true);
			break;
		case R.id.btn_back:
			if(m_fClean)
				setResult(RESULT_OK, getIntent());
			finish();
			break;
		case R.id.switch_health:
			setStatusValue(0);
			break;
		case R.id.switch_new_msg:
			setStatusValue(2);
			break;
		case R.id.switch_match:
			setStatusValue(3);
			break;
		case R.id.switch_off_notice:
			setStatusValue(4);
			break;
		case R.id.switch_enter_req:
			setStatusValue(5);
			break;
		case R.id.switch_server:
			setStatusValue(6);
			break;
		case R.id.switch_accept:
			setStatusValue(7);
			break;
		case R.id.clear_history:
			dialog = new AlertDialog.Builder(ManagerSettingsActivity.this)
			.setTitle(R.string.chat_clear_history)
			.setMessage(R.string.chat_clear_history)
			.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					ChatRoomInfo room = GgApplication.getInstance().getChatInfo().getClubChatRoom(club_id);
					int curRoomId = room.getRoomId();
					try {
						historyDB.removeMsgs(Integer.toString(curRoomId));
						Toast.makeText(ManagerSettingsActivity.this, getString(R.string.chat_clear_history_success), Toast.LENGTH_LONG).show();
						m_fClean = true;
					} catch(Exception ex) {
						ex.printStackTrace();
						Toast.makeText(ManagerSettingsActivity.this, getString(R.string.chat_clear_history_failed), Toast.LENGTH_LONG).show();
					}
				}
			})
			.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {					
				}
			}).create();
			
			dialog.show();
			break;
		case R.id.send_opinion:
			intent = new Intent(ManagerSettingsActivity.this, ReportActivity.class);
			intent.putExtra("type", CommonConsts.REPORT_TYPE);
			startActivity(intent);
			break;
		}
	}
	
	public void startGetStatus(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(ManagerSettingsActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ManagerSettingsActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetUserClubSettingTask task = new GetUserClubSettingTask(this, Integer.toString(club_id), Integer.toString(user_id));
		task.execute();
	}
	
	private void setControlStatus() {
		imgHealth.setBackgroundResource((user_status & 0x01) == 0x01 ? R.drawable.alarm_off: R.drawable.alarm_on);
		imgNewMsg.setBackgroundResource((user_status & 0x04) == 0x04 ? R.drawable.alarm_on : R.drawable.alarm_off);
		imgMatch.setBackgroundResource((user_status & 0x08) == 0x08 ? R.drawable.alarm_on : R.drawable.alarm_off);
		imgOffNotice.setBackgroundResource((user_status & 0x10) == 0x10 ? R.drawable.alarm_on : R.drawable.alarm_off);
		imgEnterReq.setBackgroundResource((user_status & 0x20) == 0x20 ? R.drawable.alarm_on : R.drawable.alarm_off);
		imgServer.setBackgroundResource((user_status & 0x40) == 0x40 ? R.drawable.alarm_on : R.drawable.alarm_off);
		imgAccept.setBackgroundResource((user_status & 0x80) == 0x80 ? R.drawable.alarm_on : R.drawable.alarm_off);
	}

	public void stopGetStatus(String datas) {

		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (StringUtil.isEmpty(datas)) {
			Toast.makeText(ManagerSettingsActivity.this, getString(R.string.get_user_club_setting_fail), Toast.LENGTH_SHORT).show();
			return;
		}
		
		user_status = Integer.parseInt(JSONUtil.getValue(datas, "status"));
		setControlStatus();
	}
	
	private void setStatusValue(int pos) {
		int posValue = (int)(Math.pow(2, pos));
		
		if ((user_status & posValue) == posValue) {
			user_status &= (255 - posValue);
		}
		else
			user_status |= posValue;
		
		setControlStatus();
		startSettingStatus(true);
	}
	
	public void startSettingStatus(boolean showdlg) {
		
		if (!NetworkUtil.isNetworkAvailable(ManagerSettingsActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ManagerSettingsActivity.this, getString(R.string.wait));
			dlg.show();
		}
				
		SetUserClubSettingTask task = new SetUserClubSettingTask(
													this,
													Integer.toString(club_id),
													Integer.toString(user_id),
													Integer.toString(user_status));
		task.execute();
	}
	
	public void stopSettingStatus(boolean success) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (!success) {
			Toast.makeText(ManagerSettingsActivity.this, getString(R.string.set_user_club_setting_fail), Toast.LENGTH_SHORT).show();
			return;
		}
		Toast.makeText(ManagerSettingsActivity.this, getString(R.string.set_user_club_setting_success), Toast.LENGTH_SHORT).show();
		
	}
}
