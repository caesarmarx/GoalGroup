package com.goalgroup.model;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.goalgroup.chat.component.ChatEngine;


public class ClubChattingDbAdapter {
	
	public static final String KEY_ID = "id";
	public static final String KEY_SENDER_ID = "sender_id";
	public static final String KEY_SENDER_NAME = "sender_name";
	public static final String KEY_MSG = "msg";
	public static final String KEY_ROOM_ID = "room_id";
	public static final String KEY_SEND_TIME = "send_time";
	public static final String KEY_ROOM_MEMBERS_NAME_LIST = "room_name";
	public static final String KEY_USER_ID = "user_id";
	public static final String KEY_USER_NAME = "user_name";
	
	public static final String DATABASE_NAME = "club_chatting";
	public static final int DATABASE_VERSION = 1;
	
	public static final String MESSAGES_TABLE = "messages";
	public static final String ROOMS_TABLE = "rooms";
	public static final String ROOMS_REF_TABLE = "rooms_ref";
	public static final String USERS_TABLE = "users";

	static final String CREATE_USERS_TABLE_QUERY = "CREATE TABLE IF NOT EXISTS "+USERS_TABLE+" (`id` INTEGER PRIMARY KEY AUTOINCREMENT, "+KEY_USER_ID+" INTEGER NOT NULL DEFAULT '0', "+KEY_USER_NAME+" TEXT NOT NULL DEFAULT '');";
	static final String CREATE_ROOMS_TABLE_QUERY = "CREATE TABLE IF NOT EXISTS "+ROOMS_TABLE+" (`id` INTEGER PRIMARY KEY AUTOINCREMENT, "+KEY_ROOM_MEMBERS_NAME_LIST+" TEXT NOT NULL DEFAULT '', "+KEY_ROOM_ID+" INTEGER NOT NULL DEFAULT '0', "+KEY_SEND_TIME+" DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00');";
	static final String CREATE_ROOMS_REF_TABLE_QUERY = "CREATE TABLE IF NOT EXISTS "+ROOMS_REF_TABLE+" (`id` INTEGER PRIMARY KEY AUTOINCREMENT, "+KEY_ROOM_ID+" INTEGER NOT NULL DEFAULT '0', "+KEY_USER_ID+" INTEGER NOT NULL DEFAULT '0');";
	static final String CREATE_MESSAGES_TABLE_QUERY = "CREATE TABLE IF NOT EXISTS "+MESSAGES_TABLE+" (`id` INTEGER PRIMARY KEY AUTOINCREMENT, "+KEY_SENDER_ID+" INTEGER NOT NULL DEFAULT '0', "+KEY_MSG+" TEXT NOT NULL DEFAULT '', "+KEY_ROOM_ID+" INTEGER NOT NULL DEFAULT '0', "+KEY_SEND_TIME+" DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00');";
	
	static final String DROP_MESSAGES_TABLE_QUERY = "DROP TABLE IF EXISTS "+MESSAGES_TABLE;
	static final String DROP_ROOMS_TABLE_QUERY = "DROP TABLE IF EXISTS "+ROOMS_TABLE;
	static final String DROP_ROOMS_REF_TABLE_QUERY = "DROP TABLE IF EXISTS "+ROOMS_REF_TABLE;
	static final String DROP_USERS_TABLE_QUERY = "DROP TABLE IF EXISTS "+USERS_TABLE;
	
	final Context context;
			
	DatabaseHelper DBHelper;
			
	SQLiteDatabase db;
	
	
	public ClubChattingDbAdapter(Context ctx) {
		this.context = ctx;
		DBHelper = new DatabaseHelper(context);
	}
	
	private static class DatabaseHelper extends SQLiteOpenHelper {
		
		public DatabaseHelper(Context context) {
			super(context, DATABASE_NAME, null, DATABASE_VERSION);
		}
		
		public void onCreate(SQLiteDatabase db) {
			try {
				db.execSQL(CREATE_USERS_TABLE_QUERY);			
				db.execSQL(CREATE_ROOMS_TABLE_QUERY);
				db.execSQL(CREATE_ROOMS_REF_TABLE_QUERY);
				db.execSQL(CREATE_MESSAGES_TABLE_QUERY);
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		
		public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
			db.execSQL(DROP_MESSAGES_TABLE_QUERY);
			db.execSQL(DROP_ROOMS_TABLE_QUERY);
			db.execSQL(DROP_ROOMS_REF_TABLE_QUERY);
			db.execSQL(DROP_USERS_TABLE_QUERY);
			onCreate(db);
		}
	}
	
	public ClubChattingDbAdapter open() throws SQLException {
		db = DBHelper.getWritableDatabase();
		return this;
	}
	
