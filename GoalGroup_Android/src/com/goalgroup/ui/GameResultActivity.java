package com.goalgroup.ui;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.task.GetGameResultTask;
import com.goalgroup.task.SetGameResultTask;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.NetworkUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class GameResultActivity extends Activity {
	
	private TextView tvTitle;
	private Button btnBack;
	private GgProgressDialog dlg;
	
	private View areaTotal;
	private ImageView clubMark01;
	private TextView clubName01;
	private ImageView clubMark02;
	private TextView clubName02;
	private TextView gameResult;
	private EditText result0101;
	private EditText result0102;
	private EditText result0201;
	private EditText result0202;
	
	private Button btnOk;
	
	private ImageLoader imgLoader;
	
	private int clubId;
	private int gameId;
	private int gameState;
	private int matchResult;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_game_result);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.game_result));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		clubMark01 = (ImageView)findViewById(R.id.club_mark_01);
		clubName01 = (TextView)findViewById(R.id.club_name_01);
		clubMark02 = (ImageView)findViewById(R.id.club_mark_02);
		clubName02 = (TextView)findViewById(R.id.club_name_02);
		gameResult = (TextView)findViewById(R.id.game_result);
		result0101 = (EditText)findViewById(R.id.result_01_01);
		result0102 = (EditText)findViewById(R.id.result_01_02);
		result0201 = (EditText)findViewById(R.id.result_02_01);
		result0202 = (EditText)findViewById(R.id.result_02_02);
		
		imgLoader = GgApplication.getInstance().getImageLoader();
		
		areaTotal = findViewById(R.id.area_result_total);
		areaTotal.setVisibility(View.GONE);
		
		clubId = getIntent().getExtras().getInt(ChatConsts.CLUB_ID_TAG);
		gameId = getIntent().getExtras().getInt(ChatConsts.GAME_ID);
		gameState = getIntent().getExtras().getInt(ChatConsts.GAME_STATE);
		
		matchResult = 3;
		
		btnOk = (Button)findViewById(R.id.save);
		btnOk.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View view) {
				startSetResult(true);
			}
		});
	}
	
	@Override
	public void onResume() {
		super.onResume();
		startGetResult(true);
	}
	
	public void startGetResult(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(GameResultActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(GameResultActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetGameResultTask task = new GetGameResultTask(this, Integer.toString(clubId), Integer.toString(gameId));
		task.execute();
	}
	
	public void stopGetResult(boolean success, String result) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (!success) {
			return;
		}
		
		areaTotal.setVisibility(View.VISIBLE);
		
		clubName01.setText(JSONUtil.getValue(result, "name1"));
		imgLoader.displayImage(JSONUtil.getValue(result, "photo_url1"), clubMark01, GgApplication.img_opt_club_mark);
		clubName02.setText(JSONUtil.getValue(result, "name2"));
		imgLoader.displayImage(JSONUtil.getValue(result, "photo_url2"), clubMark02, GgApplication.img_opt_club_mark);
		result0101.setText(Integer.toString(JSONUtil.getValueInt(result, "fhalf_goal1")));
		result0102.setText(Integer.toString(JSONUtil.getValueInt(result, "fhalf_goal2")));
		result0201.setText(Integer.toString(JSONUtil.getValueInt(result, "shalf_goal1")));
		result0202.setText(Integer.toString(JSONUtil.getValueInt(result, "shalf_goal2")));
		gameResult.setText(
				Integer.toString(JSONUtil.getValueInt(result, "fhalf_goal1") + JSONUtil.getValueInt(result, "shalf_goal1"))
				+ " - "
				+ Integer.toString(JSONUtil.getValueInt(result, "fhalf_goal2") + JSONUtil.getValueInt(result, "shalf_goal2")));
		matchResult = JSONUtil.getValueInt(result, "Match_Result");
		
		if (clubId != JSONUtil.getValueInt(result, "id1") || (matchResult == CommonConsts.GAME_STATE_FINISHED)){
			result0101.setEnabled(false);
			result0102.setEnabled(false);
			result0201.setEnabled(false);
			result0202.setEnabled(false);
//			btnOk.setText(getString(R.string.ok));
			btnOk.setVisibility(View.GONE);
		}
		
//		if (matchResult == CommonConsts.GAME_STATE_TEAM1_CONF && clubId == JSONUtil.getValueInt(result, "id1"))
//			matchResult = CommonConsts.GAME_STATE_TEAM1;
//		else if (matchResult == CommonConsts.GAME_STATE_TEAM2_CONF && clubId == JSONUtil.getValueInt(result, "id2"))
//			matchResult = CommonConsts.GAME_STATE_TEAM2;
		if (matchResult == CommonConsts.GAME_STATE_WIN 
				|| matchResult == CommonConsts.GAME_STATE_DEFEAT
				|| matchResult == CommonConsts.GAME_STATE_DRAW) {
			result0101.setEnabled(false);
			result0102.setEnabled(false);
			result0201.setEnabled(false);
			result0202.setEnabled(false);
			btnOk.setVisibility(View.GONE);
		}
	}
	
	public void startSetResult(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(GameResultActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(GameResultActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		SetGameResultTask task = new SetGameResultTask(this, Integer.toString(clubId), Integer.toString(gameId), 
				result0101.getText().toString(), result0102.getText().toString(), 
				result0201.getText().toString(), result0202.getText().toString(), Integer.toString(matchResult));
		task.execute();
	}
	
	public void stopSetResult(int status) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		switch (status){
		case 0:
			Toast.makeText(GameResultActivity.this, getString(R.string.save_failed), Toast.LENGTH_SHORT).show();
			break;
		case 1:
			Toast.makeText(GameResultActivity.this, getString(R.string.save_success), Toast.LENGTH_SHORT).show();
			gameResult.setText(
					Integer.toString(Integer.valueOf(result0101.getText().toString()) + Integer.valueOf(result0201.getText().toString()))
					+ " - "
					+ Integer.toString(Integer.valueOf(result0102.getText().toString()) + Integer.valueOf(result0202.getText().toString()))
					);
			btnOk.setVisibility(View.GONE);
			result0101.setEnabled(false);
			result0102.setEnabled(false);
			result0201.setEnabled(false);
			result0202.setEnabled(false);
			break;
		case 2:
			Toast.makeText(GameResultActivity.this, getString(R.string.confirm_success), Toast.LENGTH_SHORT).show();
			break;
		case 3:
			Toast.makeText(GameResultActivity.this, getString(R.string.game_no_finished), Toast.LENGTH_SHORT).show();
			break;
		}
	}
}
