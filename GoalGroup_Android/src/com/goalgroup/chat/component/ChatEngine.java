package com.goalgroup.chat.component;


import java.io.File;
import java.util.ArrayList;
import java.util.Date;

import org.json.JSONObject;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.webkit.WebView.FindListener;
import android.widget.BaseAdapter;
import android.widget.RemoteViews;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.info.GgChatInfo;
import com.goalgroup.chat.info.history.ChatBean;
import com.goalgroup.chat.info.history.ChatHistoryDB;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.chat.io.socket.SocketIO;
import com.goalgroup.chat.io.socket.util.SocketIOManager;
import com.goalgroup.chat.util.ChatUtil;
import com.goalgroup.chat.util.UserFunctions;
import com.goalgroup.common.GgBroadCast;
import com.goalgroup.constants.AddrConst;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.ui.HomeActivity;
import com.goalgroup.ui.chat.EmoteUtil;
import com.goalgroup.ui.view.xTextView;
import com.goalgroup.utils.DateUtil;
import com.goalgroup.utils.FileUtil;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.BinaryHttpResponseHandler;
import com.loopj.android.http.GgHttpResponseHandler;

public class ChatEngine {
	
	static public final String GET_CHATHISTORY = "get_chathistory";
	static public final String GET_CHATHISTORY_RESPONSE = "get_chathistory_response";
	
	static public final String SEND_CHAT = "sendchat";
	static public final String SEND_IMG_CHAT = "send_img_chat";
	static public final String SEND_AUD_CHAT = "send_audio_chat";
	static public final String SEND_CREATE_ROOM = "create_room";
	static public final String UPDATE_CHAT = "updatechat";
	static public final String UPDATE_IMG_CHAT = "update_img_chat";
	static public final String UPDATE_AUD_CHAT = "update_audio_chat";
	static public final String REGISTER = "register";
	static public final String REGISTER_RESPONSE = "register_response";
	
	static public final String LOGIN = "login";
	static public final String LOGIN_RESPONSE = "login_response";
	
	static public final String LOGOUT = "logout";
	static public final String LOGOUT_RESPONSE = "logout_response";

	static public final String TAG = ChatEngine.class.getSimpleName();
	
	static private int NOT_SENT = 0; 

	static public ChatService chatService = null;
	
	static public BaseAdapter adapter = null;
	static private ChatBaseActivity runActivity = null;
	
	static public final int DISPLAY_UNIT = 10;

	static int MyID = -1000;
	static String MyName = null;
	static public int MyRoomID = -1000;
	
	private static NotificationManager notifyManager;

	static public final int REQUEST = 1;
	static public final int REQUESTED = 2;

	private SocketIOManager socketIOManager = null;
	private SocketIO socketIO = null;
	private ChatHistoryDB historyDB;
	private GgChatInfo ggChatInfo;
	
	private ArrayList<ChatBean> tmp_msgs;
	
	static public boolean connect_flag = false;
	static public boolean socketerr_flag = false;

	public static String CHAT_URL = "http://" + AddrConst.CHAT_SERVER_ADDR + ":1931/";
	public static String BASE_URL = "http://" + AddrConst.WEB_SERVER_ADDR + ":9600/goalsrv/api";
	
//	public static String PHOTO_BASE_URL = Environment.getExternalStorageDirectory() + "/GoalGroup/Chat/Photoes/";
	
	public static int FILE_MAX_SIZE = 5000000;
	
	private final Context ctx;
	
	private static String download_filename;
	
	public ChatEngine(Context ctx) {
		this.ctx = ctx;
	}
	
	static public void setRunningActivity(ChatBaseActivity activity) {
		runActivity = activity;
	}

	static public Activity getRunningActivity() {
		return runActivity;
	}	
	
	public void createSocketIOManager() {	
		socketIOManager = new SocketIOManager(mHandler);
		socketIOManager.disconnect();
	}
	
	public void netConnect() {
		if (socketIOManager == null)
			return;
		
		socketIO = socketIOManager.connect(CHAT_URL);
	}
	
	public SocketIO getSocketIO() {		
		return socketIO;
	}
	
	public SocketIOManager getSocketIOManager() {
		return socketIOManager;
	}
	
	public void disconnect() {
		if (socketIOManager == null)
			return;
		
		socketIOManager.disconnect();
		socketIO = null;
	}
	
	public boolean onConnectState() {
		if (socketIOManager != null)
			return socketIOManager.onConnectState();
		return false;
	}
	
	public static void setMyID(int id) {
		MyID = id;
	}
	