	public void close() {
		DBHelper.close();
	}
	
	
	/*
	 * Query methods against "users" table ...
	 */
	public Cursor getAllUsers() {
		String query = "SELECT * FROM "+USERS_TABLE+" ORDER BY id ASC";
		return db.rawQuery(query, null);
	}
	
	public long insertUser(int user_id, String user_name) {
		ContentValues initialValue = new ContentValues();
		
		initialValue.put(KEY_USER_ID, user_id);
		initialValue.put(KEY_USER_NAME, user_name);
		
		return db.insert(USERS_TABLE, null, initialValue);
	}
	
	public String getUserName(int user_id) {
		String query = "SELECT user_name FROM `users` WHERE user_id="+user_id;
		
		Cursor cursor = db.rawQuery(query,  null);
		if (cursor == null)
			return "";
		if (!cursor.moveToFirst())
			return "";
		
		return cursor.getString(cursor.getColumnIndexOrThrow("user_name"));
	}
	
	/*
	 * Query methods against "rooms_ref" table ...
	 */
	public Cursor getAllRoomRefs() {
		String query = "SELECT * FROM "+ROOMS_REF_TABLE+" ORDER BY id ASC";
		return db.rawQuery(query, null);
	}
	
	public long insertRoomsRefs(int room_id, int user_id) {
		ContentValues initialValue = new ContentValues();
		
		initialValue.put(KEY_ROOM_ID, room_id);
		initialValue.put(KEY_USER_ID, user_id);
		
		return db.insert(ROOMS_REF_TABLE, null, initialValue);
	}
	
	/*
	 * Query methods against "messages" table ...
	 */
	public Cursor getAllMessages() {
		return db.query(MESSAGES_TABLE, new String[] {KEY_ID, KEY_SENDER_ID, KEY_SENDER_NAME, KEY_MSG, KEY_ROOM_ID, KEY_SEND_TIME}, null, null, null, null, null);
	}
	
	public long insertMsg(int sender_id, String msg, int room_id, String send_time) {
		ContentValues initialValue = new ContentValues();
		
		initialValue.put(KEY_SENDER_ID, sender_id);
		initialValue.put(KEY_MSG, msg);
		initialValue.put(KEY_ROOM_ID, room_id);
		initialValue.put(KEY_SEND_TIME, send_time);

		return db.insert(MESSAGES_TABLE, null, initialValue);
	}
	
	public Cursor getMessagesInRoomWithUnit(int room_id, int page_index) {
		int start_index = page_index * ChatEngine.DISPLAY_UNIT;
		String query = "SELECT m.*, u.user_name FROM (SELECT * FROM "+MESSAGES_TABLE+" WHERE room_id="+room_id+" ORDER BY send_time ASC LIMIT "+start_index+", "+ChatEngine.DISPLAY_UNIT+") m, "+USERS_TABLE+" u WHERE m.sender_id=u.user_id";
		return db.rawQuery(query, null);
	}
	
	/*
	 * Query methods against "rooms" table ...
	 */
	public String getLatestTimeForRoom(int room_id) {
		String query = "SELECT "+KEY_SEND_TIME+" FROM "+MESSAGES_TABLE+" WHERE "+KEY_ROOM_ID+"="+room_id+" ORDER BY send_time DESC LIMIT 0,1";
		Cursor cursor = db.rawQuery(query, null);
		if (cursor == null)
			return "";
		
		if (!cursor.moveToFirst())
			return "";
		
		String datetime_str = cursor.getString(cursor.getColumnIndexOrThrow(KEY_SEND_TIME));
		
		return datetime_str;
	}
	
	public String getLatestTime() {
		String query = "SELECT "+KEY_SEND_TIME+" FROM "+MESSAGES_TABLE+" ORDER BY "+KEY_SEND_TIME+" DESC LIMIT 0,1";
		Cursor cursor = db.rawQuery(query, null);
		if (cursor == null)
			return "";
		
		if (!cursor.moveToFirst())
			return "";
		
		String datetime_str = cursor.getString(cursor.getColumnIndexOrThrow(KEY_SEND_TIME));
			
		return datetime_str;
	}
	
	public Cursor getAllRooms() {
		String query = "SELECT * FROM "+ROOMS_TABLE+" ORDER BY send_time DESC";
		return db.rawQuery(query, null);
	}
	
	public Cursor getRoomsWithUnit(int page_index) {
		int start_index = page_index * ChatEngine.DISPLAY_UNIT;
		String query = "SELECT * FROM "+ROOMS_TABLE+" ORDER BY send_time DESC LIMIT "+start_index+","+ChatEngine.DISPLAY_UNIT;
		return db.rawQuery(query, null);
	}
	
