package com.goalgroup;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Date;

import android.R.bool;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Application;
import android.app.NotificationManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;

import cn.jpush.android.api.JPushInterface;

import com.goalgroup.chat.component.ChatEngine;
import com.goalgroup.chat.info.GgChatInfo;
import com.goalgroup.common.GgBroadCast;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.login.GgLoginAgent;
import com.goalgroup.ui.HomeActivity;
import com.goalgroup.utils.FileUtil;
import com.goalgroup.utils.PrefUtil;
import com.goalgroup.utils.ServerTimeUtil;
import com.goalgroup.utils.StorageUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;

import java.lang.Thread.UncaughtExceptionHandler;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;

public class GgApplication extends Application {
	
	private static GgApplication instance;
	
	public static final String PREFS_NAME = "MyPrefsFile";
	
	public static DisplayImageOptions img_opt_photo;
	public static DisplayImageOptions img_opt_captain;
	public static DisplayImageOptions img_opt_club_mark;
	public static DisplayImageOptions img_opt_pic;
	public static DisplayImageOptions img_opt_bbs;
	
	
	public static final int PICK_FROM_CAMERA = 0;
	public static final int PICK_FROM_ALBUM = 1;
	public static final int CROP_FROM_CAMERA = 2;
	
	public static boolean test = true;
	
	private PrefUtil pref;
	private GgChatInfo chatInfo;
	private Uri mImageCaptureUri;
	private Activity photoParent;
	public HomeActivity homeActivity;
	
	private ChatEngine chatEngine;
	private GgLoginAgent loginAgent;

	private UncaughtExceptionHandler mUncaughtExceptionHandler;
	
	@Override
	public void onCreate() {
		super.onCreate();
		instance = this;
		mUncaughtExceptionHandler = Thread.getDefaultUncaughtExceptionHandler();

		Thread.setDefaultUncaughtExceptionHandler(new UncaughtExceptionHandlerApplication());
		
		File rootdir = new File(FileUtil.getFullPath(""));	//"com.pgi.omtelephone" : PackageName	
		rootdir.mkdir();
		
		chatEngine = new ChatEngine(instance);
		chatEngine.setNotificationManager((NotificationManager)getSystemService(NOTIFICATION_SERVICE));
		
		pref = new PrefUtil();
		chatInfo = new GgChatInfo();
		JPushInterface.setDebugMode(false);
	    JPushInterface.init(this);
		initImageLoader();
		initBroadCaster();
		
		servTimeUtil = new ServerTimeUtil();
		loginAgent = new GgLoginAgent(this);
	}
	private String getStackTrace(Throwable th) {


		final Writer result = new StringWriter();

		final PrintWriter printWriter = new PrintWriter(result);


		Throwable cause = th;

		while (cause != null) {

			cause.printStackTrace(printWriter);

			cause = cause.getCause();

		}

		final String stacktraceAsString = result.toString();

		printWriter.close();


		return stacktraceAsString;

	}
	class UncaughtExceptionHandlerApplication implements Thread.UncaughtExceptionHandler{


		@Override

		public void uncaughtException(Thread thread, Throwable ex) {


			//????? ?? ?? ?? ??

			Log.e("Error", getStackTrace(ex));


			//????? ?? ?? DefaultUncaughtException?? ???.

			mUncaughtExceptionHandler.uncaughtException(thread, ex);

		}


	}


	@Override
	public void onTerminate() {
		super.onTerminate();
		Log.d("onTerminate", "unknown");
		//JPushInterface.stopPush(getApplicationContext());
	}

	@Override
	public void onLowMemory() {
		super.onLowMemory();
		//JPushInterface.stopPush(getApplicationContext());
		Log.d("onLowMemory", "unknown");
	}

	@Override
	public void onTrimMemory(int level) {
		super.onTrimMemory(level);
		//if (level < 20)
		//	JPushInterface.stopPush(getApplicationContext());
		Log.d("onTrimMemory", Integer.toString(level));
	}

	public static GgApplication getInstance() {
		return instance;
	}
	
	public String getRealPathFromURI(Context context, Uri contentUri) {
		Cursor cursor = null;
		try { 
			String[] proj = { MediaStore.Images.Media.DATA };
			cursor = context.getContentResolver().query(contentUri,  proj, null, null, null);
			int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
			cursor.moveToFirst();
			return cursor.getString(column_index);
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}
	}
	
