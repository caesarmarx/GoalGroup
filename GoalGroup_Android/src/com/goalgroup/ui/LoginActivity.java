package com.goalgroup.ui;

import org.json.JSONObject;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.component.ChatBaseActivity;
import com.goalgroup.common.GgBroadCast;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;

import cn.jpush.android.api.JPushInterface;

public class LoginActivity extends ChatBaseActivity {

	private GgProgressDialog dlg;
	private EditText userid;
	private EditText userpwd;
	private Button btnLogin = null;
	private Button btnRegister = null;
	private String username;
	private String password;
	private boolean first = true;
	private boolean userRegist = false;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_login);
		
		userid = (EditText)findViewById(R.id.login_edit_id);
		userpwd = (EditText)findViewById(R.id.login_edit_pwd);
		
		if (getIntent().getExtras() != null){
			first = getIntent().getExtras().getBoolean("first");
			userRegist = getIntent().getExtras().getBoolean("userRegist");
		}
		
		if (first) {
			SharedPreferences settings = getSharedPreferences(GgApplication.getInstance().PREFS_NAME, 0);
			username = settings.getString("user_id", "");
			password = settings.getString("user_pwd", "");
			if (!StringUtil.isEmpty(username)){
				userid.setText(username);
				userpwd.setText(password);
				startLogin();
			}
		}
		
		if (userRegist) {
			username = getIntent().getExtras().getString("id");
			password = getIntent().getExtras().getString("pwd");
			if (!StringUtil.isEmpty(username)){
				userid.setText(username);
				userpwd.setText(password);
				startLogin();
			}
		}
		
		btnLogin = (Button)findViewById(R.id.btn_login);
		btnLogin.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View view) {
				startLogin();
			}
		});

		btnRegister = (Button)findViewById(R.id.btn_register);
		btnRegister.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View view) {
				Intent intent = new Intent(LoginActivity.this, UserRegistActivity.class);
				startActivity(intent);
			}
		});
	}
	
	public void startLogin() {
		if (!checkLoginValues())
			return;
		
		if (!NetworkUtil.isNetworkAvailable(LoginActivity.this))
			return;
		
		showProgressDialog(true);
		
		GgApplication.getInstance().setUserPwd(password);
		GgApplication.getInstance().getLoginAgent().login(username, password);
		
//		LoginTask task = new LoginTask();
//		task.execute(username, password);
	}
	
	public void setUserName(String phoneNum) {
		username = phoneNum;
		userid.setText(username);
	}
	
	public void setPassword(String pwd) {
		password = pwd;
		userpwd.setText(password);
	}
	
	public void startHomeActivity() {
		showProgressDialog(false);
		
		SharedPreferences settings = getSharedPreferences(GgApplication.getInstance().PREFS_NAME, 0);
		SharedPreferences.Editor editor = settings.edit();
		editor.putString("user_id", username);
		editor.putString("user_pwd", password);		
		editor.commit();
		
		Intent intent = new Intent(LoginActivity.this, HomeActivity.class);
		intent.putExtra("userRegist", userRegist);
		startActivity(intent);
		finish();
	}
	
	private void showProgressDialog(boolean show) {
		if (show) {
			dlg = new GgProgressDialog(LoginActivity.this, getString(R.string.wait));
			dlg.show();
			return;
		}
		
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
	}
	
	private boolean checkLoginValues() {
//		userid.setText("01");
		username = userid.getText().toString();
		if (StringUtil.isEmpty(username)) {
			userid.requestFocus();
			Toast.makeText(LoginActivity.this, getString(R.string.login_notice_username), Toast.LENGTH_SHORT).show();
			return false;
		}
		
//		userpwd.setText("01");
		password = userpwd.getText().toString();
		if (StringUtil.isEmpty(password)) {
			userpwd.requestFocus();
			Toast.makeText(LoginActivity.this, getString(R.string.login_notice_password), Toast.LENGTH_SHORT).show();
			return false;
		}
	
		return true;
	}
	
	private int[] error_ids = {
		R.string.server_error_connection, 0, R.string.login_error_username, R.string.login_error_password, R.string.login_nonverified, R.string.login_error_aggree 
	};
	
	private void showNotice(int error) {
		Toast.makeText(LoginActivity.this, getString(error_ids[error]), Toast.LENGTH_SHORT).show();
	}
	
	@Override
	public void setUpdate(JSONObject json) {
		super.setUpdate(json);
//		startHomeActivity();
	}
	
	@Override
	public void onStart() {
		super.onStart();
		
		IntentFilter filter = new IntentFilter();
		filter.addAction(GgBroadCast.GOAL_GROUP_BROADCAST);
		registerReceiver(broadCastReceiver, filter);
	}
	
	private BroadcastReceiver broadCastReceiver = new BroadcastReceiver() {

		@Override
		public void onReceive(Context context, Intent intent) {
			int msg = intent.getExtras().getInt("Message");
			if (msg != GgBroadCast.MSG_LOGIN_RESULT)
				return;
			
			showProgressDialog(false);
			
			int error = intent.getExtras().getInt(CommonConsts.LOGIN_ERROR);
			if (error != GgHttpErrors.LOGIN_SUCCESS) {
				showNotice(error);
				return;
			}
			
			startHomeActivity();
		}
	};

	@Override
	public void onPause() {
		//JPushInterface.onPause(getApplicationContext());
		super.onPause();
	}
	@Override
	public void onResume() {
		//JPushInterface.onResume(getApplicationContext());
		super.onResume();
	}
	@Override
	protected void onDestroy() {
		super.onDestroy();
		unregisterReceiver(broadCastReceiver);
	}
}