	public long insertRoom(String room_members_name_list, int room_id) {
		ContentValues initialValue = new ContentValues();
		
		String latest_time = getLatestTimeForRoom(room_id);
		
		initialValue.put(KEY_ROOM_MEMBERS_NAME_LIST, room_members_name_list);
		initialValue.put(KEY_ROOM_ID, room_id);
		initialValue.put(KEY_SEND_TIME, latest_time);
		
		return db.insert(ROOMS_TABLE, null, initialValue);
	}
	
	public void updateLatestTimeForAllRooms() {
		Cursor cursor = getAllRooms();
		if (cursor == null)
			return;
		
		if (!cursor.moveToFirst())
			return;
		
		int room_id;
		do {
			room_id = cursor.getInt(cursor.getColumnIndexOrThrow("room_id"));
			updateLatestTimeForRoom(room_id);
		} while (cursor.moveToNext());
	}
	
	public int updateLatestTimeForRoom(int room_id) {
		String send_time = getLatestTimeForRoom(room_id);
		
		ContentValues updatedValues = new ContentValues();
		updatedValues.put(KEY_SEND_TIME, send_time);
		
		String where = KEY_ROOM_ID + "=" + room_id;
		
		return db.update(ROOMS_TABLE, updatedValues, where, null);
	}
	
	public void updateRoomMemberListForAllRooms() {
		Cursor cursor = getAllRooms();
		if (cursor == null)
			return;
		
		if (!cursor.moveToFirst())
			return;
		
		int room_id;
		do {
			room_id = cursor.getInt(cursor.getColumnIndexOrThrow("room_id"));
			updateRoomMemberListForRoom(room_id);
		} while (cursor.moveToNext());
	}
	
	public int updateRoomMemberListForRoom(int room_id) {
		String member_list = getMemberListForRoom(room_id);
		
		ContentValues updatedValues = new ContentValues();
		updatedValues.put(KEY_ROOM_MEMBERS_NAME_LIST, member_list);
		
		String where = KEY_ROOM_ID + "=" + room_id;
		
		return db.update(ROOMS_TABLE, updatedValues, where, null);
	}
	
	public String getMemberListForRoom(int room_id) {
		
		String member_list_str = "";
		
		String query = "select u."+KEY_USER_NAME+" from "+ROOMS_REF_TABLE+" r_f, "+USERS_TABLE+" u where r_f."+KEY_USER_ID+"=u."+KEY_USER_ID+" and r_f."+KEY_ROOM_ID+"="+room_id;
		Cursor cursor = db.rawQuery(query, null);
		if (cursor == null)
			return "";
	
		if (!cursor.moveToFirst())
			return "";
		
		String room_name;
		do {
			room_name = cursor.getString(cursor.getColumnIndexOrThrow(KEY_USER_NAME));
			member_list_str = member_list_str + room_name + ",";
		} while (cursor.moveToNext());
		member_list_str = member_list_str.substring(0, member_list_str.length()-1);
		
		return member_list_str;
	}
	
	//
	public void saveUserRoomData(JSONArray user_array, JSONArray room_array, JSONArray ref_array) {		
		// Save user list to the 'users' table in a local sqlite database ...
		JSONObject user;
		int count = user_array.length();
		int user_id;
		String user_name;
		for (int i=0; i<count; i++) {
			try {
				user = user_array.getJSONObject(i);
				
				user_id = user.getInt("user_id");
				user_name = user.getString("user_name");
				
				insertUser(user_id,  user_name);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		// Save room list to the 'rooms' table in a local sqlite database ...
		JSONObject room;
		String members_name_list;
		int room_id;
		count = room_array.length();
		for (int i=0; i<count; i++) {
			try {
				room = room_array.getJSONObject(i);
				
				room_id = room.getInt("room_id");
				members_name_list = room.getString("room_name");
				
				insertRoom(members_name_list, room_id);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		// Save user list to the 'rooms_ref' table in a local sqlite database ...
		JSONObject room_ref;
		count = ref_array.length();
		for (int i=0; i<count; i++) {
			try {
				room_ref = ref_array.getJSONObject(i);
				
				room_id = room_ref.getInt("room_id");
				user_id = room_ref.getInt("user_id");
				
				insertRoomsRefs(room_id, user_id);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public void saveMessageHistory(JSONArray message_array) {		
		// Save message log to the 'messages' table in a local sqlite database ...
		int count = message_array.length();
		JSONObject message;
		String msg, send_time;
		int sender_id, room_id;
		for (int i=0; i<count; i++) {
			try {
				message = message_array.getJSONObject(i);
				
				sender_id = message.getInt("sender_id");
				room_id = message.getInt("room_id");
				msg = message.getString("msg");
				send_time = message.getString("send_time");
				
				insertMsg(sender_id, msg, room_id, send_time);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		updateLatestTimeForAllRooms();
		updateRoomMemberListForAllRooms();
	}
	
}
