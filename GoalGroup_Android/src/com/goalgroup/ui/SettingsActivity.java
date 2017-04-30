package com.goalgroup.ui;

import java.util.ArrayList;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import cn.sharesdk.framework.ShareSDK;
import cn.sharesdk.onekeyshare.OnekeyShare;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.info.history.ChatHistoryDB;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.common.GgBroadCast;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.task.SetUserOptionTask;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;

public class SettingsActivity extends Activity implements OnClickListener {
	
	private GgProgressDialog dlg;
	private TextView tvTitle;
	private Button btnBack;
	
	private ImageView switchReqAccept;
	private ImageView switchNewsReq;
	private int option;
	private int option_id;
	private int news_id;
	String[] options;
	private boolean accepRequest = true;
	private boolean newsRequest = true;
	
	private View areaProfile;
	private View areaClear;
	private View areaReport;
	private View areaAbout;
	private View areaShareSNS;
	private View areaLogout;
	
	private ChatHistoryDB historyDB;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_settings);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.individual_settings));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				GgApplication.getInstance().setOption(option);
				finish();
			}
		});
		option = GgApplication.getInstance().getOption();
		options = StringUtil.getOptions(option);
		for (int i = 0; i < options.length; i++) {
			if ("4".equals(options[i])){
				accepRequest = true;
				option_id = i;
			} else if ("8".equals(options[i])) {
				accepRequest = false;
				option_id = i;
			}
			if ("16".equals(options[i])){
				newsRequest = true;
				news_id = i;
			} else if ("32".equals(options[i])) {
				newsRequest = false;
				news_id = i;
			}
		}
		
		switchReqAccept = (ImageView)findViewById(R.id.switch_accept_req);
		switchReqAccept.setOnClickListener(this);
		switchReqAccept.setBackgroundResource(accepRequest ? R.drawable.alarm_on : R.drawable.alarm_off);
		
		switchNewsReq = (ImageView)findViewById(R.id.switch_news_req);
		switchNewsReq.setOnClickListener(this);
		switchNewsReq.setBackgroundResource(newsRequest ? R.drawable.alarm_on : R.drawable.alarm_off);
		
		areaProfile = findViewById(R.id.area_edit_profile);
		areaProfile.setOnClickListener(this);
		areaClear = findViewById(R.id.area_clear_data);
		areaClear.setOnClickListener(this);
		areaShareSNS = findViewById(R.id.area_share_sns);
		areaShareSNS.setOnClickListener(this);
		areaReport = findViewById(R.id.area_report_opinion);
		areaReport.setOnClickListener(this);
		areaAbout = findViewById(R.id.area_about_app);
		areaAbout.setOnClickListener(this);
		areaLogout = findViewById(R.id.area_log_out);
		areaLogout.setOnClickListener(this);
		
		historyDB = GgApplication.getInstance().getChatInfo().getChatHistDB();
	}
	
	@Override
	public void onPause() {
		super.onPause();
		GgApplication.getInstance().setOption(option);
		//finish();
	}
	
	private void showShare() {
		 ShareSDK.initSDK(this);
		 OnekeyShare oks = new OnekeyShare();
		 //关闭sso授权
		 oks.disableSSOWhenAuthorize(); 

		// 分享时Notification的图标和文字  2.5.9以后的版本不调用此方法
		 //oks.setNotification(R.drawable.ic_launcher, getString(R.string.app_name));
		 // title标题，印象笔记、邮箱、信息、微信、人人网和QQ空间使用
		 oks.setTitle(getString(R.string.share));
		 // titleUrl是标题的网络链接，仅在人人网和QQ空间使用
		 oks.setTitleUrl("http://sharesdk.cn");
		 // text是分享文本，所有平台都需要这个字段
		 oks.setText("足球的城是为了所有足球迷的软件。在这软件您可以创建俱乐部， 跟朋友们一起踢足球。");
		 // imagePath是图片的本地路径，Linked-In以外的平台都支持此参数
		 oks.setImagePath("/sdcard/test.jpg");//确保SDcard下面存在此张图片
		 // url仅在微信（包括好友和朋友圈）中使用
		 oks.setUrl("http://sharesdk.cn");
		 // comment是我对这条分享的评论，仅在人人网和QQ空间使用
		 oks.setComment("创建俱乐部， 可以随便约会踢足球是 非常好的功能。也可以随便跟朋友们讨论关于比赛。");
		 // site是分享此内容的网站名称，仅在QQ空间使用
		 oks.setSite(getString(R.string.app_name));
		 // siteUrl是分享此内容的网站地址，仅在QQ空间使用
		 oks.setSiteUrl("http://sharesdk.cn");

		// 启动分享GUI
		 oks.show(this);
		 }
	@Override
	public void onClick(View view) {
		Intent intent;
		AlertDialog dialog;
		switch (view.getId()) {
		case R.id.area_share_sns:
			showShare();
			break;
		case R.id.switch_accept_req:
			accepRequest = !accepRequest;
			switchReqAccept.setBackgroundResource(accepRequest ? R.drawable.alarm_on : R.drawable.alarm_off);
			options[option_id] = accepRequest ? "4" : "8";
			option = StringUtil.getOption(options);
			startSetUserOption(true);
			break;
		case R.id.switch_news_req:
			newsRequest = !newsRequest;
			switchNewsReq.setBackgroundResource(newsRequest ? R.drawable.alarm_on : R.drawable.alarm_off);
			options[news_id] = newsRequest ? "16" : "32";
			option = StringUtil.getOption(options);
			startSetUserOption(true);
			break;
		case R.id.area_edit_profile:
			intent = new Intent(SettingsActivity.this, ProfileActivity.class);
			intent.putExtra("user_id", Integer.valueOf(GgApplication.getInstance().getUserId()));
			intent.putExtra("type", CommonConsts.EDIT_PROFILE);
			startActivity(intent);
			break;
		case R.id.area_clear_data:
			dialog = new AlertDialog.Builder(SettingsActivity.this)
			.setTitle(R.string.clear_datas)
			.setMessage(R.string.clear_datas)
			.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					ArrayList<ChatRoomInfo> rooms = new ArrayList<ChatRoomInfo>(GgApplication.getInstance().getChatInfo().getChatRooms());
					boolean mClean = false;
					for (ChatRoomInfo room : rooms) {
						try {
							int curRoomId = room.getRoomId();
							historyDB.removeMsgs();
							if (room.getRoomType() == 1)
								GgApplication.getInstance().getChatInfo().removeChatDiscussRoom(room.getRoomId());
							mClean = true;
						} catch(Exception ex) {
							ex.printStackTrace();
							mClean = false;
						}
					}
					
					if (mClean)
						Toast.makeText(SettingsActivity.this, getString(R.string.chat_clear_history_success), Toast.LENGTH_SHORT).show();
					else
						Toast.makeText(SettingsActivity.this, getString(R.string.chat_clear_history_failed), Toast.LENGTH_SHORT).show();
				}
			})
			.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {					
				}
			}).create();
			
			dialog.show();
			break;
		case R.id.area_report_opinion:
			intent = new Intent(SettingsActivity.this, ReportActivity.class);
			intent.putExtra("type", CommonConsts.OPINION_TYPE);
			startActivity(intent);
			break;
		case R.id.area_about_app:
			intent = new Intent(SettingsActivity.this, AboutActivity.class);
			startActivity(intent);
			break;
		case R.id.area_log_out:
			dialog = new AlertDialog.Builder(SettingsActivity.this)
			.setTitle(R.string.logout)
			.setMessage(R.string.logout_verify)
			.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					startLogOut();
				}
			})
			.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {					
				}
			}).create();
			
			dialog.show();
			break;
		}		
	}

	public void startLogOut() {
		GgApplication.getInstance().getChatEngine().hideNotification();  
		GgApplication.getInstance().getLoginAgent().logout(CommonConsts.LOGOUT_REASON_USER);
	}
	
	public void stopLogOut() {
		HomeActivity homeActivity = ((GgApplication)getApplication()).homeActivity;
		homeActivity.loaderHandler.removeCallbacks(homeActivity.runtimeDetailLoader);
		
		GgApplication.getInstance().getChatInfo().closeDBs();
		
		Intent logoutIntent = new Intent(SettingsActivity.this, LoginActivity.class);
		logoutIntent.putExtra("first", false);
		logoutIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		startActivity(logoutIntent);
		SharedPreferences settings = getSharedPreferences(GgApplication.getInstance().PREFS_NAME, 0);
		
		SharedPreferences.Editor editor = settings.edit();
		editor.clear();
		editor.commit();
		
		finish();
		homeActivity.finish();
	}
	
	public void startSetUserOption(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(SettingsActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(SettingsActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		SetUserOptionTask task = new SetUserOptionTask(SettingsActivity.this, option);
		task.execute();
	}
	
	public void stopSetUserOption(int result) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (result == 1)
			Toast.makeText(SettingsActivity.this, getString(R.string.setting_succeed), Toast.LENGTH_SHORT).show();
		else
			Toast.makeText(SettingsActivity.this, getString(R.string.setting_failed), Toast.LENGTH_SHORT).show();
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
			if (msg != GgBroadCast.MSG_LOGOUT_RESULT)
				return;
			
			int reason = intent.getExtras().getInt(CommonConsts.LOGOUT_REASON);
			if (reason != CommonConsts.LOGOUT_REASON_USER)
				return;
			
			stopLogOut();
		}
	};
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		unregisterReceiver(broadCastReceiver);
		
	}
}
