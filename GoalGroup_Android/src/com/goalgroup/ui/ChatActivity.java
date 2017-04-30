package com.goalgroup.ui;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.graphics.Rect;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.os.SystemClock;
import android.provider.MediaStore;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AbsListView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.audio.AudioCenter;
import com.goalgroup.chat.component.ChatBaseActivity;
import com.goalgroup.chat.component.ChatEngine;
import com.goalgroup.chat.imageupload.MOHttpRequester;
import com.goalgroup.chat.imageupload.MOHttpResponse;
import com.goalgroup.chat.info.GgChatInfo;
import com.goalgroup.chat.info.history.ChatBean;
import com.goalgroup.chat.info.history.ChatHistoryDB;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.common.GgBroadCast;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.BreakUpClubTask;
import com.goalgroup.task.CancelGameTask;
import com.goalgroup.task.GetUserIDTask;
import com.goalgroup.task.LeaveClubTask;
import com.goalgroup.task.ResponseToGameTask;
import com.goalgroup.ui.HomeActivity;
import com.goalgroup.ui.adapter.PanelAdapter;
import com.goalgroup.ui.chat.ChatAdapter;
import com.goalgroup.ui.chat.ChatEntity;
import com.goalgroup.ui.chat.EmoteUtil;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.xEditText;
import com.goalgroup.ui.view.xTextView;
import com.goalgroup.utils.DateUtil;
import com.goalgroup.utils.FileUtil;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StorageUtil;
import com.goalgroup.utils.StringUtil;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.BinaryHttpResponseHandler;
import com.loopj.android.http.GgHttpResponseHandler;

import cn.jpush.android.api.JPushInterface;

public class ChatActivity extends ChatBaseActivity implements OnClickListener,
		MOHttpRequester {

	private static final int CLUBMEETING_FUNC_COLS = 4;
	private static final int CHALLDISCUSS_FUNC_COLS = 3;

	private static final int PICK_FROM_CAMERA = 0;
	private static final int PICK_FROM_ALBUM = 1;
	private static final int CROP_FROM_CAMERA = 2;
	private static final int PICK_GAME_SCHEDULE = 3;
	private static final int CLUB_INFO = 4;
	private static final int CLEAR_HISTORY = 5;
	private static final int EDIT_GAME = 6;
	
	private ChatEngine chatEngine;
	private GgChatInfo ggChatInfo;
	
	private boolean lastServerState;
	private boolean oldServerState;
	private boolean serverState;
	
	private int chatType = -1;

	private Button btnBack;
	private TextView tvTitle;
	private Button btnSetting;
	private ImageView btnSettingImg;
	private ImageButton btnViewPanel;
	private TextView btnText;
	private xEditText editContent;
	private Button btnSend;

	private LinearLayout popupMenu;
	private Button mnuClubMembers;
	private Button mnuClubInfos;
	private Button mnuEditGame;
	private Button mnuCMSettings;
	private Button mnuBreakClub;

	private AbsListView lvChatHistory;
	private ChatAdapter adapter;

	private Boolean panelVisible = false;
	private View viewPanel = null;
	private LinearLayout otherPanel = null;
	private LinearLayout emotePanel = null;
	private RelativeLayout recPanel = null;
	
	private Button btnRecord;
	private ImageView imgRecMark;
	
	private Button btnRecordCancel;
	private ImageView imgRecCancel;

	private TextView lbl_minute = null;
	private TextView lbl_second = null;
	private GridView emoticon_grid1 = null;
	private GridView emoticon_grid2 = null;
	public ArrayList<EmoticonItem> emoticonList1;
	public ArrayList<EmoticonItem> emoticonList2;
	private Button btn_left_emoticon = null;
	private Button btn_right_emoticon = null;
	private ImageButton btnShowEmoticon;
	private Button btn_delEmoticon=null;
	private ImageButton btn_voice = null;
	private Handler timerHandler;
	private Runnable timerRunnable;

	private int[] title_ids = { R.string.club_meeting, R.string.chall_discuss };

	private Uri mImageCaptureUri;
	private Uri mImageCropUri;

	private int myClubId;
	private int challId;
	private int gameId;
	private int game_state;
	private int createClubId;
	private int curUserId;
	private String curUserName;
	private int curRoomId;
	private int recTime = 0;
	private int mScrollState;

	private int type;
	// private int req_userId;

	private MyClubData mClubData;
	private int[] myClubIds;
	private GgProgressDialog dlg;

	public AlertDialog.Builder builder;
	public AlertDialog.Builder voiceDlg;
	public AlertDialog dialog;
	public ListView emoticonListView;
	public ArrayList<EmoticonItem> emoticonList;
	public int emoticon_position = 1000;

	private String photo_name = null;
	private String audio_name = null;
	private int camera_album_flag; // first:it shows the photoe's source(if
									// camera or album)
	private int msg_type = 0; // 1: img_chat, 0: normal message chat

	private boolean firstUpdate;

	public static ChatActivity instance;

	private ChatHistoryDB historyDB;
	private AudioCenter audioWriter;
	private String audioMailName;
	private AudioCenter audioPlayer;
	public static boolean m_vMailPlaying = false;

	public GgProgressDialog pro_dlg;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		IntentFilter filter = new IntentFilter();
		filter.addAction(GgBroadCast.GOAL_GROUP_BROADCAST);
		registerReceiver(broadCastReceiver, filter);
		
		setContentView(R.layout.activity_chat);
		
		chatEngine = GgApplication.getInstance().getChatEngine();
		lastServerState = chatEngine.getConnectFlag();
		oldServerState = chatEngine.getConnectFlag();
		serverState = chatEngine.getConnectFlag();
		ggChatInfo = GgApplication.getInstance().getChatInfo();
		
		audioPlayer = new AudioCenter();

		firstUpdate = true;

		instance = this;

		historyDB = ggChatInfo.getChatHistDB();

		mClubData = new MyClubData();
		myClubIds = mClubData.getOwnerClubIDs();

		curUserId = Integer.valueOf(GgApplication.getInstance().getUserId());
		curUserName = GgApplication.getInstance().getUserName();

		chatType = getIntent().getExtras().getInt(ChatConsts.CHAT_TYPE_TAG);
		createClubId = getIntent().getExtras().getInt(
				ChatConsts.CREATE_CLUB_ID_TAG);
		myClubId = getIntent().getExtras().getInt(ChatConsts.CLUB_ID_TAG);
		gameId = getIntent().getExtras().getInt(ChatConsts.GAME_ID);
		game_state = getIntent().getExtras().getInt(ChatConsts.GAME_STATE);
		challId = getIntent().getExtras().getInt(ChatConsts.CHALLENGE_ID);
		// req_userId = getIntent().getExtras().getInt(ChatConsts.REQ_USER_ID);
		type = getIntent().getExtras().getInt("type");

		if (chatType == ChatConsts.FROM_MEETING) {
			ChatRoomInfo room = ggChatInfo.getClubChatRoom(myClubId);
			room.resetUnreadCount();
			curRoomId = room.getRoomId();
		}
		
		if(chatType == ChatConsts.FROM_DISCUSS) {
			curRoomId = getIntent().getExtras().getInt(ChatConsts.ROOM_ID);
			ggChatInfo.getChatRoomDB().resetUnreadCount(curRoomId);
		}
		
		GgApplication.getInstance().setCurChatRoomId(curRoomId);

		btnBack = (Button) findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View view) {
				GgApplication.getInstance().setCurChatRoomId(GgApplication.CUR_CHAT_ROOM_NONE);
				
				loaderHandler.removeCallbacks(runtimeDetailLoader);
				setResult(RESULT_OK, getIntent());
				finish();
			}
		});

		tvTitle = (TextView) findViewById(R.id.top_title);
		if (chatType == ChatConsts.FROM_MEETING)
			tvTitle.setText(mClubData.getNameFromID(myClubId) + "-"
					+ getString(title_ids[chatType]));
		else
			tvTitle.setText(getString(title_ids[chatType]));

		if (chatType != ChatConsts.FROM_DISCUSS) {
			btnSetting = (Button)findViewById(R.id.btn_view_more);
			btnSettingImg = (ImageView)findViewById(R.id.top_img);
			
			btnSetting.setVisibility(View.VISIBLE);
			btnSettingImg.setVisibility(View.VISIBLE);
			btnSettingImg.setBackgroundResource(R.drawable.list_more);
			// btnSetting.setText(getString(view_more_ids[chatType]));
			btnSetting.setOnClickListener(this);
		}
		
		btnText = (TextView) findViewById(R.id.common_action_text);
		btnText.setVisibility(View.GONE);
		
		popupMenu = (LinearLayout) findViewById(R.id.club_meeting_popup_menu);
		popupMenu.setVisibility(View.GONE);
		btn_left_emoticon = (Button) findViewById(R.id.back_emoticon);
//		btn_left_emoticon.setVisibility(View.INVISIBLE);
		btn_right_emoticon = (Button) findViewById(R.id.fore_emoticon);