	public boolean copyFile(File srcFile, File destFile) {
		boolean result = false;
		try {
			InputStream in = new FileInputStream(srcFile);
			try {
				result = copyToFile(in, destFile);
			} finally {
				in.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
			result = false;
		}
		
		return result;
	}
	
	private boolean copyToFile(InputStream inputStream, File destFile) {
		try {
			OutputStream out = new FileOutputStream(destFile);
			try {
				byte[] buffer = new byte[4096];
				int bytesRead;
				while ((bytesRead = inputStream.read(buffer)) >= 0) {
					out.write(buffer, 0, bytesRead);
				}
			} finally {
				out.close();
			}
			
			return true;
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	private void doTakePhotoAction() {
		if (!StorageUtil.isMountedStorage(photoParent))
			return;
		
		Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
		
		long now = System.currentTimeMillis();
		Date curDate = new Date(now);
	
		String url = "pic_" + String.format("_%04d%02d%02d_%02d%02d%02d_", curDate.getYear() + 1900, curDate.getMonth() + 1, curDate.getDate(), 
				curDate.getHours(), curDate.getMinutes(), curDate.getSeconds()) + ".jpg";
		File f = new File(Environment.getExternalStorageDirectory() + "/picture");
		if (!f.exists() || !f.isDirectory()) {
			f.mkdir();
		}
		mImageCaptureUri = Uri.fromFile(new File(Environment.getExternalStorageDirectory() + "/picture", url));
		
		intent.putExtra(android.provider.MediaStore.EXTRA_OUTPUT, mImageCaptureUri);
		//intent.putExtra("return-data", true);
		photoParent.startActivityForResult(intent, PICK_FROM_CAMERA);
	}
	
	private void doTakeAlbumAction() {
		Intent intent = new Intent(Intent.ACTION_PICK);
		intent.setType(android.provider.MediaStore.Images.Media.CONTENT_TYPE);
		photoParent.startActivityForResult(intent, PICK_FROM_ALBUM);
	}
	
	public Uri getImageUri() {
		return mImageCaptureUri;
	}
	
	public void setImageUri(Uri imagePath) {
		mImageCaptureUri = imagePath;
	}
	
	public void addPhoto(Activity parentActivity) {
		
		photoParent = parentActivity;
		
		DialogInterface.OnClickListener cameraListener = new DialogInterface.OnClickListener() {					
			@Override
			public void onClick(DialogInterface dialog, int which) {
				doTakePhotoAction();
			}
		};
		
		DialogInterface.OnClickListener albumListener = new DialogInterface.OnClickListener() {					
			@Override
			public void onClick(DialogInterface dialog, int which) {
				doTakeAlbumAction();
			}
		};
		
		DialogInterface.OnClickListener cancelListener = new DialogInterface.OnClickListener() {					
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		};
		
		new AlertDialog.Builder(photoParent)
			.setTitle(getString(R.string.home_picture_dlg_title))
			.setMessage(getString(R.string.home_picture_dlg_msg))
			.setPositiveButton(getString(R.string.home_picture_camera), cameraListener)
			.setNeutralButton(getString(R.string.home_picture_album), albumListener)
			.setNegativeButton(getString(R.string.cancel), cancelListener)
			.show();
	}
	
	private ImageLoader imageLoader;
	
	private void initImageLoader() {
		imageLoader = ImageLoader.getInstance();
		imageLoader.init(ImageLoaderConfiguration.createDefault(instance));
		
		img_opt_captain = new DisplayImageOptions.Builder()
		.showStubImage(R.drawable.photo_default)
		.showImageForEmptyUri(R.drawable.photo_default)
		.showImageOnFail(R.drawable.photo_default)
		.cacheInMemory(true)
		.cacheOnDisk(true)
		.bitmapConfig(Bitmap.Config.RGB_565)
		.build();
		
		img_opt_photo = new DisplayImageOptions.Builder()
			.showStubImage(R.drawable.photo_default)
			.showImageForEmptyUri(R.drawable.photo_empty)
			.showImageOnFail(R.drawable.photo_empty)
			.cacheInMemory(true)
			.cacheOnDisk(true)
			.bitmapConfig(Bitmap.Config.RGB_565)
			.build();
		
		img_opt_club_mark = new DisplayImageOptions.Builder()
			.showStubImage(R.drawable.club_empty)
			.showImageForEmptyUri(R.drawable.club_empty)
			.showImageOnFail(R.drawable.club_empty)
			.cacheInMemory(true)
			.cacheOnDisk(true)
			.bitmapConfig(Bitmap.Config.RGB_565)
			.build();
		
		img_opt_pic = new DisplayImageOptions.Builder()
			.showStubImage(R.drawable.image_none)
			.showImageForEmptyUri(R.drawable.image_none)
			.showImageOnFail(R.drawable.image_none)
			.cacheInMemory(true)
			.cacheOnDisk(true)
			.bitmapConfig(Bitmap.Config.RGB_565)
			.build();
		
		img_opt_bbs = new DisplayImageOptions.Builder()
		.showStubImage(R.drawable.bbs_picture_sample)
		.showImageForEmptyUri(R.drawable.bbs_picture_sample)
		.showImageOnFail(R.drawable.bbs_picture_sample)
		.cacheInMemory(true)
		.cacheOnDisk(true)
		.bitmapConfig(Bitmap.Config.RGB_565)
		.build();
	}
	
	public ImageLoader getImageLoader() {
		return imageLoader;
	}
	
	private String user_id;
	private String user_pwd;
	private String user_name;
	private String user_photo;
	private int playing_city;
	
	public void setUserId(String value) {
		user_id = value;
	}
	
	public void setUserPwd(String value) {
		user_pwd = value;
	}
	
	public void setUserName(String value) {
		user_name = value;
	}
	
	public void setUserPhoto(String value) {
		this.user_photo = value;
	}
	
	public void setPlayingCity(int  value) {
		this.playing_city = value;
	}
	
	public String getUserId() {
		return user_id;
	}
	
	public String getUserPwd() {
		return user_pwd;
	}
	
	public String getUserName() {
		return user_name;
	}
	
	public String getUserPhoto() {
		return user_photo;
	}
	
	public int getPlayingCity() {
		return playing_city;
	}
	
	private int option;
	private String[] club_id;
	private String[] club_name;
	private int[] post;
	private String[] stadium_id;
	private String[] stadium_name;
	private String[] city_id;
	private String[] city_name;
	private String[] district_id;
	private String[] district_city_id;
	private String[] district_name;
	private String[] all_club_id;
	private String[] all_club_name;
	private boolean chall_flag = true;
	private int inv_count;
	private int temp_inv_count;
	
	private String strSystemCurTime;
	private String[] mMyClubID;
	
	public void setOption(int value){
		option = value;
	}
	
	public int getOption() {
		return option;
	}
	
	public void setCityInfo(String[] cityID, String[] cityName) {
		city_id = cityID;
		city_name = cityName;
	}
	
	public String[] getCityID() {
		return city_id;
	}
	
	public String[] getCityName() {
		return city_name;
	}
	
	public void setDistrictInfo(String[] districtID, String[] cityID, String[] districtName) {
		district_id = districtID;
		district_city_id = cityID;
		district_name = districtName;
	}
	
	public String[] getDistrictID() {
		return district_id;
	}
	
	public String[] getDistrictCityID() {
		return district_city_id;
	}
	
	public String[] getDistrictName() {
		return district_name;
	}
	
	public void setChallFlag(boolean bChall) {
		chall_flag = bChall;
	}
	
	public boolean getChallFlag() {
		return chall_flag;
	}
	
	public void setClubInfo(String[] strId, String[] strName, int[] userPost, int type) {
		if (type == CommonConsts.MY_CLUB) {
			club_id = new String[strId.length];
			club_id = strId;
			club_name = new String[strName.length];
			club_name = strName;
			post = new int[userPost.length];
			post = userPost;
		} else {
			all_club_id = strId;
			all_club_name = strName;
		}
	}
	
	public int[] getPost() {
		return post;
	}
	
	public void changeClubPost(String id) {
		for (int i = 0; i < club_id.length; i ++) {
			if (!id.equals(club_id[i]))
				continue;
			
			post[i] = 8;
		}
	}
	
	public String[] getClubId() {
		return club_id;
	}
	
	public String[] getClubName() {
		return club_name;
	}
	
	public String[] getAllClubId() {
		return all_club_id;
	}
	
	public String[] getAllClubName() {
		return all_club_name;
	}
	
	public void popClubID(String clubID) {
		String[] new_club_id = new String[club_id.length];
		String[] new_club_name = new String[club_name.length];
		int[] new_club_post = new int[post.length];
		
		int count = 0;
		for (int i = 0; i < club_id.length; i++)
			if (!clubID.equals(club_id[i])){
				new_club_id[count] = club_id[i];
				new_club_name[count] = club_name[i];
				new_club_post[count] = post[i];
				count++;
			}
		
		club_id = new String[count];
		club_name = new String[count];
		post = new int[count];
		for (int i = 0; i < count; i ++){
			club_id[i] = new_club_id[i];
			club_name[i] = new_club_name[i];
			post[i] = new_club_post[i];
		}
	}
	
	public void addClubInfo(String id, String name, int post) {
		int count = getClubId().length;
		String nClub_ID[] = new String[count+1];
		String nClub_Name[] = new String[count+1];
		int nClub_Post[] = new int[count+1];
		
		for (int i = 0; i < count; i++) {
			nClub_ID[i] = getClubId()[i];
			nClub_Name[i] = getClubName()[i];
			nClub_Post[i] = getPost()[i];
		}
		
		nClub_ID[count] = id;
		nClub_Name[count] = name;
		nClub_Post[count] = post;
		
		setClubInfo(nClub_ID, nClub_Name, nClub_Post, CommonConsts.MY_CLUB);
		
	}
	
	public void setStadiumInfo(String[] strId, String[] strName) {
		stadium_id = strId;
		stadium_name = strName;
	}
	
	public String[] getStadiumId() {
		return stadium_id;
	}
	
	public String[] getStadiumName() {
		return stadium_name;
	}
	
	public String getIDFromName(String name, int type) {
		String[] arrName = new String[0];
		String[] arrID = new String[0];
		switch(type) {
		case CommonConsts.CITY:
			arrName = city_name;
			arrID = city_id;
			break;
		case CommonConsts.DISTRICT:
			arrName = district_name;
			arrID = district_id;
			break;
		case CommonConsts.STADIUM:
			arrName = stadium_name;
			arrID = stadium_id;
		}
		
		for (int i = 0; i < arrName.length; i++)
			if (name.equals(arrName[i]))
				return arrID[i];
		return "0";
	}
	
	public int getDistLengthfromCityID(String cityID){
		String[] distCityID = GgApplication.getInstance().getDistrictCityID();
		int count = 0;
		for ( int i = 0; i < distCityID.length; i++) {
			if (Integer.valueOf(cityID) == Integer.valueOf(distCityID[i]))
				count ++;
		}
		return count;
	}
	
	public String[][] getDistfromCity(String strCityID) {
    	int count = getDistLengthfromCityID(strCityID);
    	String[][] sub_distInfo = new String[3][count];
		count = 0;
		for (int i = 0; i < district_id.length; i++) {
			if (Integer.valueOf(district_city_id[i]) == Integer.valueOf(strCityID)){
				sub_distInfo[0][count] = district_id[i];
				sub_distInfo[1][count] = district_city_id[i];
				sub_distInfo[2][count] = district_name[i];
				count++;
			}
		}
		return sub_distInfo;
    }
	
	public PrefUtil getPrefUtil() {
		return pref;
	}
	
	public GgChatInfo getChatInfo() {
		return chatInfo;
	}
	
	public void setInvCount(int count) {
		this.inv_count = count;
	}
	
	public int getInvCount() {
		return inv_count;
	}
	
	public void setTempInvCount(int count) {
		this.temp_inv_count = count;
	}
	
	public int getTempInvCount() {
		return temp_inv_count;
	}
	
	public void setSystemTime(String t) {
		strSystemCurTime = t;
	}
	
	public String getSystemTime() {
		return strSystemCurTime;
	}
	
	public ChatEngine getChatEngine() {
		return chatEngine;
	}
	
	public static final int CUR_CHAT_ROOM_NONE = -1;
	private int cur_chat_room_id = CUR_CHAT_ROOM_NONE;
	
	public void setCurChatRoomId(int value) {
		this.cur_chat_room_id = value;
	}
	
	public int getCurChatRoomId() {
		return this.cur_chat_room_id;
	}
	
	private int lastNotifyRoomType = 0;
	
	public int getLastNotifyRoomType() {
		return lastNotifyRoomType;
	}
	
	public void setLastNotifyRoomType(int type) {
		lastNotifyRoomType = type;
	}
	
	private GgBroadCast broadCaster;
	
	public void initBroadCaster() {
		broadCaster = new GgBroadCast(this);
	}
	
	public GgBroadCast getBroadCaster() {
		return broadCaster;
	}
	
	private ServerTimeUtil servTimeUtil;
	
	public void setClientTime(String value) {
		servTimeUtil.setClientTime(value);
	}
	
	public void setServerTime(String value) {
		servTimeUtil.setServerTime(value);
		servTimeUtil.getTimeDiff();
	}
	
	public String getCurServerTime() {
		return servTimeUtil.getCurServerTime();
	}
	
	public GgLoginAgent getLoginAgent() {
		return loginAgent;
	}
	
	public void setMyClubID(String[] ids) {
		mMyClubID = ids;
	}
	
	public String[] getMyClubID() {
		return mMyClubID;
	}
}
