package com.goalgroup.offline;

import java.util.Timer;
import java.util.TimerTask;

import android.app.Service;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.OfflineDataHttp;
import com.goalgroup.model.OfflineClubChattingDbAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;

public class GetOfflineService extends Service {
	
	static final int UPDATE_INTERVAL = 60000;
	private GgProgressDialog dlg;

	private final IBinder binder = new MyBinder();
	private Timer timer = new Timer();

	public class MyBinder extends Binder {
		GetOfflineService getService() {
			return GetOfflineService.this;
		}
	}

	
	@Override
	public IBinder onBind(Intent arg0) {
		return null;
	}

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		// We want this service to continue running until it is explicitly
		// stopped, so return sticky.
		
		getofflinedata();
		return START_STICKY;
	}

	private void getofflinedata() {
//		timer.scheduleAtFixedRate(new TimerTask() {
//			public void run() {
//				Log.d("AAAAAAAAAAA", "AAAAAAAAAAAAAAAAA");
//				String param = GgApplication.getInstance().getPrefUtil().getLastChatTime();
//				GetOfflineDataTask go = new GetOfflineDataTask(param);
//				go.execute(LastUpdatedState
//						.getLastUpdatedTime(GetOfflineService.this));
//			}
//		}, 0, UPDATE_INTERVAL);
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		if (timer != null) {
			timer.cancel();
		}
		Log.d("Service Destroyed", "OK");
	}

	private class GetOfflineDataTask extends AsyncTask<String, String, String> {

		private OfflineDataHttp post;
		private String lastUpdatedTime;

		public GetOfflineDataTask(String lastChatTime) {
			this.lastUpdatedTime = lastChatTime;
		}
		
		@Override
		protected void onPreExecute() {
			super.onPreExecute();
		}

		@Override
		protected String doInBackground(String... params) {
			post = new OfflineDataHttp();
			post.setParams(lastUpdatedTime);
			post.run();
			return null;
		}

		@Override
		protected void onPostExecute(String result) {
			super.onPostExecute(result);

			int error = post.getError();
			if (error != GgHttpErrors.GETOFFLINEDATA_SUCCESS) {
				showProgressDialog(false);
				showNotice(error);
				return;
			}
			updateOfflineTable(post);
		}
	}

	private void updateOfflineTable(OfflineDataHttp post) {
		OfflineClubChattingDbAdapter db = new OfflineClubChattingDbAdapter(
				getBaseContext());
		db.open();
		db.updateOfflineTable(post);
		db.close();
	}

	private void showProgressDialog(boolean show) {
		if (show) {
			dlg = new GgProgressDialog(this, getString(R.string.wait));
			dlg.show();
			return;
		}

		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
	}

	private void showNotice(int error) {
		Toast.makeText(this, "Connection error!", Toast.LENGTH_SHORT).show();
	}
}