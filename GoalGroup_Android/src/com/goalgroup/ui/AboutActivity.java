package com.goalgroup.ui;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.R;
import com.goalgroup.task.GetVersionTask;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.StringUtil;

import cn.jpush.android.api.JPushInterface;

public class AboutActivity extends Activity {
	
	private final String UPDATE_SERVERAPK = "GoalGroup.apk";
	
	private TextView tvTitle;
	private Button btnBack;	
	private Button btnUpdate;
	private TextView tvVersion;
	
	private GgProgressDialog dlg;
	
	private String curVersion;
	private String updateVer;
	private String updateUrl;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_about);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.about_goalgroup_app));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		try {
			curVersion = getPackageManager().getPackageInfo("com.goalgroup", 0).versionName;
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}
		
		tvVersion = (TextView)findViewById(R.id.version);
		tvVersion.setText(String.format("Ver %s", curVersion));
		
		btnUpdate = (Button)findViewById(R.id.update_app);
		btnUpdate.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View view) {
				startCheckVersion();
			}
		});
		JPushInterface.resumePush(getApplicationContext());
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
	
	public void startCheckVersion() {		
		updateVer = updateUrl = "";
		
		showProgDialog(true);
		
		GetVersionTask task = new GetVersionTask(this, curVersion);
		task.execute();
	}
	
	public void stopCheckVersion(boolean state) {
		showProgDialog(false);
		
		if (!state || StringUtil.isEmpty(updateVer)) {
			Toast.makeText(AboutActivity.this, getString(R.string.about_fail_check_version), Toast.LENGTH_SHORT).show();
			return;
		}
		
		if (StringUtil.isEmpty(curVersion) || updateVer.equals(curVersion)) {
			Toast.makeText(AboutActivity.this, getString(R.string.about_already_latest), Toast.LENGTH_SHORT).show();
			return;
		}
		
		String verMsg = String.format(getString(R.string.about_msg_new_ver), curVersion, updateVer);
		
		AlertDialog dialog = new AlertDialog.Builder(AboutActivity.this)
		.setTitle(R.string.about_confirm_update)
		.setMessage(verMsg)
		.setCancelable(false)
		.setPositiveButton(R.string.ok, 
		new DialogInterface.OnClickListener() {
		
			@Override
			public void onClick(DialogInterface dialog, int which) {
				showProgDialog(true);
				downFile(updateUrl);
			}
		})
		.setNegativeButton(R.string.cancel, 
		new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		}).create();
		
		dialog.show();
		return;
	}
	
	public void setUpdateInfo(String ver, String url) {
		this.updateVer = ver;
		this.updateUrl = url;
	}
	
	private void showProgDialog(boolean view) {
		if (view) {
			dlg = new GgProgressDialog(AboutActivity.this, getString(R.string.wait));
			dlg.show();
			return;
		}
		
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
	}
	
	/**
	 * 下载apk
	 */
	private void downFile(final String url) {
		new Thread(){
			public void run(){
				HttpClient client = new DefaultHttpClient();
				HttpGet get = new HttpGet(url);
				HttpResponse response;
				try {
					response = client.execute(get);
					HttpEntity entity = response.getEntity();
					
					InputStream is =  entity.getContent();
					FileOutputStream fileOutputStream = null;
					if(is != null){
						File file = new File(Environment.getExternalStorageDirectory(), UPDATE_SERVERAPK);
						if (file.exists())
							file.delete();
						
						fileOutputStream = new FileOutputStream(file);
						byte[] b = new byte[1024*16];
						int readbytes;
						
						while((readbytes = is.read(b))!=-1){
							fileOutputStream.write(b, 0, readbytes);
						}
					}
					
					fileOutputStream.flush();
					if(fileOutputStream!=null){
						fileOutputStream.close();
					}
					
					down();
				}  catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					downfail();
				}
			}
		}.start();
	}
	
	Handler handler = new Handler() {

		@Override
		public void handleMessage(Message msg) {

			super.handleMessage(msg);				
			showProgDialog(false);
			update();
		}
	};
	
	/**
	 * 下载完成，通过handler将下载对话框取消
	 */
	public void down(){
		new Thread(){
			public void run(){
				Message message = handler.obtainMessage();
				handler.sendMessage(message);
			}
		}.start();
	}
	
	public void downfail(){
		new Thread(){
			public void run(){
				Message message = handler.obtainMessage();
				handler.sendMessage(message);
			}
		}.start();
	}
	
	/**
	 * 安装应用
	 */
	public void update(){
		Intent intent = new Intent();
		intent.setAction(Intent.ACTION_VIEW);
		File apkFile = new File(Environment.getExternalStorageDirectory(), UPDATE_SERVERAPK);
		intent.setDataAndType(Uri.fromFile(apkFile), "application/vnd.android.package-archive");
		startActivity(intent);
		
//		apkFile.delete();
		finish();
	}

}