	public static int getMyID() {
		return MyID;
	}
	
	public static void setMyName(String name) {
		MyName = name;
	}
	
	public static String getMyName() {
		return MyName;
	}

	public Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case SocketIOManager.SOCKETIO_DISCONNECT:
                    Log.i(TAG, "SOCKETIO_DISCONNECT");
                    connect_flag = false;
                   
                    break;
                case SocketIOManager.SOCKETIO_CONNECT:
                    Log.i(TAG, "SOCKETIO_CONNECT");
                    connect_flag = true;
                    final Handler loaderHandler = new Handler();
                	final Runnable runtimeDetailLoader = new Runnable() {
                		
                		@Override
                		public void run() {
                			// TODO Auto-generated method stub
                			ggChatInfo = GgApplication.getInstance().getChatInfo();
                    		if (ggChatInfo != null) {
                    			historyDB = ggChatInfo.getChatHistDB();
                    			if (historyDB == null)
                    				return;
        	                    tmp_msgs = historyDB.fetchMsgs(NOT_SENT);
        	                    for (ChatBean tmp_msg : tmp_msgs) {
        	                    	ChatEngine.this.sendTmpMessage(tmp_msg.getID(), tmp_msg.getMsg().toString(), 
        	                    			tmp_msg.getType(), 
        	                    			tmp_msg.getRoomId(),
        	                    			tmp_msg.getTime().toString(),
        	                    			true);
        	                    }
                    		}
                		}
                	};
                	loaderHandler.postDelayed(runtimeDetailLoader, 5000);
                    
                    break;
                case SocketIOManager.SOCKETIO_HERTBEAT:
                    Log.i(TAG, "SOCKETIO_HERTBEAT");
                    
                    break;
                case SocketIOManager.SOCKETIO_MESSAGE:
                    Log.i(TAG, "SOCKETIO_MESSAGE");
                   
                    break;
                case SocketIOManager.SOCKETIO_JSON_MESSAGE:
                	String temp = (String)(msg.obj);
					JSONObject json = null;
				
