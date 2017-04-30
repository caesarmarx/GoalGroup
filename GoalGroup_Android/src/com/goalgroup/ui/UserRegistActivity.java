package com.goalgroup.ui;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.R;
import com.goalgroup.task.UserRegisterTask;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;

public class UserRegistActivity extends Activity implements OnClickListener {
	
	private LinearLayout total_area;
	private LinearLayout sub_total_area;
	private TextView tvTitle;
	private Button btnBack;
	private EditText etUserName;
	private EditText etPhoneNumber;
	private EditText etPassword;
	private EditText etPasswordConfirm;
	private Button btnRegister;
	
	private String strUserName;
	private String strPhoneNumber;
	private String strPassword;
	private String strPasswordConfirm;
	private boolean bCheckInput;
	private InputMethodManager ipm;
	
	private GgProgressDialog dlg;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_user_regist);
		
		total_area = (LinearLayout) findViewById(R.id.regist_total_area);
		sub_total_area = (LinearLayout) findViewById(R.id.regist_layer);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.register));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				InputMethodManager ipm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
				ipm.hideSoftInputFromWindow(etUserName.getWindowToken(), 0);
				finish();
			}
		});
		
		etUserName = (EditText)findViewById(R.id.user_name);
		etPhoneNumber = (EditText)findViewById(R.id.phone_number);
		etPassword = (EditText)findViewById(R.id.password_01);
		etPasswordConfirm = (EditText)findViewById(R.id.password_02);
		btnRegister = (Button)findViewById(R.id.regist);
		
		btnRegister.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				InputMethodManager ipm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
				ipm.hideSoftInputFromWindow(etUserName.getWindowToken(), 0);
				
				strUserName = etUserName.getText().toString();
				strPhoneNumber = etPhoneNumber.getText().toString();
				strPassword = etPassword.getText().toString();
				strPasswordConfirm = etPasswordConfirm.getText().toString();
				bCheckInput = checkInputValue();
				
				if(bCheckInput) {
					startSendRegister(true);
				}
				
			}
		});
		
		total_area.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				// TODO Auto-generated method stub
				InputMethodManager ipm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
				ipm.hideSoftInputFromWindow(etUserName.getWindowToken(), 0);
				return true;
			}
		});
		
		sub_total_area.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				// TODO Auto-generated method stub
				InputMethodManager ipm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
				ipm.hideSoftInputFromWindow(etUserName.getWindowToken(), 0);
				return true;
			}
		});
		
		/*Timer timer = new Timer();
		timer.schedule(new TimerTask() {
			@Override
			public void run() {
				ipm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
				ipm.hideSoftInputFromWindow(
						etUserName.getWindowToken(), 0);
			}
		}, 100);*/
	}
	
	public boolean checkInputValue() {
		
		if(strUserName.isEmpty()) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.register_notice_username), Toast.LENGTH_SHORT).show();
			etUserName.setText("");
			etUserName.requestFocus();
			Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
	        etUserName.startAnimation(shake);
			return false;
		} else if (strUserName.length() > 10) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.register_input_length_invalid), Toast.LENGTH_LONG).show();
			etUserName.setText("");
			etUserName.requestFocus();
			Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
	        etUserName.startAnimation(shake);
			return false;
		} else if (containsSpecChar(strUserName)) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.alias) + getString(R.string.register_input_invalid), Toast.LENGTH_LONG).show();
			etUserName.setText("");
			etUserName.requestFocus();
			Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
	        etUserName.startAnimation(shake);
			return false;
		} else if (strPhoneNumber.isEmpty()) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.register_notice_phonenumber), Toast.LENGTH_SHORT).show();
			etPhoneNumber.setText("");
			etPhoneNumber.requestFocus();
			Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
			etPhoneNumber.startAnimation(shake);
			return false;
		} else if (!isMobileNO(strPhoneNumber)) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.register_handphone_invalid), Toast.LENGTH_SHORT).show();
			etPhoneNumber.setText("");
			etPhoneNumber.requestFocus();
			Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
			etPhoneNumber.startAnimation(shake);
			return false;
		} else if (strPassword.isEmpty()) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.register_notice_password), Toast.LENGTH_SHORT).show();
			etPassword.setText("");
			etPassword.requestFocus();
			Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
			etPassword.startAnimation(shake);
			return false;
		} else if (containsSpecChar(strPassword)) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.password) + getString(R.string.register_input_invalid), Toast.LENGTH_LONG).show();
			etPassword.setText("");
			etPassword.requestFocus();
			Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
			etPassword.startAnimation(shake);
			return false;
		} else if (strPassword.length() > 10) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.register_pwd_length_invalid), Toast.LENGTH_LONG).show();
			etPassword.setText("");
			etPasswordConfirm.setText("");
			etPassword.requestFocus();
			Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
			etPassword.startAnimation(shake);
			return false;
		} else if (strPasswordConfirm.isEmpty()) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.register_notice_password_confirm), Toast.LENGTH_SHORT).show();
			etPasswordConfirm.setText("");
			etPasswordConfirm.requestFocus();
			Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
			etPasswordConfirm.startAnimation(shake);
			return false;
		} else if (!strPassword.toString().equals(strPasswordConfirm.toString())) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.register_notice_password_diff), Toast.LENGTH_LONG).show();
			etPassword.setText("");
			etPasswordConfirm.setText("");
			etPassword.requestFocus();
			Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
			etPassword.startAnimation(shake);
			return false;
		}    
		