//		btn_right_emoticon.setVisibility(View.VISIBLE);
		emoticon_grid1 = (GridView) findViewById(R.id.emoticon_grid1);
		emoticon_grid2 = (GridView) findViewById(R.id.emoticon_grid2);
		emoticonList1 = new ArrayList<EmoticonItem>();
		emoticonList2 = new ArrayList<EmoticonItem>();

		loadEmoticon();

		EmoticonAdapter emoticonAdapter1 = new EmoticonAdapter(this, 1);
		EmoticonAdapter emoticonAdapter2 = new EmoticonAdapter(this, 2);
		emoticon_grid1.setAdapter(emoticonAdapter1);
		emoticon_grid1.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// dialog.dismiss();
				if (position == 24) {
					editContent.removeLastCharacter();
				} else 
					editContent.insertDrawable(EmoteUtil.emoImageIDs[position], 20, 20);
			}
		});

		emoticon_grid2.setAdapter(emoticonAdapter2);
		emoticon_grid2.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// dialog.dismiss();
				editContent.insertDrawable(EmoteUtil.emoImageIDs[26 + position], 20, 20);
			}
		});
		btn_left_emoticon.setOnClickListener(this);
		btn_right_emoticon.setOnClickListener(this);

		mnuClubMembers = (Button) findViewById(R.id.club_meeting_mnu_club_members);
		mnuClubMembers.setOnClickListener(this);
		mnuClubInfos = (Button) findViewById(R.id.club_meeting_mnu_club_infos);
		mnuClubInfos.setOnClickListener(this);
		mnuEditGame = (Button) findViewById(R.id.club_meeting_mnu_edit_game);
		mnuEditGame.setOnClickListener(this);
		mnuCMSettings = (Button) findViewById(R.id.club_meeting_mnu_settings);
		mnuCMSettings.setOnClickListener(this);
		mnuBreakClub = (Button) findViewById(R.id.club_break_up);
		mnuBreakClub.setOnClickListener(this);
		

		btnSend = (Button) findViewById(R.id.btn_send);
		btnSend.setOnClickListener(this);

		btn_voice = (ImageButton) findViewById(R.id.btn_voice);
		
		adapter = new ChatAdapter(this);

		ArrayList<ChatBean> logs = historyDB.fetchMsgs(Integer
				.toString(curRoomId));
		for (ChatBean log : logs) {
			if ("".equals(log.getMsg()) || null == log.getMsg()) continue;
			curUserName = GgApplication.getInstance().getUserName();
			String name = log.getIsMine() == 1 ? curUserName : log.getBuddy();

			boolean isMine = log.getIsMine() == 1 ? true : false;
			int user_id = log.getIsMine() == 1 ? curUserId : log.getUserID();
			String user_photo = log.getIsMine() == 1 ? GgApplication
					.getInstance().getUserPhoto() : log.getBuddyPhoto();
			boolean isSent = log.getIsSent() == 1 ? true : false;
			if (chatEngine.isNewDiscussRoom(log.getMsg()) || chatEngine.isUpdateDiscussRoom(log.getMsg()))
				continue;
			ChatEntity entity = new ChatEntity(user_id, name, log.getTime(),
					log.getMsg(), 0, isMine, user_photo, isSent);
			adapter.addData(entity);
		}

		lvChatHistory = (ListView) findViewById(R.id.chat_history);
		lvChatHistory.setAdapter(adapter);
		lvChatHistory.setSelection(lvChatHistory.getCount() - 1);
		lvChatHistory.setOnScrollListener(new AbsListView.OnScrollListener()
		{
			@Override
			public void onScrollStateChanged(AbsListView view, int scrollState)
			{
				//记录当前状态
				mScrollState = scrollState;
			}

			@Override
			public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount)
			{
				// 可视的最后一个列表项的索引
				int lastVisibleItem = firstVisibleItem + visibleItemCount - 1; 
				//当列表正处于滑动状态且滑动到列表底部时，执行
				if (mScrollState != AbsListView.OnScrollListener.SCROLL_STATE_IDLE 
					&& lastVisibleItem == totalItemCount - 1)
				{
					// 执行线程，模拟睡眠5秒钟后添加10个列表项
					new Thread()
					{

						private Handler handler = new Handler()
						{

							@Override
							public void handleMessage(Message msg)
							{
								super.handleMessage(msg);
								//通知数据集变化
								adapter.notifyDataSetChanged();
							}

						};

						@Override
						public void run()
						{
							super.run();
							try
							{
								sleep(5000);
								handler.sendEmptyMessage(0);
							} catch (InterruptedException e)
							{
								e.printStackTrace();
							}
						}

					}.start();
				}
			}
		});

		btn_delEmoticon=(Button)findViewById(R.id.delete_btn);
		btn_delEmoticon.setOnClickListener(this);
		btnShowEmoticon = (ImageButton) findViewById(R.id.btn_emoticon);
		btnShowEmoticon.setOnClickListener(this);

		initPanel();

		editContent = (xEditText) findViewById(R.id.edit_chat_content);
		editContent.setOnClickListener(this);
		editContent.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
				// here is your code
				if (s.length() != 0) {
					btnViewPanel.setVisibility(View.GONE);
					btnSend.setVisibility(View.VISIBLE);
				} else {
					btnViewPanel.setVisibility(View.VISIBLE);
					btnSend.setVisibility(View.GONE);
				}
			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				// TODO Auto-generated method stub
			}

			@Override
			public void afterTextChanged(Editable arg0) {
				// TODO Auto-generated method stub

			}
		});

		InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
		inputMethodManager.hideSoftInputFromWindow(
				editContent.getWindowToken(), 0);
		
		loaderHandler.post(runtimeDetailLoader);
		
		GgApplication.getInstance().homeActivity.stopRunTimeDetail();
	}

	@Override
	public void onResume() {
		
		super.onResume();
		adapter.notifyDataSetChanged();
		if (firstUpdate) {
			firstUpdate = false;
		}
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		// TODO Auto-generated method stub
		if (keyCode == KeyEvent.KEYCODE_BACK){
			GgApplication.getInstance().setCurChatRoomId(GgApplication.CUR_CHAT_ROOM_NONE);
			loaderHandler.removeCallbacks(runtimeDetailLoader);
			setResult(RESULT_OK, getIntent());
			finish();
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}
	
	Handler loaderHandler = new Handler();
	Runnable runtimeDetailLoader = new Runnable() {
		
		@Override
		public void run() {
			lastServerState = oldServerState;
			oldServerState = serverState;
			serverState = chatEngine.getConnectFlag();
			if ((oldServerState == false && serverState == true) ||
					(lastServerState == false && oldServerState ==true)) {
				adapter.clearData();
				ArrayList<ChatBean> logs = historyDB.fetchMsgs(Integer
						.toString(curRoomId));
				for (ChatBean log : logs) {
					if ("".equals(log.getMsg()) || null == log.getMsg()) continue;
					curUserName = GgApplication.getInstance().getUserName();
					String name = log.getIsMine() == 1 ? curUserName : log.getBuddy();

					boolean isMine = log.getIsMine() == 1 ? true : false;
					int user_id = log.getIsMine() == 1 ? curUserId : log.getUserID();
					String user_photo = log.getIsMine() == 1 ? GgApplication
							.getInstance().getUserPhoto() : log.getBuddyPhoto();
					boolean isSent = log.getIsSent() == 1 ? true : false;
					if (chatEngine.isNewDiscussRoom(log.getMsg()) || chatEngine.isUpdateDiscussRoom(log.getMsg()))
						continue;
					ChatEntity entity = new ChatEntity(user_id, name, log.getTime(),
							log.getMsg(), 0, isMine, user_photo, isSent);
					adapter.addData(entity);
				}
				adapter.notifyDataSetChanged();
			}
			
			String[] clubIds = GgApplication.getInstance().getClubId();
			boolean breakClub = false;
			for (int i = 0; i < clubIds.length; i++) {
				if (Integer.valueOf(clubIds[i]) == myClubId)
					breakClub = true;
			}
			loaderHandler.postDelayed(runtimeDetailLoader, 10000);
			if (!breakClub){
				loaderHandler.removeCallbacks(runtimeDetailLoader);
				Toast.makeText(ChatActivity.this, getString(R.string.breaked_club), Toast.LENGTH_SHORT).show();
				finish();
			}
		}
	};
	
	@Override
	public void onPause() {
		super.onPause();
	}

	public void stopCreateChatRoom() {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
	}

	private void dismissDlg() {
		if (timerHandler != null)
			timerHandler.removeCallbacks(timerRunnable);
		timerHandler = null;

		if (dialog != null)
			dialog.dismiss();
		dialog = null;
	}

	@Override
	public void onClick(View view) {
		Intent intent;
		if(view.getId() != R.id.btn_view_more) {
			popupMenu.setVisibility(View.GONE);
		}
			
		switch (view.getId()) {
		case R.id.btn_voice:
			LayoutInflater mInflater = LayoutInflater.from(this);
			View dlg_view = mInflater.inflate(R.layout.dlg_voice_record, null);
			dialog = new AlertDialog.Builder(this)
					.setView(dlg_view)
					.setCancelable(false)
					.setPositiveButton(getString(R.string.ok),
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int arg1) {
									audioWriter.stopPublish();
									SystemClock.sleep(500);
									
									msg_type = 2;
									
									String time = GgApplication.getInstance().getCurServerTime();
									boolean sent = chatEngine.sendMessage(audioMailName, ChatConsts.MSG_AUDIO, curRoomId, time, true);
									
									curUserName = GgApplication.getInstance().getUserName();
									
									// show the image_chat on your notation in the listView
									ChatEntity histItem = new ChatEntity(curUserId, curUserName,
											time, audioMailName, ChatConsts.MSG_AUDIO,
											true, GgApplication.getInstance().getUserPhoto(), sent);
									adapter.addData(histItem);
									adapter.notifyDataSetChanged();
			
									lvChatHistory.setSelection(lvChatHistory.getCount() - 1);
									dismissDlg();
								}
							})
					.setNegativeButton(R.string.cancel,
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int item) {
									audioWriter.stopPublish();
									dismissDlg();
								}
							}).create();

			lbl_minute = (TextView) dlg_view
					.findViewById(R.id.lbl_record_minute);
			lbl_second = (TextView) dlg_view
					.findViewById(R.id.lbl_record_second);

			dialog.show();

			recTime = 0;

			timerRunnable = new Runnable() {

				@Override
				public void run() {
					recTime++;

					lbl_second.setText(String.format("%02d", recTime % 60));
					lbl_minute.setText(String.format("%02d", recTime / 60));

					timerHandler.postDelayed(timerRunnable, 1000);
				}
			};

			timerHandler = new Handler();
			timerHandler.post(timerRunnable);
			
			long now = System.currentTimeMillis();
			String nowMilliSecString = String.valueOf(now);
			
			audioMailName = "audio_user_" + curUserId + "_";

			audioMailName = audioMailName.concat(nowMilliSecString);
			audioMailName = audioMailName.concat(".gga");
			
			audioWriter = new AudioCenter();
			audioWriter.publishSpeexAudioFile(audioMailName);
			
			break;
		case R.id.btn_view_more:
			popupMenu
					.setVisibility(popupMenu.getVisibility() == View.GONE ? View.VISIBLE
							: View.GONE);
			break;
		case R.id.club_meeting_mnu_club_members:
			intent = new Intent(ChatActivity.this, ClubMembersActivity.class);
			intent.putExtra(ChatConsts.CLUB_ID_TAG, myClubId);
			startActivity(intent);
			break;
		case R.id.club_meeting_mnu_club_infos:
			if (mClubData.isManagerOfClub(myClubId)) {
				intent = new Intent(ChatActivity.this, CreateClubActivity.class);
				intent.putExtra(CommonConsts.CLUB_ID_TAG, myClubId);
				intent.putExtra(CommonConsts.CLUB_TYPE_TAG,
						CommonConsts.EDIT_GAME);
				startActivityForResult(intent, CLUB_INFO);
			} else {
				intent = new Intent(ChatActivity.this, ClubInfoActivity.class);
				intent.putExtra(GgIntentParams.CLUB_ID,
						String.valueOf(myClubId));
				startActivityForResult(intent, CLUB_INFO);
			}
			break;
		case R.id.club_meeting_mnu_edit_game:
			if (mClubData.isManagerOfClub(myClubId)) {
				intent = new Intent(ChatActivity.this,
						NewChallengeActivity.class);
				intent.putExtra(GgIntentParams.CLUB_ID,
						String.valueOf(myClubId));
				intent.putExtra("type", CommonConsts.NEW_GAME);
				intent.putExtra("challType", CommonConsts.CUSTOM_GAME);
				startActivity(intent);
			} else
				Toast.makeText(ChatActivity.this,
						getString(R.string.no_manager), Toast.LENGTH_SHORT)
						.show();
			break;
		case R.id.club_meeting_mnu_settings:
			intent = new Intent(ChatActivity.this,
					ManagerSettingsActivity.class);
			intent.putExtra(ChatConsts.CLUB_ID_TAG, myClubId);
			intent.putExtra(ChatConsts.REQ_USER_ID, curUserId);
			startActivityForResult(intent, CLEAR_HISTORY);
			break;
		case R.id.club_break_up:
			if (!mClubData.isManagerOfClub(myClubId)) {
				Toast.makeText(ChatActivity.this, getString(R.string.no_manager), Toast.LENGTH_SHORT).show();
				return;
			}
			dialog = new AlertDialog.Builder(ChatActivity.this)
			.setTitle(R.string.breakup_title)
			.setMessage(R.string.breakup_messege)
			.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					Object[] param = new Object[2];
					param[0] = GgApplication.getInstance().getUserId();
					param[1] = String.valueOf(myClubId);
					startBreakUpClub(true, param);
				}
			})
			.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {					
				}
			}).create();
			
			dialog.show();
			break;
		case R.id.edit_chat_content:
			viewPanel.setVisibility(View.GONE);
			otherPanel.setVisibility(View.GONE);
			emotePanel.setVisibility(View.GONE);
			recPanel.setVisibility(View.GONE);
			break;
		case R.id.btn_send:			
			String msg = editContent.getText().toString();
			
			String time = GgApplication.getInstance().getCurServerTime();
			boolean sent = chatEngine.sendMessage(msg, ChatConsts.MSG_TEXT, curRoomId, time, true);

			curUserName = GgApplication.getInstance().getUserName();
			
			ChatEntity histItem = new ChatEntity(curUserId, curUserName,
					time, msg, ChatConsts.MSG_TEXT, true,
					GgApplication.getInstance().getUserPhoto(), sent);
			histItem.setState(sent);
			adapter.addData(histItem);
			adapter.notifyDataSetChanged();

			lvChatHistory.setSelection(lvChatHistory.getCount() - 1);

			editContent.setText("");
				
			break;
		case R.id.btn_emoticon:// /////////////////////emoticon panel show
			toggleEconAndFunc();
			break;
		case R.id.back_emoticon:
			// TODO Auto-generated method stub
			emoticon_grid1.setVisibility(View.VISIBLE);
			emoticon_grid2.setVisibility(View.GONE);