					try {
						json = new JSONObject(temp);
						Log.d(TAG, json.getString("event"));
						
						String message;
						String eventStr = json.getString("event");
						int msgType = ChatConsts.MSG_TEXT;
						if (ChatEngine.UPDATE_IMG_CHAT.equals(eventStr)) {
							msgType = ChatConsts.MSG_IMAGE;
							message = json.getString("image_name");
						} else if (ChatEngine.UPDATE_AUD_CHAT.equals(eventStr)) {
							msgType = ChatConsts.MSG_AUDIO;
							message = json.getString("audio_name");
						} else {
							message = json.getString("msg");
							String newMsg = "";
							int len = message.length();
							for (int i = 0; i < len; i++) {
								if (message.charAt(i) == '`') {
									int next = message.indexOf("`", i + 1);
									String idstr = message.substring(i, next+1);

									int index = StringUtil.findIDfromArray(EmoteUtil.emoArgs, idstr);
									String str = "╬" + EmoteUtil.emoImageIDs[index] + "╬";

									newMsg = newMsg + str;

									i = next;
								} else {
									newMsg = newMsg + message.charAt(i);
								}
							}
							message = newMsg;
						}					
						
						if (checkNewDiscussRoom(message) || 
							updateDiscussRoom(message)) {
							break;
						}						
						
						int cur_user_id = Integer.valueOf(GgApplication.getInstance().getUserId());
						int sender_id = json.getInt("sender_id");
						
						if (cur_user_id == sender_id)
							break;
						
						String sender_name = json.getString("sender_name");
						String time = json.getString("send_time"); // /////////////////////new
						int room_id = json.getInt("room_id");
						String sender_photo = json.getString("sender_photo");
						
						int curChatRoomId = GgApplication.getInstance().getCurChatRoomId();
						if (runActivity != null && 
							curChatRoomId != GgApplication.CUR_CHAT_ROOM_NONE && curChatRoomId == room_id) {
							runActivity.setUpdate(json);
							break;
						}

						time = DateUtil.completeDatetTime(time);
						GgApplication.getInstance().getPrefUtil().setLastChatTime(time);
						
						File dir = new File(FileUtil.getFullPath(""));
						if (!dir.exists() && !dir.mkdirs()) {
							break;
						}
						
						if (msgType == ChatConsts.MSG_IMAGE) {							
							download_filename = "pic_down_" + GgApplication.getInstance().getUserId() + "_";
							
							long now = System.currentTimeMillis();
							String nowMilliSecString = String.valueOf(now);
							download_filename = download_filename.concat(nowMilliSecString);
							download_filename = download_filename.concat(".jpg");
							
							AsyncHttpClient httpIMGClient = new AsyncHttpClient();
							httpIMGClient.setTimeout(10000);
							String[] allowContents = { "image/jpeg", "image/bmp", "image/png" };

							httpIMGClient.get(message, new BinaryHttpResponseHandler(allowContents) {
								
								@Override
								public void onSuccess(byte[] buffer) {
									FileUtil.writeFile(FileUtil.getFullPath(download_filename), buffer);
								}

								@Override
								public void onFailure(Throwable error, String content) {
								}
							});							
							
						}  else if (msgType == ChatConsts.MSG_AUDIO) {
							download_filename = "audio_user_" + GgApplication.getInstance().getUserId() + "_";
							
							long now = System.currentTimeMillis();
							String nowMilliSecString = String.valueOf(now);
							download_filename = download_filename.concat(nowMilliSecString);
							download_filename = download_filename.concat(".gga");
							
							AsyncHttpClient httpIMGClient = new AsyncHttpClient();
							httpIMGClient.setTimeout(10000);
							httpIMGClient.get(message, new GgHttpResponseHandler() {
								
								@Override
								public void onSuccess(byte[] buffer) {									
									FileUtil.writeFile(FileUtil.getFullPath(download_filename), buffer);
								}

								@Override
								public void onFailure(Throwable error, String content) {
								}
							});
						}
						
						message = (message.endsWith("jpg") || message.endsWith("gga")) ? download_filename : message;
						updateMsgHistory(message, msgType, room_id, sender_name, sender_id, 
								time, sender_photo, false, true);
						
						GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();						
						ChatRoomInfo room = chatInfo.getChatRoom(room_id);
						
						if (room != null) {
							room.incUnreadCount();
							GgApplication.getInstance().getChatEngine().showNotification(room.getRoomType(), sender_name, message, room_id);
						}
					} catch (org.json.JSONException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					
                    break;
                case SocketIOManager.SOCKETIO_EVENT:
                    Log.i(TAG, "SOCKETIO_EVENT");
                   
                    break;
                case SocketIOManager.SOCKETIO_ERROR:
                    Log.i(TAG, "SOCKETIO_ERROR");
                    connect_flag = false;
                    
                    ChatEngine chatEngine = GgApplication.getInstance().getChatEngine();
                    chatEngine.getSocketIOManager().disconnect();
                    
                    ((ChatBaseActivity)getRunningActivity()).prsDlgDismiss();
//                    Toast.makeText(getRunningActivity(), "无法聊天网格连接。", Toast.LENGTH_LONG).show();
//                    if (runActivity != null) {
//                    	runActivity.finish();
//                    }
                    
                    break;
                case SocketIOManager.SOCKETIO_ACK:
                    Log.i(TAG, "SOCKETIO_ACK");
                   
                    break;
                default:
                	break;
            }
        }
    };

    @SuppressWarnings("deprecation")
	public static String makeDateTime() {
		Date date = new Date();
		String strDate = "";
		strDate = String.valueOf(date.getYear() + 1900) + "-";
		if (date.getMonth() + 1 < 10)
			strDate = strDate + "0" + String.valueOf(date.getMonth() + 1) + "-";
		else
			strDate = strDate + String.valueOf(date.getMonth() + 1) + "-";
		if (date.getDate() < 10)
			strDate = strDate + "0" + String.valueOf(date.getDate()) + " ";
		else
			strDate = strDate + String.valueOf(date.getDate()) + " ";
		if (date.getHours() < 10)
			strDate = strDate + "0" + String.valueOf(date.getHours()) + ":";
		else
			strDate = strDate + String.valueOf(date.getHours()) + ":";
		if (date.getMinutes() < 10)
			strDate = strDate + "0" + String.valueOf(date.getMinutes()) + ":";
		else
			strDate = strDate + String.valueOf(date.getMinutes()) + ":";
		if (date.getSeconds() < 10)
			strDate = strDate + "0" + String.valueOf(date.getSeconds());
		else
			strDate = strDate + String.valueOf(date.getSeconds());
		return strDate;
	}
    
	static void autoLogOut() {
	}
	
	public void setNotificationManager(NotificationManager value) {
		notifyManager = value;
	}
	
	public NotificationManager getNotificationManager() {
		return notifyManager;
	}
	
	public void showNotification(int room_type, String from, String msg, int room_id) {
		xTextView notifyMsg;
		RemoteViews notifyView = new RemoteViews(GgApplication.getInstance().getBaseContext().getPackageName(), 
				R.layout.notify_view);
		notifyView.setTextViewText(R.id.notify_from, from);
		String showMsg = ChatUtil.getMsgTypeStr("", msg);

		notifyView.setTextViewText(R.id.notify_msg, showMsg);
		
		Intent intent = new Intent(GgApplication.getInstance(), HomeActivity.class);
		intent.putExtra(CommonConsts.NOTIFY_TYPE, room_type);
		intent.putExtra(CommonConsts.NOTIFY_ROOM_ID, room_id);
		intent.putExtra(CommonConsts.NOTIFY_CONTENT, showMsg);
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
		
		PendingIntent contentIntent = PendingIntent.getActivity(GgApplication.getInstance(), 0,
				intent, PendingIntent.FLAG_UPDATE_CURRENT);
		
		Notification notify = new Notification(R.drawable.ic_launcher, "没读的新聊天信息收到。", System.currentTimeMillis());
		notify.flags = Notification.FLAG_ONGOING_EVENT;
		notify.contentView = notifyView;		
		notify.contentIntent = contentIntent;
		notifyManager.notify(CommonConsts.NOTIFY_ID, notify);
		
		GgApplication.getInstance().setLastNotifyRoomType(room_type);
		GgApplication.getInstance().getBroadCaster().send(GgBroadCast.MSG_UNREAD_MESSAGE);
	}
	
	public void hideNotification() {
		notifyManager.cancel(CommonConsts.NOTIFY_ID);
	}
	
	public boolean isNewDiscussRoom(String msg) {
		if (msg.indexOf("create new discuss room") != 0)
			return false;
		
		String[] items = msg.split(",");
		if (items == null || items.length != 3)
			return false;
		
		return true;
	}
	
	private boolean checkNewDiscussRoom(String msg) {
		if (!isNewDiscussRoom(msg))
			return false;
		
		String[] items = msg.split(",");
		
		int room_id = Integer.parseInt(items[1].substring(8)); // "room_id=".length() - 1)
		String room_title = items[2].substring(11); // "room_title=".length() - 1 
		ChatRoomInfo room = new ChatRoomInfo(room_id, room_title);
		room.getRoomInfoByTitle(room_title);
		MyClubData myClubData = new MyClubData();
		int[] clubIds = myClubData.getOwnerClubIDs();
		for (int i = 0; i < clubIds.length; i++)
			if (clubIds[i] == room.getClubId01()
				|| clubIds[i] == room.getClubId02()) {
				GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
				chatInfo.addDiscussChatRoom(room_id, room_title);
				return true;
			}
		
		return false;
	}
	
	public boolean isUpdateDiscussRoom(String msg) {
		if (msg.indexOf("update discuss room") != 0)
			return false;
		
		String[] items = msg.split(",");
		if (items == null || items.length != 3)
			return false;
		
		return true;
	}
	
	private boolean updateDiscussRoom(String msg) {
		if (!isUpdateDiscussRoom(msg))
			return false;
		
		String[] items = msg.split(",");
		
		int room_id = Integer.parseInt(items[1].substring(8)); // "room_id=".length() - 1)
		String room_title = items[2].substring(11); // "room_title=".length() - 1 
		
		GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
		ChatRoomInfo room = chatInfo.getChatRoom(room_id);
		
		if (room == null) {
			return false;
		}
		
		room.getRoomInfoByTitle(room_title);
		
		return true;
	}
	
	private UserFunctions userFunctions = null;
	
	public void sendCreateNewDiscussRoom(int room_id, String room_title) {		
		int cur_user_id = Integer.valueOf(GgApplication.getInstance().getUserId());
		
		String time = GgApplication.getInstance().getCurServerTime();
		
		String msg = "create new discuss room";
		msg = msg.concat(",room_id=");
		msg = msg.concat(Integer.toString(room_id));
		msg = msg.concat(",room_title=");
		msg = msg.concat(room_title);
		
		sendMessage(msg, ChatConsts.MSG_TEXT, room_id, time, false);
		
		msg = "我们会议吧。";
		sendMessage(msg, ChatConsts.MSG_TEXT, room_id, time, true);
	}
	
	public void updateDiscussRoom(int room_id, String room_title) {
		int cur_user_id = Integer.valueOf(GgApplication.getInstance().getUserId());
		
		String time = GgApplication.getInstance().getCurServerTime();
		
		String msg = "update discuss room";
		msg = msg.concat(",room_id=");
		msg = msg.concat(Integer.toString(room_id));
		msg = msg.concat(",room_title=");
		msg = msg.concat(room_title);
		
		sendMessage(msg, ChatConsts.MSG_TEXT, room_id, time, false);
	}
	
	public boolean sendTmpMessage(int msg_id, String msg, int msgType, int roomId, String time, boolean remainDB) {
		int userId = Integer.parseInt(GgApplication.getInstance().getUserId());
		
		if (!connect_flag) {
			return connect_flag;
		}
		
		if (userFunctions == null) {
			userFunctions = new UserFunctions();		
		}
		
		switch (msgType) {
		case ChatConsts.MSG_TEXT:
			if (isNewDiscussRoom(msg)||isUpdateDiscussRoom(msg))
				remainDB = false;
			String newMsg = "";
			int len = msg.length();
			for (int i = 0; i < len; i++) {
				if (msg.charAt(i) == '╬') {
					int next = msg.indexOf("╬", i + 1);
					String idstr = msg.substring(i + 1, next);
					int id = Integer.parseInt(idstr);

					int index = StringUtil.findIDfromArray(EmoteUtil.emoImageIDs, id);
					String str = EmoteUtil.emoArgs[index];

					newMsg = newMsg + str;

					i = next;
				} else {
					newMsg = newMsg + msg.charAt(i);
				}
			}
			userFunctions.sendMessage(newMsg, roomId);
			break;
		case ChatConsts.MSG_IMAGE:
			userFunctions.sendImageChat(msg, userId, roomId);
			break;
		case ChatConsts.MSG_AUDIO:
			if (!userFunctions.sendAudioChat(msg, userId, roomId))
				return false;
		}
		
		if (!remainDB)
			return true;
		
		updateMsgState(msg_id);
		return connect_flag;
	}
	
	public boolean sendMessage(String msg, int msgType, int roomId, String time, boolean remainDB) {
		
		boolean result = false;
		
		String curUserName = GgApplication.getInstance().getUserName();
		String photoURL = GgApplication.getInstance().getUserPhoto();
		int userId = Integer.parseInt(GgApplication.getInstance().getUserId());
		
		if (!connect_flag) {
			updateMsgHistory(msg, msgType, roomId, curUserName, userId, time, photoURL, true, false);
			return connect_flag;
		}
		
		if (userFunctions == null) {
			userFunctions = new UserFunctions();		
		}
		
		switch (msgType) {
		case ChatConsts.MSG_TEXT:
			String newMsg = "";
			int len = msg.length();
			for (int i = 0; i < len; i++) {
				if (msg.charAt(i) == '╬') {
					int next = msg.indexOf("╬", i + 1);
					String idstr = msg.substring(i + 1, next);
					int id = Integer.parseInt(idstr);

					int index = StringUtil.findIDfromArray(EmoteUtil.emoImageIDs, id);
					String str = EmoteUtil.emoArgs[index];

					newMsg = newMsg + str;

					i = next;
				} else {
					newMsg = newMsg + msg.charAt(i);
				}
			}
			userFunctions.sendMessage(newMsg, roomId);
			result = true;
			break;
		case ChatConsts.MSG_IMAGE:
			userFunctions.sendImageChat(msg, userId, roomId);
			result = true;
			break;
		case ChatConsts.MSG_AUDIO:
			result = userFunctions.sendAudioChat(msg, userId, roomId);
			break;
		}
		
		if (!remainDB)
			return true;
		
		updateMsgHistory(msg, msgType, roomId, curUserName, userId, time, photoURL, true, true);
		
		return result;
	}
	
	public void updateMsgHistory(String msg, int msgType, int roomId, String userName, int userId, String time, String photoURL, boolean isMine, boolean isSent) {
		ChatBean newChat = new ChatBean();
		newChat.setMsg(msg);
		newChat.setRoomId(roomId);
		newChat.setBuddy(userName);
		newChat.setTime(time);
		newChat.setType(msgType);
		newChat.setIsMine(isMine ? 1 : 0);
		newChat.setUserID(userId);
		newChat.setBuddyPhoto(photoURL);
		newChat.setIsSent(isSent ? 1 : 0);
		
		GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
		
		if (null == chatInfo) return;
		
		chatInfo.getChatHistDB().addMsg(newChat);
		chatInfo.setLastChatContent(roomId, userName, msg, time);
	}
	
	public void updateMsgState(int id) {
		GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
		chatInfo.getChatHistDB().updateState(id);
	}
	
	public boolean getConnectFlag() {
		return connect_flag;
	}

}
