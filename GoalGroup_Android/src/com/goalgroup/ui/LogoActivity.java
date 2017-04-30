package com.goalgroup.ui;

import com.goalgroup.R;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Window;

import cn.jpush.android.api.JPushInterface;

public class LogoActivity extends Activity implements Runnable{

	Thread thread = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_logo);
	}
	
	@Override
	protected void onStart() {
		// TODO Auto-generated method stub
		super.onStart();
		
		thread = new Thread(this);
		thread.start();
	}
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
	public void run() {
		// TODO Auto-generated method stub
		try {
			thread.sleep(1500);
		} catch (Exception e) {
			// TODO: handle exception
		}
		
		Intent intent = new Intent(LogoActivity.this, LoginActivity.class);
		startActivity(intent);
		overridePendingTransition(R.anim.slide_out_left, R.anim.slide_in_right);
		finish();
	}
	
	
	
}