//			btn_right_emoticon.setVisibility(View.VISIBLE);
//			btn_left_emoticon.setVisibility(View.INVISIBLE);
			Log.d("emo_dir", "back");
			break;
		case R.id.fore_emoticon:
			// TODO Auto-generated method stub
			emoticon_grid1.setVisibility(View.GONE);
			emoticon_grid2.setVisibility(View.VISIBLE);
//			btn_right_emoticon.setVisibility(View.INVISIBLE);
//			btn_left_emoticon.setVisibility(View.VISIBLE);
			Log.d("emo_dir", "fore");
			break;
		 case R.id.delete_btn:
			 editContent.removeLastCharacter();
		 break;
		}
	}

	private void initPanel() {
		
		btnViewPanel = (ImageButton) findViewById(R.id.btn_view_panel);
		btnViewPanel.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View view) {
				showPanel();
			}
		});

		viewPanel = findViewById(R.id.chat_bottom_panel);
		emotePanel = (LinearLayout) findViewById(R.id.emoticon_panel);

		int[][] panel_names = {
				{ R.string.picture, R.string.schedule, R.string.club_results,
						R.string.player_results, R.string.leave_club,
						R.string.official_note, R.string.chat_challenge,
						R.string.enter_request_list },
				{ R.string.change_game, R.string.game_result,
						R.string.exit_game, R.string.response_game,
						R.string.opponent_info, R.string.report_other } };

		ArrayList<String> names = new ArrayList<String>();
		for (int name_id : panel_names[chatType])
			names.add(getString(name_id));

		int[][] panel_imgs = {
				{ R.drawable.cm_func_01_picture,
						R.drawable.cm_func_02_schedule,
						R.drawable.cm_func_03_club_results,
						R.drawable.cm_func_04_player_results,
						R.drawable.cm_func_05_leave_club,
						R.drawable.cm_func_06_official_note,
						R.drawable.cm_func_07_challenge,
						R.drawable.cm_func_08_reqenter },
				{ R.drawable.cd_func_01_change_game,
						R.drawable.cd_func_02_edit_result,
						R.drawable.cd_func_03_exit_game,
						R.drawable.cd_func_04_response_game,
						R.drawable.cd_func_05_opponent_info,
						R.drawable.cd_func_06_report_other } };

		ArrayList<Integer> imgs = new ArrayList<Integer>();
		for (int img_id : panel_imgs[chatType])
			imgs.add(new Integer(img_id));

		PanelAdapter funcGridAdapter = new PanelAdapter(this, names, imgs);

		int[] panel_columns = { CLUBMEETING_FUNC_COLS, CHALLDISCUSS_FUNC_COLS };

		GridView funcGrid = new GridView(this);
		funcGrid.setNumColumns(panel_columns[chatType]);
		funcGrid.setAdapter(funcGridAdapter);

		funcGrid.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View v,
					int position, long id) {
				panelMeetingProc(position);
			}
		});

		otherPanel = (LinearLayout) findViewById(R.id.chat_func_panel);
		otherPanel.addView(funcGrid);
		
		recPanel = (RelativeLayout)findViewById(R.id.rec_panel);
		btnRecord = (Button)findViewById(R.id.btn_rec_start);
		imgRecMark = (ImageView)findViewById(R.id.img_rec_mark);
		
		btn_voice.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				showRecPanel();
			}
		});
		
		btnRecord.setOnLongClickListener(new View.OnLongClickListener() {
			
			@Override
			public boolean onLongClick(View v) {
				imgRecMark.setVisibility(View.GONE);
				
				recTime = 0;

				timerRunnable = new Runnable() {

					@Override
					public void run() {
						recTime++;

						btnRecord.setText(String.format("%02d:%02d", recTime / 60, recTime % 60));

						if(recTime == 90) {
							timerHandler.removeCallbacks(timerRunnable);
							Toast.makeText(ChatActivity.this, getString(R.string.rec_limit), Toast.LENGTH_SHORT).show();
							onStopRecord();
						}
						else
							timerHandler.postDelayed(timerRunnable, 1000);
					}
				};

				timerHandler = new Handler();
				timerHandler.post(timerRunnable);
				
				long now = System.currentTimeMillis();
				String nowMilliSecString = String.valueOf(now);
				
				audioMailName = "audio_user_" + curUserId + "_";

				audioMailName = audioMailName.concat(nowMilliSecString);
				audioMailName = audioMailName.concat(".gga");
				
				audioWriter = new AudioCenter();
				audioWriter.publishSpeexAudioFile(audioMailName);
				
				btnRecordCancel.setVisibility(View.VISIBLE);
				imgRecCancel.setVisibility(View.VISIBLE);
				
				return false;
			}
		});
		
		btnRecord.setOnTouchListener(new View.OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				int x = (int)event.getRawX();
	            int y = (int)event.getRawY();
	            if (inViewInBounds(btnRecordCancel, x, y)) {
	            	v.setPressed(false);
	            	imgRecCancel.setVisibility(View.GONE);
	            	btnRecordCancel.setText("取消");
	            	btnRecordCancel.dispatchTouchEvent(event);
	            	return true;
	            } else {
	            	if (event.getAction() != MotionEvent.ACTION_UP) {
						v.setPressed(true);
						return false;
					}
	            }
				
				return onStopRecord();
			}
		});
		
		btnRecordCancel = (Button)findViewById(R.id.btn_rec_cancel);
		imgRecCancel = (ImageView)findViewById(R.id.img_rec_cancel);
		btnRecordCancel.setOnTouchListener(new View.OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				int x = (int)event.getRawX();
	            int y = (int)event.getRawY();
	            if (!inViewInBounds(btnRecordCancel, x, y)) {
					v.setPressed(false);
	            	//btnRecord.dispatchTouchEvent(event);
	            	return true;
	            } else {
	            	switch (event.getAction()) {
		            case MotionEvent.ACTION_DOWN:
		            case MotionEvent.ACTION_MOVE:
		                if (!v.isPressed()) {
		                    v.setPressed(true);
		                }
		                return false;
		            case MotionEvent.ACTION_UP:
		                // perform action ON CLICK
		            	if (timerHandler != null) {
							timerHandler.removeCallbacks(timerRunnable);
							timerHandler = null;
						}
						
						btnRecord.setText("");
						imgRecMark.setVisibility(View.VISIBLE);
						
						if (audioWriter == null)
							return false;
						
						audioWriter.stopPublish();
						audioWriter = null;
						btnRecordCancel.setText("");
						btnRecordCancel.setVisibility(View.GONE);
						imgRecCancel.setVisibility(View.GONE);
		                break;
	            	}
				
	            }

	            v.setPressed(false);
	            return false;
			}
		});
	}
	
	private boolean onStopRecord()
	{		
		final String time;
		
		btnRecordCancel.setText("");
		btnRecordCancel.setVisibility(View.GONE);
		imgRecCancel.setVisibility(View.GONE);
		
		if (timerHandler != null) {
			timerHandler.removeCallbacks(timerRunnable);
			timerHandler = null;
		}
		
		btnRecord.setText("");
		imgRecMark.setVisibility(View.VISIBLE);
		
		if (audioWriter == null)
			return false;
		
		audioWriter.stopPublish();
		audioWriter = null;
		
		SystemClock.sleep(500);
		
		msg_type = 2;
		time = GgApplication.getInstance().getCurServerTime();
		
		new AsyncTask<Void, Boolean, Boolean>() {
			ChatEntity histItem;
			@Override
			protected void onPreExecute() {
				
				curUserName = GgApplication.getInstance().getUserName();
				// show the image_chat on your notation in the listView
				histItem = new ChatEntity(curUserId, curUserName,
						time, audioMailName, ChatConsts.MSG_AUDIO,
						true, GgApplication.getInstance().getUserPhoto(), true, true);
				adapter.addData(histItem);
				lvChatHistory.setSelection(lvChatHistory.getCount() - 1);
				
				super.onPreExecute();
			}

			@Override
			protected Boolean doInBackground(Void... params) {
				// TODO Auto-generated method stub
				boolean sent = chatEngine.sendMessage(audioMailName, ChatConsts.MSG_AUDIO, curRoomId, time, true);
				publishProgress(sent);
			
				return sent;
			}
			
			@Override
			protected void onProgressUpdate(Boolean... progress) {
				histItem.setSending(false);
				histItem.setState(progress[0]);
				adapter.notifyDataSetChanged();
			}
			
			@Override
			protected void onPostExecute(Boolean result) {
				
			}
		}.execute();
		return false;
	}
	
	Rect outRect = new Rect();
    int[] location = new int[2];

    private boolean inViewInBounds(View view, int x, int y){
        view.getDrawingRect(outRect);
        view.getLocationOnScreen(location);
        outRect.offset(location[0], location[1]);
        return outRect.contains(x, y);
    }

	private void showPanel() {
		if (!panelVisible) {
			InputMethodManager imm = (InputMethodManager) getApplicationContext()
					.getSystemService(Context.INPUT_METHOD_SERVICE);
			imm.hideSoftInputFromWindow(editContent.getWindowToken(), 0);
		}

		if (!otherPanel.isShown()) {
			viewPanel.setVisibility(View.VISIBLE);
			otherPanel.setVisibility(View.VISIBLE);
			emotePanel.setVisibility(View.GONE);
			recPanel.setVisibility(View.GONE);
		} else {
			viewPanel.setVisibility(View.GONE);
			otherPanel.setVisibility(View.GONE);
			emotePanel.setVisibility(View.GONE);
			recPanel.setVisibility(View.GONE);
		}
	}
	
	private void showRecPanel() {
		if (!panelVisible) {
			InputMethodManager imm = (InputMethodManager) getApplicationContext()
					.getSystemService(Context.INPUT_METHOD_SERVICE);
			imm.hideSoftInputFromWindow(editContent.getWindowToken(), 0);
		}

		if (!recPanel.isShown()) {
			viewPanel.setVisibility(View.VISIBLE);
			recPanel.setVisibility(View.VISIBLE);
			otherPanel.setVisibility(View.GONE);
			emotePanel.setVisibility(View.GONE);
		} else {
			viewPanel.setVisibility(View.GONE);
			otherPanel.setVisibility(View.GONE);
			emotePanel.setVisibility(View.GONE);
			recPanel.setVisibility(View.GONE);
		}
	}

	private void toggleEconAndFunc() {
		if (!emotePanel.isShown()) {
			InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
			inputMethodManager.hideSoftInputFromWindow(
					editContent.getWindowToken(), 0);
			viewPanel.setVisibility(View.VISIBLE);
			otherPanel.setVisibility(View.GONE);
			emotePanel.setVisibility(View.VISIBLE);
			recPanel.setVisibility(View.GONE);
		} else {
			viewPanel.setVisibility(View.GONE);
			otherPanel.setVisibility(View.GONE);
			emotePanel.setVisibility(View.GONE);
			recPanel.setVisibility(View.GONE);
		}
	}

	private void panelMeetingProc(int position) {
		Intent intent;

		switch (position) {
		case 0:
			if (chatType == ChatConsts.FROM_MEETING) {
				addPhoto();
			} else {
				if (challId == 0) {
					Toast.makeText(ChatActivity.this,
							getString(R.string.no_power), Toast.LENGTH_SHORT)
							.show();
					return;
				}
				
				if (mClubData.isOwner(createClubId)) {
					intent = new Intent(ChatActivity.this,
							NewChallengeActivity.class);
						
					intent.putExtra("challenge_id", challId);
					intent.putExtra("challType", type);
					// intent.putExtra("club1_name",
					// getIntent().getExtras().getString("club1_name"));
					// intent.putExtra("club1_id", createClubId);
					// intent.putExtra("club2_name",
					// getIntent().getExtras().getString("club2_name"));
					// intent.putExtra("club2_id", myClubId);
					// intent.putExtra("game_date",
					// getIntent().getExtras().getString("game_date"));
					// intent.putExtra("game_time",
					// getIntent().getExtras().getString("game_time"));
					// intent.putExtra("player_count",
					// getIntent().getExtras().getString("player_count"));
					// intent.putExtra("stadium_area",
					// getIntent().getExtras().getString("stadium_area"));
					// intent.putExtra("stadium_address",
					// getIntent().getExtras().getString("stadium_address"));
					// intent.putExtra("money_split",
					// getIntent().getExtras().getString("money_split"));
					intent.putExtra("type", CommonConsts.EDIT_GAME);
					startActivityForResult(intent, EDIT_GAME);
				} else {
//					Toast.makeText(ChatActivity.this,
//							getString(R.string.no_power), Toast.LENGTH_SHORT)
//							.show();
					intent = new Intent(ChatActivity.this,
							NewChallengeActivity.class);						
					intent.putExtra("challenge_id", challId);
					intent.putExtra("challType", type);
					intent.putExtra("type", CommonConsts.SHOW_GAME);
					startActivity(intent);
				}
			}
			break;
		case 1:
			if (chatType == ChatConsts.FROM_MEETING) {
				intent = new Intent(ChatActivity.this,
						GameScheduleActivity.class);
				intent.putExtra(CommonConsts.SCHEDULE_FROM_TAG,
						CommonConsts.SCHEDULE_FROM_CHAT);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, myClubId);
				intent.putExtra(ChatConsts.REQ_USER_ID, curUserId);
				startActivityForResult(intent, PICK_GAME_SCHEDULE);
			} else {
				if (gameId == 0) {
					Toast.makeText(ChatActivity.this,
							getString(R.string.edit_result_impossible),
							Toast.LENGTH_SHORT).show();
					break;
				}
				
				if (game_state == 3 || game_state < 2) {
					Toast.makeText(ChatActivity.this,
							getString(R.string.edit_result_impossible),
							Toast.LENGTH_SHORT).show();
					break;
				}

				intent = new Intent(ChatActivity.this, GameResultActivity.class);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, myClubId);
				intent.putExtra(ChatConsts.GAME_ID, gameId);
				intent.putExtra(ChatConsts.GAME_STATE, game_state);
				startActivity(intent);
			}
			break;
		case 2:
			if (chatType == ChatConsts.FROM_MEETING) {
				intent = new Intent(ChatActivity.this,
						ClubHistoryActivity.class);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, myClubId);
				startActivity(intent);
			} else {
				if (gameId != 0){
					if (game_state == CommonConsts.GAME_STATE_FINISHED){
						Toast.makeText(ChatActivity.this, getString(R.string.game_finished), Toast.LENGTH_SHORT).show();
						return;
					} else if(game_state == CommonConsts.GAME_STATE_CANCELED) {
						Toast.makeText(ChatActivity.this, getString(R.string.game_canceled), Toast.LENGTH_SHORT).show();
						return;
					}
					confirmCancelGame();
				}else
					Toast.makeText(ChatActivity.this, R.string.no_exit_game,
							Toast.LENGTH_SHORT).show();
			}
			break;
		case 3:
			if (chatType == ChatConsts.FROM_DISCUSS) {
				if (gameId != 0) {
					Toast.makeText(ChatActivity.this,
							getString(R.string.already_response),
							Toast.LENGTH_SHORT).show();
					break;
				}

				if (mClubData.isOwner(createClubId)) {
					Toast.makeText(ChatActivity.this, R.string.manager_club,
							Toast.LENGTH_SHORT).show();
					break;
				} else
					startResponseToChallenge(challId, myClubId, true, type);
			} else if (chatType == ChatConsts.FROM_MEETING) {
				intent = new Intent(ChatActivity.this,
						PlayerHistoryActivity.class);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, myClubId);
				startActivity(intent);
			}
			break;
		case 4:
			if (chatType == ChatConsts.FROM_MEETING){
				if (mClubData.isOwner(myClubId)){
					Toast.makeText(ChatActivity.this, getString(R.string.select_manager_msg), Toast.LENGTH_SHORT).show();
					return;
				}
				confirmExitClub();
			} else if (chatType == ChatConsts.FROM_DISCUSS) {
				intent = new Intent(ChatActivity.this, ClubInfoActivity.class);
				intent.putExtra(GgIntentParams.CLUB_ID, getIntent().getExtras()
						.getString(ChatConsts.OPP_CLUB_ID_TAG));
				startActivity(intent);
			}
			break;
		case 5:
			if (chatType == ChatConsts.FROM_MEETING) {
				intent = new Intent(ChatActivity.this,
						ClubChallengesActivity.class);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, myClubId);
				intent.putExtra(CommonConsts.CHALL_TYPE_TAG,
						CommonConsts.CHALL_TYPE_ALL_PROCLAIM);
				intent.putExtra(CommonConsts.PROCLAIM_START_TYPE, CommonConsts.FROM_CHAT);
				startActivity(intent);
			} else {
				intent = new Intent(ChatActivity.this, ReportActivity.class);
				intent.putExtra("type", CommonConsts.REPORT_TYPE);
				startActivity(intent);
			}
			break;
		case 6:
			intent = new Intent(ChatActivity.this, ClubChallengesActivity.class);
			intent.putExtra(ChatConsts.CLUB_ID_TAG, myClubId);
			intent.putExtra(CommonConsts.CHALL_TYPE_TAG,
					CommonConsts.CHALL_TYPE_MY_CHALLENGE);
			startActivity(intent);
			break;
		case 7:
			int flag = 0;

			if (mClubData.isOwner()) {
				for (int i = 0; i < myClubIds.length; i++) {
					if (myClubIds[i] == myClubId)
						flag = 1;
				}
				if (flag == 1) {
					intent = new Intent(ChatActivity.this,
							EnterReqListActivity.class);
					intent.putExtra("CLUB_ID", myClubId);
					startActivity(intent);
				} else
					Toast.makeText(ChatActivity.this,
							getString(R.string.no_manager), Toast.LENGTH_SHORT)
							.show();
			} else
				Toast.makeText(ChatActivity.this,
						getString(R.string.no_manager), Toast.LENGTH_SHORT)
						.show();

			break;
		}
	}

	private void addPhoto() {

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

		new AlertDialog.Builder(ChatActivity.this)
				.setTitle(getString(R.string.home_picture_dlg_title))
				.setMessage(getString(R.string.home_picture_dlg_msg))
				.setPositiveButton(getString(R.string.home_picture_camera),
						cameraListener)
				.setNeutralButton(getString(R.string.home_picture_album),
						albumListener)
				.setNegativeButton(getString(R.string.cancel), cancelListener)
				.show();
	}

	private void doTakePhotoAction() {
		
		if (!StorageUtil.isMountedStorage(ChatActivity.this))
			return;
		
		Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

		String url = "tmp_" + String.valueOf(System.currentTimeMillis())
				+ ".jpg";
		mImageCaptureUri = Uri.fromFile(new File(Environment
				.getExternalStorageDirectory(), url));

		intent.putExtra(android.provider.MediaStore.EXTRA_OUTPUT,
				mImageCaptureUri);
		intent.putExtra("return-data", true);
		startActivityForResult(intent, PICK_FROM_CAMERA);
	}

	private void doTakeAlbumAction() {
		Intent intent = new Intent(Intent.ACTION_PICK);
		intent.setType(android.provider.MediaStore.Images.Media.CONTENT_TYPE);
		startActivityForResult(intent, PICK_FROM_ALBUM);
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode != Activity.RESULT_OK)
			return;

		switch (requestCode) {
		case CROP_FROM_CAMERA:
			
			long now = System.currentTimeMillis();
			String nowMilliSecString = String.valueOf(now);

			photo_name = "pic_user_" + curUserId + "_";

			photo_name = photo_name.concat(nowMilliSecString);
			photo_name = photo_name.concat(".jpg");
			mImageCropUri = Uri.fromFile(new File(FileUtil.getFullPath(photo_name)));

			File src_file = new File(mImageCaptureUri.getPath());
			File dst_file = new File(mImageCropUri.getPath());

			if (copyFile(src_file, dst_file)) {
				Toast.makeText(ChatActivity.this, R.string.send_img_success, 2000).show();
			}
			if (camera_album_flag == 1) {
				src_file.delete();
			}

			msg_type = 1; // this message is image_chat
			
			String time = GgApplication.getInstance().getCurServerTime();
			boolean sent = chatEngine.sendMessage(photo_name, ChatConsts.MSG_IMAGE, curRoomId, time, true);
			
			curUserName = GgApplication.getInstance().getUserName();
			
			// show the image_chat on your notation in the listView
			ChatEntity histItem = new ChatEntity(curUserId, curUserName,
					time, photo_name, ChatConsts.MSG_IMAGE,
					true, GgApplication.getInstance().getUserPhoto(), sent);
			histItem.setState(sent);
			adapter.addData(histItem);
			adapter.notifyDataSetChanged();

			lvChatHistory.setSelection(lvChatHistory.getCount() - 1);

			editContent.setText("");
			otherPanel.setVisibility(View.GONE);
			
			break;
		case PICK_FROM_ALBUM:
			Uri captureUri = data.getData();
			String realFileName = getRealPathFromURI(ChatActivity.this,
					captureUri);
			File realFile = new File(realFileName);
			mImageCaptureUri = Uri.fromFile(realFile);
			// mImageCaptureUri = data.getData();

			camera_album_flag = 0;

			Intent intent1 = new Intent("com.android.camera.action.CROP");
			intent1.setDataAndType(mImageCaptureUri, "image/*");

			intent1.putExtra("outputX", 320);
			intent1.putExtra("outputY", 320);
			intent1.putExtra("aspectX", 0);
			intent1.putExtra("aspectY", 0);
			intent1.putExtra("scale", true);
			intent1.putExtra("output", mImageCaptureUri);
			startActivityForResult(intent1, CROP_FROM_CAMERA);
			break;
		case PICK_FROM_CAMERA:
			camera_album_flag = 1;

			Intent intent2 = new Intent("com.android.camera.action.CROP");
			intent2.setDataAndType(mImageCaptureUri, "image/*");

			intent2.putExtra("outputX", 320);
			intent2.putExtra("outputY", 320);
			intent2.putExtra("aspectX", 0);
			intent2.putExtra("aspectY", 0);
			intent2.putExtra("scale", true);
			intent2.putExtra("output", mImageCaptureUri);
			startActivityForResult(intent2, CROP_FROM_CAMERA);
			break;
		case PICK_GAME_SCHEDULE:
			// getIntent().putExtra(ChatConsts.FINISH_NEW_DISCUSS, 1);
			// getIntent().putExtra(CommonConsts.CLUB_ID_TAG,
			// data.getExtras().getInt(CommonConsts.CLUB_ID_TAG));
			// getIntent().putExtra(CommonConsts.OPP_CLUB_ID_TAG,
			// data.getExtras().getInt(CommonConsts.OPP_CLUB_ID_TAG));
			// getIntent().putExtra(CommonConsts.GAME_ID_TAG,
			// data.getExtras().getInt(CommonConsts.GAME_ID_TAG));
			// setResult(RESULT_OK, getIntent());
			// finish();
			break;
		case CLUB_INFO:
			int break_flag = data.getExtras().getInt(CommonConsts.BREAKUP_CLUB);
			String club_name = data.getExtras().getString("club_name");
			if (chatType == ChatConsts.FROM_MEETING)
				tvTitle.setText(club_name + "-"
						+ getString(title_ids[chatType]));

			if (break_flag == CommonConsts.UNBREAKED_CLUB)
				break;
			getIntent().putExtra(CommonConsts.BREAKUP_CLUB, 1);
			setResult(RESULT_OK, getIntent());
			
			GgApplication.getInstance().setCurChatRoomId(GgApplication.CUR_CHAT_ROOM_NONE);
			loaderHandler.removeCallbacks(runtimeDetailLoader);
			finish();
			break;
		case CLEAR_HISTORY:
			lvChatHistory.removeAllViewsInLayout();
			adapter.clearData();
			break;
		case EDIT_GAME:
			ChatRoomInfo room = ggChatInfo.getChatRoom(curRoomId);
			room.setPlayerCount(data.getExtras().getInt("PLAYER_COUNT"));
			room.setGameDate(data.getExtras().getString("CHALL_DATE"));
			room.setGameTime(data.getExtras().getString("CHALL_TIME"));
			room.setRoomTitle();
			GgApplication.getInstance().getChatEngine().updateDiscussRoom(room.getRoomId(), room.getRoomTitle());
			break;
		}
		super.onActivityResult(requestCode, resultCode, data);
		return;
	}

	public String getRealPathFromURI(Context context, Uri contentUri) {
		Cursor cursor = null;
		try {
			String[] proj = { MediaStore.Images.Media.DATA };
			cursor = context.getContentResolver().query(contentUri, proj, null,
					null, null);
			int column_index = cursor
					.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
			cursor.moveToFirst();
			return cursor.getString(column_index);
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}
	}

	private boolean copyFile(File srcFile, File destFile) {
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

	private File recv_dir;
	private String recv_msg;
	private String recv_time;
	private String recv_sender_name;
	private String recv_sender_photo;
	private int recv_room_id;
	private int recv_sender_id;
	
	@Override
	public void setUpdate(JSONObject json) {
		int success_flag = 0;
		String eventStr = null;
		
		recv_dir = new File(FileUtil.getFullPath(""));
		
		boolean parseMsgOK = true;
		
		try {
			eventStr = json.getString("event");
			err_msg = json.getString("err_msg");
			success_flag = json.getInt("success");
			
			recv_sender_id = json.getInt("sender_id");
			recv_sender_name = json.getString("sender_name");
			recv_time = json.getString("send_time");
			recv_time = DateUtil.completeDatetTime(recv_time);
			recv_room_id = json.getInt("room_id");
			recv_sender_photo = json.getString("sender_photo");
			
			if (ChatEngine.UPDATE_IMG_CHAT.equals(eventStr)) {
				recv_msg = json.getString("image_name");
			} else if (ChatEngine.UPDATE_AUD_CHAT.equals(eventStr)) {
				recv_msg = json.getString("audio_name");
			} else {
				recv_msg = json.getString("msg");
				String newMsg = "";
				int len = recv_msg.length();
				for (int i = 0; i < len; i++) {
					if (recv_msg.charAt(i) == '`') {
						int next = recv_msg.indexOf("`", i + 1);
						String idstr = recv_msg.substring(i, next+1);

						int index = StringUtil.findIDfromArray(EmoteUtil.emoArgs, idstr);
						String str = "╬" + EmoteUtil.emoImageIDs[index] + "╬";

						newMsg = newMsg + str;

						i = next;
					} else {
						newMsg = newMsg + recv_msg.charAt(i);
					}
				}
				recv_msg = newMsg;
			}
		} catch (JSONException e) {
			e.printStackTrace();
			parseMsgOK = false;
		}

		if (success_flag != 1 || !parseMsgOK) {
			Toast.makeText(this, err_msg, Toast.LENGTH_LONG).show();
			return;
		}
		
		if (recv_msg.indexOf("我应战了对这个比赛。") == 0)
			if(chatType == ChatConsts.FROM_DISCUSS) {
				ChatRoomInfo room = ggChatInfo.getChatRoom(curRoomId);
				if (room.getGameType() == 2) {
					gameId = room.getGameId();
					game_state = room.getGameState();
				}
			}

		if (eventStr.equals(ChatEngine.UPDATE_CHAT)) {

			chatEngine.updateMsgHistory(recv_msg, ChatConsts.MSG_TEXT, recv_room_id, recv_sender_name, recv_sender_id, 
					recv_time, recv_sender_photo, false, true);
			
			GgApplication.getInstance().getPrefUtil().setLastChatTime(recv_time);
			
			ChatEntity histItem = new ChatEntity(recv_sender_id, recv_sender_name,
					recv_time, recv_msg, ChatConsts.MSG_TEXT, false,
					recv_sender_photo, true);
			
			adapter.addData(histItem);
			adapter.notifyDataSetChanged();
			lvChatHistory.setSelection(lvChatHistory.getCount() - 1);
			
			return;
		}
		
		if (!recv_dir.exists() && !recv_dir.mkdirs()) {
			Toast.makeText(ChatActivity.this, "dir doesn't exist", Toast.LENGTH_SHORT).show();
		}
		
		if (eventStr.equals(ChatEngine.UPDATE_IMG_CHAT)) {
			String image_path = recv_msg;

			photo_name = "pic_down_" + curUserId + "_";

			long now = System.currentTimeMillis();
			String nowMilliSecString = String.valueOf(now);
			photo_name = photo_name.concat(nowMilliSecString);
			photo_name = photo_name.concat(".jpg");
			
			AsyncHttpClient httpIMGClient = new AsyncHttpClient();
			httpIMGClient.setTimeout(10000);
			String[] allowContents = { "image/jpeg", "image/bmp", "image/png" };
			
			httpIMGClient.get(image_path, new BinaryHttpResponseHandler(allowContents) {
				@Override
				public void onSuccess(byte[] buffer) {
					FileUtil.writeFile(FileUtil.getFullPath(photo_name), buffer);
					
					chatEngine.updateMsgHistory(photo_name, ChatConsts.MSG_IMAGE, recv_room_id, recv_sender_name, recv_sender_id, 
							recv_time, recv_sender_photo, false, true);
					
					ChatEntity histItem = new ChatEntity(recv_sender_id,
							recv_sender_name, recv_time, photo_name,
							ChatConsts.MSG_IMAGE, false, recv_sender_photo, true);
					adapter.addData(histItem);
					adapter.notifyDataSetChanged();

					lvChatHistory.setSelection(lvChatHistory.getCount() - 1);
				}

				@Override
				public void onFailure(java.lang.Throwable error,
						java.lang.String content) {

					Log.d("image download HTTP", "onFailure: " + content);

				}
			});
			
			return;			
		}
		
		if (eventStr.equals(ChatEngine.UPDATE_AUD_CHAT)) {
			String audio_path = recv_msg;

			audio_name = "audio_user_" + curUserId + "_";

			long now = System.currentTimeMillis();
			String nowMilliSecString = String.valueOf(now);
			audio_name = audio_name.concat(nowMilliSecString);
			audio_name = audio_name.concat(".gga");

			AsyncHttpClient httpAUDClient = new AsyncHttpClient();
			httpAUDClient.setTimeout(10000);
			
			httpAUDClient.get(audio_path, new GgHttpResponseHandler() {
				@Override
				public void onSuccess(byte[] buffer) {
					
					FileUtil.writeFile(FileUtil.getFullPath(audio_name), buffer);
					
					chatEngine.updateMsgHistory(audio_name, ChatConsts.MSG_AUDIO, recv_room_id, recv_sender_name, recv_sender_id, 
							recv_time, recv_sender_photo, false, true);
					
					ChatEntity histItem = new ChatEntity(recv_sender_id,
							recv_sender_name, recv_time, audio_name,
							ChatConsts.MSG_AUDIO, false, recv_sender_photo, true);
					adapter.addData(histItem);
					adapter.notifyDataSetChanged();

					lvChatHistory.setSelection(lvChatHistory.getCount() - 1);
				}

				@Override
				public void onFailure(Throwable error, String content) {
				}
			});
			
		}
	}

	public class EmoticonItem {

		public int resourceId;

		public EmoticonItem(int resourceId) {
			this.resourceId = resourceId;
		}

		public int getResources() {
			return this.resourceId;
		}

		public void setResources(int resourceId) {
			this.resourceId = resourceId;
		}

	}

	public class EmoticonAdapter extends BaseAdapter {

		private LayoutInflater mInflater;
		private int emoticon_type;

		class ViewHolder {
			ImageView icon;
		}

		public EmoticonAdapter(Context context, int type) {
			mInflater = LayoutInflater.from(context);
			emoticon_type = type;
		}

		@Override
		public int getCount() {
			// TODO Auto-generated method stub
			if (this.emoticon_type == 1) {
				return emoticonList1.size();
			} else {
				return emoticonList2.size();
			}
		}

		@Override
		public Object getItem(int position) {
			// TODO Auto-generated method stub
			if (this.emoticon_type == 1) {
				return emoticonList1.get(position);
			} else {
				return emoticonList2.get(position);
			}
		}

		@Override
		public long getItemId(int position) {
			// TODO Auto-generated method stub
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			// TODO Auto-generated method stub
			ViewHolder v;
			if (convertView == null) {
				convertView = mInflater.inflate(R.layout.emoticon_item, null);
				v = new ViewHolder();
				v.icon = (ImageView) convertView.findViewById(R.id.emot_icon);
				convertView.setTag(v);
			} else {
				v = (ViewHolder) convertView.getTag();
			}
			EmoticonItem item;
			if (this.emoticon_type == 1) {
				item = emoticonList1.get(position);
			} else {
				item = emoticonList2.get(position);
			}

			v.icon.setImageResource(item.getResources());
			return convertView;
		}

	}

	public void loadEmoticon() {
		emoticonList1.add(new EmoticonItem(EmoteUtil.emoImageIDs[0]));
		for (int i = 1; i < 24; i++) {
			emoticonList1.add(new EmoticonItem(EmoteUtil.emoImageIDs[i]));
		}
		emoticonList1.add(new EmoticonItem(EmoteUtil.emoImageIDs[24]));
//		emoticonList2.add(new EmoticonItem(EmoteUtil.emoImageIDs[26]));
//		for (int i = 27; i < 52; i++) {
//			emoticonList2.add(new EmoticonItem(EmoteUtil.emoImageIDs[i]));
//		}
	}

	public void startResponseToChallenge(int challenge_id, int sel_clubID,
			boolean showdlg, int type) {
		if (!NetworkUtil.isNetworkAvailable(ChatActivity.this))
			return;

		if (showdlg) {
			dlg = new GgProgressDialog(ChatActivity.this,
					getString(R.string.wait));
			dlg.show();
		}

		Object[] param;
		param = new Object[3];
		param[0] = challenge_id;
		param[1] = sel_clubID;
		param[2] = type;

		ResponseToGameTask task = new ResponseToGameTask(ChatActivity.this,
				param, 1, -1);
		task.execute();
	}

	public void stopResponseToChallenge(int result, int index, int game_id) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		if (result == GgHttpErrors.GET_CHALL_SUCCESS) {			
			String msg = "我应战了对这个比赛。";
			String time = GgApplication.getInstance().getCurServerTime();
			
			boolean sent = chatEngine.sendMessage(msg, ChatConsts.MSG_TEXT, curRoomId, time, true);
			
			curUserName = GgApplication.getInstance().getUserName();
			
			this.gameId = game_id;
			
			ChatEntity histItem = new ChatEntity(curUserId, curUserName,
					time, msg, ChatConsts.MSG_TEXT,
					true, GgApplication.getInstance().getUserPhoto(), sent);
			adapter.addData(histItem);
			adapter.notifyDataSetChanged();

			lvChatHistory.setSelection(lvChatHistory.getCount() - 1);
			
			otherPanel.setVisibility(View.GONE);
			
			Toast.makeText(ChatActivity.this, R.string.response_success,
					Toast.LENGTH_LONG).show();
		} else if (result == GgHttpErrors.HTTP_POST_FAIL) {
			Toast.makeText(ChatActivity.this, R.string.response_failed,
					Toast.LENGTH_LONG).show();
		} else if (result == 2) {
			Toast.makeText(ChatActivity.this, R.string.response_exist,
					Toast.LENGTH_LONG).show();
		}
	}

	private void confirmExitClub() {
		AlertDialog dialog;
		dialog = new AlertDialog.Builder(ChatActivity.this)
				.setTitle(R.string.leave_club)
				.setMessage(R.string.leave_club_conf)
				.setPositiveButton(R.string.ok,
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog, int item) {
								startLeaveClub(true);
							}
						})
				.setNegativeButton(R.string.cancel,
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog, int item) {
								dialog.dismiss();
							}
						}).create();

		dialog.show();
	}

	public void startLeaveClub(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(ChatActivity.this))
			return;

		if (showdlg) {
			dlg = new GgProgressDialog(ChatActivity.this,
					getString(R.string.wait));
			dlg.show();
		}

		LeaveClubTask task = new LeaveClubTask(ChatActivity.this,
				Integer.toString(myClubId));
		task.execute();
	}

	public void stopLeaveClub(boolean result) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}

		String notice = getString(result ? R.string.leave_club_success
				: R.string.leave_club_fail);
		Toast.makeText(ChatActivity.this, notice, Toast.LENGTH_SHORT).show();

		if (result) {
			GgApplication.getInstance().setCurChatRoomId(GgApplication.CUR_CHAT_ROOM_NONE);
			
			getIntent().putExtra(ChatConsts.FINISH_LEAVE_CLUB, 1);
			loaderHandler.removeCallbacks(runtimeDetailLoader);
			setResult(RESULT_OK, getIntent());
			finish();
		}
	}

	private void confirmCancelGame() {
		AlertDialog dialog;
		dialog = new AlertDialog.Builder(ChatActivity.this)
				.setTitle(R.string.exit_game)
				.setMessage(R.string.exit_game_conf)
				.setPositiveButton(R.string.ok,
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog, int item) {
								selectCancelGameType();
							}
						})
				.setNegativeButton(R.string.cancel,
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog, int item) {
								dialog.dismiss();
							}
						}).create();

		dialog.show();
	}
	
	private int selExitType;
	
	private void selectCancelGameType() {
		String[] exitType = {
				getString(R.string.discuss_exit),
				getString(R.string.force_exit)
				};
		selExitType = 0;
		
		AlertDialog dialog;
		dialog = new AlertDialog.Builder(ChatActivity.this)
			.setTitle(R.string.exit_game_title)
			.setCancelable(true)
			.setSingleChoiceItems(exitType, selExitType, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int item) {
					selExitType = item;
				}
			})
			.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int item) {
					dlgExitCause();
				}
			}).create();
		dialog.show();
	}
	
	private String strExitCause;
	private void dlgExitCause() {
		strExitCause = "";
		final View dlg_view;
		LayoutInflater mInflater = LayoutInflater.from(ChatActivity.this); 
		dlg_view = mInflater.inflate(R.layout.dlg_exit_game_cause, null);
		
		AlertDialog dialog;
		final TextView tv_exitCause = (TextView)dlg_view.findViewById(R.id.str_cause);
		
		dialog = new AlertDialog.Builder(ChatActivity.this)
		.setTitle(getString(R.string.exit_game_cause_title))
		.setView(dlg_view)
		.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int arg1) {
				strExitCause = tv_exitCause.getText().toString();
				startCancelGame(true);
			}
		}).create();
		dialog.show();
	}

	public void startCancelGame(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(ChatActivity.this))
			return;

		if (showdlg) {
			dlg = new GgProgressDialog(ChatActivity.this,
					getString(R.string.wait));
			dlg.show();
		}

		CancelGameTask task = new CancelGameTask(ChatActivity.this,
				Integer.toString(myClubId), Integer.toString(gameId), strExitCause, Integer.toString(selExitType));
		task.execute();
	}

	public void stopCancelGame(int result) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (result == 1 || result == 6) {
			String msg = "";
			if (result == 1)
				msg = "对不起，我要退赛。 如您同意协议退赛， 请选择协议退赛！\r\n";
			else
				msg = "对不起，我要退赛。\r\n";
			msg = msg.concat(strExitCause);
			String time = GgApplication.getInstance().getCurServerTime();
			
			boolean sent = chatEngine.sendMessage(msg, ChatConsts.MSG_TEXT, curRoomId, time, true);
			
			curUserName = GgApplication.getInstance().getUserName();
			
			ChatEntity histItem = new ChatEntity(curUserId, curUserName,
					time, msg, ChatConsts.MSG_TEXT,
					true, GgApplication.getInstance().getUserPhoto(), sent);
			adapter.addData(histItem);
			adapter.notifyDataSetChanged();

			lvChatHistory.setSelection(lvChatHistory.getCount() - 1);
			
			otherPanel.setVisibility(View.GONE);
		}

		String notice = getString(R.string.exit_game_fail);
		if (result == 1)
			notice = getString(R.string.exit_game_req_success);
		else if (result == 2)
			notice = getString(R.string.exit_game_req_success_exist);
		else if (result == 3)
			notice = getString(R.string.exit_game_success);
		else if (result == 5)
			notice = getString(R.string.already_exit_game);
		else if (result == 6)
			notice = getString(R.string.exit_game_force_success);
		else if (result == 7)
			notice = getString(R.string.exit_game_time_limit);
		Toast.makeText(ChatActivity.this, notice, Toast.LENGTH_SHORT).show();
	}

	@Override
	public void callback(MOHttpResponse res) {

		Log.d("upload response", res.toString());

		int status = res.getStatus();
		String resultStr = null;

		switch (status) {

		case MOHttpResponse.STATUS_SUCCESS:

			if (res.getResultDataString() != null) {
				resultStr = res.getResultDataString();
				JSONObject json_response;
				try {
					json_response = new JSONObject(resultStr);

					int success = json_response.getInt("success");
					if (success == 0) {
						Log.d("call back func", "success  =  0");
					} else {
						String server_file_path = json_response
								.getString("server_file_path");
						String server_file_name = json_response.getString("server_file_name");

						// emit socket request to server by using the node.js
						JSONObject json = new JSONObject();

						try {
							json.put("sender_id", curUserId);
							json.put("server_path", server_file_path);
							if(msg_type == 1)
								json.put("msg", server_file_name);
							else if(msg_type == 2)
								json.put("msg", server_file_name);
							json.put("room_id", curRoomId); // clubId should
															// change to RoomId
															// @@@@@@@@@@
							json.put("sender_photo", GgApplication.getInstance().getUserPhoto());
						} catch (JSONException e) {
							e.printStackTrace();
						}
						Log.d("img_chat", json.toString()); 

						if (chatEngine.getSocketIO() != null) {
							Log.d("img_chat_request",
									"socket is already initialized");
							if(msg_type == 1)
								chatEngine.getSocketIO().emit(
									ChatEngine.SEND_IMG_CHAT, json);
							else if(msg_type == 2)
								chatEngine.getSocketIO().emit(ChatEngine.SEND_AUD_CHAT, json);
						} else {
							Log.d("img_chat_request", "socket is now creating");
							chatEngine.createSocketIOManager();
							chatEngine.netConnect();
							if(msg_type == 1)
								chatEngine.getSocketIO().emit(ChatEngine.SEND_IMG_CHAT, json);
							else if(msg_type == 2)
								chatEngine.getSocketIO().emit(ChatEngine.SEND_AUD_CHAT, json);
						}

					}
					
				} catch (Exception e) {
					Log.d("Exception occured", e.toString());
				}
			}

			break;
		case MOHttpResponse.STATUS_FAILED:
			Log.d("upload_response", "failed");
			break;
		case MOHttpResponse.STATUS_CANCELLED:
			Log.d("upload_response", "canceled");
			break;
		case MOHttpResponse.STATUS_UNKNOWN:
			Log.d("upload_response", "unknown");
			break;
		default:
			break;
		}
		
		msg_type = 0;
	}
	
	public boolean onTouchEvent(View view, MotionEvent event) {
		super.onTouchEvent(event);
		return true;
	}
		
	@Override
	public boolean dispatchTouchEvent(MotionEvent ev) {
		
		Rect rect = new Rect();
		popupMenu.getGlobalVisibleRect(rect);
		
		if (popupMenu != null && popupMenu.getVisibility() == View.VISIBLE && (ev.getX() < rect.left || (rect.top + rect.height()) < ev.getY())) {
			popupMenu.setVisibility(View.GONE);	
		}	
		super.dispatchTouchEvent(ev);
		return true;
	}
	public void fullview(View v) {
		xTextView tv = (xTextView)v;
		String msg = tv.getText().toString();
		
		if (isAudioMail(msg)) {
			if (m_vMailPlaying)
				return;
			m_vMailPlaying = true;
			audioPlayer.playSpeexAudioFile(msg);
		} else if(isImgMail(msg)) {
			Intent intent = new Intent(ChatActivity.this, ShowImageActivity.class);
			intent.putExtra("img_url", FileUtil.getFullPath(msg));
			intent.putExtra("display_option", "mail");
			startActivity(intent);
		} else {
			if(msg.contains("擂台")) {
				Intent intent = new Intent(ChatActivity.this, HomeActivity.class);
				intent.putExtra(CommonConsts.NOTIFY_TYPE, 2);
				startActivity(intent);
			} else if(msg.contains("我推荐这个球员")) {
				String[] strArray = msg.split("\r\n");
				String user_name = strArray[1];
				
				GetUserIDTask task = new GetUserIDTask(ChatActivity.this, user_name);
				task.execute();
			} else if(msg.contains("战书")) {
				Intent intent = new Intent(ChatActivity.this,
						ClubChallengesActivity.class);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, myClubId);
				intent.putExtra(CommonConsts.CHALL_TYPE_TAG,
						CommonConsts.CHALL_TYPE_ALL_PROCLAIM);
				intent.putExtra(CommonConsts.PROCLAIM_START_TYPE, CommonConsts.FROM_CHAT);
				startActivity(intent);
			}
		}
		
		return;
	}
	
	public void stopGetUserID(String datas) {

		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (StringUtil.isEmpty(datas)) {
			Toast.makeText(ChatActivity.this, getString(R.string.get_user_club_setting_fail), Toast.LENGTH_SHORT).show();
			return;
		}
		
		int userID = -1;
		userID = Integer.parseInt(datas);
		Intent intent;
		intent = new Intent(ChatActivity.this, ProfileActivity.class);
		intent.putExtra("user_id", userID);
		if (userID == Integer.valueOf(GgApplication.getInstance().getUserId()))
			intent.putExtra("type", CommonConsts.EDIT_PROFILE);
		else {
			intent.putExtra("type", CommonConsts.SHOW_PROFILE);
		}
		intent.putExtra("from", CommonConsts.FROM_INVITE);
		startActivity(intent);
	}
	
	private boolean isAudioMail(String msg) {
		int pre_idx = msg.indexOf("audio_user");
		if (pre_idx != 0)
			return false;
		
		int suf_idx = msg.lastIndexOf(".gga");
		if (suf_idx != msg.length() - 4)
			return false;
		
		return true;
	}
	
	private boolean isImgMail(String msg) {
		int pre_idx = msg.indexOf("pic");
		if (pre_idx != 0)
			return false;
		
		int suf_idx = msg.lastIndexOf(".jpg");
		if (suf_idx != msg.length() - 4)
			return false;
		
		return true;
	}
	
	public void startBreakUpClub(boolean showdlg, Object[] param) {
		if (!NetworkUtil.isNetworkAvailable(ChatActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ChatActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		BreakUpClubTask task = new BreakUpClubTask(ChatActivity.this, param);
		task.execute();
	}
	
	public void stopBreakUpClub(int data) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (data == 1) {
			GgApplication.getInstance().getChatInfo().removeChatRooms(myClubId);
			GgApplication.getInstance().popClubID(String.valueOf(myClubId));
			
			Toast.makeText(ChatActivity.this, getString(R.string.breakup_success), Toast.LENGTH_LONG).show();
			getIntent().putExtra(CommonConsts.BREAKUP_CLUB, CommonConsts.BREAKED_CLUB);
			loaderHandler.removeCallbacks(runtimeDetailLoader);
			setResult(RESULT_OK, getIntent());
			finish();
		} else
			Toast.makeText(ChatActivity.this, getString(R.string.breakup_failed), Toast.LENGTH_LONG).show();
	}
	
	private BroadcastReceiver broadCastReceiver = new BroadcastReceiver() {

		@Override
		public void onReceive(Context context, Intent intent) {
			int msg = intent.getExtras().getInt("Message");
			if (msg == GgBroadCast.MSG_AUDIO_UP_FINISH) {
				SystemClock.sleep(3000);
				
				pro_dlg.dismiss();
				pro_dlg = null;
				
				String time = GgApplication.getInstance().getCurServerTime();
				boolean sent = chatEngine.sendMessage(audioMailName, ChatConsts.MSG_AUDIO, curRoomId, time, true);
				
				curUserName = GgApplication.getInstance().getUserName();
				
				// show the image_chat on your notation in the listView
				ChatEntity histItem = new ChatEntity(curUserId, curUserName,
						time, audioMailName, ChatConsts.MSG_AUDIO,
						true, GgApplication.getInstance().getUserPhoto(), sent);
				adapter.addData(histItem);
				
				adapter.notifyDataSetChanged();

				lvChatHistory.setSelection(lvChatHistory.getCount() - 1);
			}
		}
	};	
	
	@Override
	protected void onStop() {
		super.onStop();
		if (isFinishing()) {
			Log.d("onStop", "Finishing...");
			JPushInterface.clearAllNotifications(getApplicationContext());
			JPushInterface.stopPush(getApplicationContext());
		}
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		unregisterReceiver(broadCastReceiver);
		GgApplication.getInstance().homeActivity.reloadRunTimeDetail();
	}
}