//		String strTmp = "";
		/*for (int i = 0; i < strPhoneNumber.length(); i++) {
			strTmp = strPhoneNumber.substring(i, i + 1);
			try {
				Integer.parseInt(strTmp);
			} catch (NumberFormatException e) {
				// TODO: handle exception
				Toast.makeText(UserRegistActivity.this, getString(R.string.phone_number) + getString(R.string.register_input_invalid), Toast.LENGTH_SHORT).show();
				etPhoneNumber.setText("");
				etPhoneNumber.requestFocus();
				Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
				etPhoneNumber.startAnimation(shake);
				return false;
			}
		}*/
		
		/* special character discover
		 * 
		 */
		/*char chrTmp = '0';
		
		for (int i = 0; i < strUserName.length(); i++) {
			chrTmp = strUserName.charAt(i);
			if (chrTmp > 0x20 && chrTmp < 0x30 || chrTmp > 0x39 && chrTmp < 0x41 || chrTmp > 0x5A && chrTmp < 0x61 || chrTmp > 0x7A) {
				Toast.makeText(UserRegistActivity.this, getString(R.string.alias) + getString(R.string.register_input_invalid), Toast.LENGTH_SHORT).show();
				etUserName.setText("");
				etUserName.requestFocus();
				Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
				etUserName.startAnimation(shake);
				return false;
			}
		}
		
		for (int i = 0; i < strPassword.length(); i++) {
			chrTmp = strPassword.charAt(i);
			if (chrTmp > 0x20 && chrTmp < 0x30 || chrTmp > 0x39 && chrTmp < 0x41 || chrTmp > 0x5A && chrTmp < 0x61 || chrTmp > 0x7A) {
				Toast.makeText(UserRegistActivity.this, getString(R.string.password) + getString(R.string.register_input_invalid), Toast.LENGTH_SHORT).show();
				etPassword.setText("");
				etPasswordConfirm.setText("");
				etPassword.requestFocus();
				Animation shake = AnimationUtils.loadAnimation(this, R.anim.shake);
				etPassword.startAnimation(shake);
				return false;
			}
		}*/
		return true;
	}
	
	public void startSendRegister(boolean showDlg) {
		if (!NetworkUtil.isNetworkAvailable(UserRegistActivity.this))
			return;
		
		if (showDlg) {
			dlg = new GgProgressDialog(UserRegistActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		Object[] objRegisterInfo = new Object[4];
		objRegisterInfo[0] = strPhoneNumber;
		objRegisterInfo[1] = strUserName;
		objRegisterInfo[2] = strPassword;
		objRegisterInfo[3] = "";
		UserRegisterTask task = new UserRegisterTask(this, objRegisterInfo);
		task.execute();
	}
	
	public void stopUserRegister(String result) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (result.equals("1")) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.user_register_success), Toast.LENGTH_SHORT).show();
			Intent intent = new Intent(UserRegistActivity.this, LoginActivity.class);
			intent.putExtra("first", false);
			intent.putExtra("userRegist", true);
			intent.putExtra("id", strPhoneNumber);
			intent.putExtra("pwd", strPassword);
			startActivity(intent);
			finish();
			return;
		} else if (result.equals("0")) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.user_register_failed), Toast.LENGTH_SHORT).show();
		} else if (result.equals("2")) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.register_handphone_duplicated), Toast.LENGTH_SHORT).show();
		} else if (result.equals("3")) {
			Toast.makeText(UserRegistActivity.this, getString(R.string.register_username_duplicated), Toast.LENGTH_SHORT).show();
		} else if (StringUtil.isEmpty(result))
			Toast.makeText(UserRegistActivity.this, getString(R.string.server_error_connection), Toast.LENGTH_SHORT).show();
			
	}
	
	/*public boolean isMobileNO_1(String mobileNo) {
		String telRegex = "[1][358]\\d{9}";  
	    if (TextUtils.isEmpty(mobileNo)) return false;  
	    else return mobileNo.matches(telRegex);  
	}*/
	
	public boolean isMobileNO(String mobileNo) {
		Pattern p = Pattern.compile("^((13[0-9])|(15[^4,\\D])|(18[0,3,5-9]))\\d{8}$");
		Matcher m = p.matcher(mobileNo);
		return m.matches();
	}
	
	public boolean containsSpecChar(String username) {
		String regEx="[`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？\t\f\n\r[[:space:]]]"; 
        Pattern p = Pattern.compile(regEx); 
        Matcher m = p.matcher(username);
        
        return m.find();
        
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		
	}
}
