package com.goalgroup.model;

import java.util.Hashtable;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.ContentValues;
import android.content.Context;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.goalgroup.http.OfflineDataHttp;
import com.goalgroup.ui.chat.EmoteUtil;
import com.goalgroup.utils.StringUtil;

public class OfflineClubChattingDbAdapter {
	public static final String KEY_USER_TABLE_ID = "id";
	public static final String KEY_USER_TABLE_USER_ID = "user_id";
	public static final String KEY_USER_TABLE_USER_NICKNAME = "nickname";
	public static final String KEY_USER_TABLE_USER_PHONE_NUM = "phone_num";

	public static final String KEY_USER_CLUB_RELATION_TABLE_ID = "id";
	public static final String KEY_USER_CLUB_RELATION_TABLE_CLUB_ID = "club_id";
	public static final String KEY_USER_CLUB_RELATION_TABLE_POST = "post";

	public static final String KEY_CLUB_TABLE_ID = "id";
	public static final String KEY_CLUB_TABLE_CLUB_ID = "club_id";
	public static final String KEY_CLUB_TABLE_CLUB_NAME = "club_name";

	public static final String KEY_CHAT_ROOM_MEMBER_TABLE_ID = "id";
	public static final String KEY_CHAT_ROOM_MEMBER_TABLE_CHAT_ROOM_ID = "chat_room_id";
	public static final String KEY_CHAT_ROOM_MEMBER_TABLE_STATE = "state";
	public static final String KEY_CHAT_ROOM_MEMBER_TABLE_OPTION = "chat_option";

	public static final String KEY_CHAT_ROOM_TABLE_ID = "id";
	public static final String KEY_CHAT_ROOM_TABLE_CHAT_ROOM_ID = "chat_room_id";
	public static final String KEY_CHAT_ROOM_TABLE_CHAT_ROOM_TITLE = "chat_room_title";
	public static final String KEY_CHAT_ROOM_TABLE_CHAT_TYPE = "chat_type";
	public static final String KEY_CHAT_ROOM_TABLE_CREATE_DATETIME = "create_datetime";

	public static final String KEY_CHAT_HISTORY_TABLE_ID = "id";
	public static final String KEY_CHAT_HISTORY_TABLE_CHAT_ROOM_ID = "chat_room_id";
	public static final String KEY_CHAT_HISTORY_TABLE_SENDER_ID = "sender_id";
	public static final String KEY_CHAT_HISTORY_TABLE_CONTENT = "content";
	public static final String KEY_CHAT_HISTORY_TABLE_SENDTIME = "sendtime";
	public static final String KEY_CHAT_HISTORY_TABLE_TYPE = "type";
	public static final String KEY_CHAT_HISTORY_TABLE_STATE = "state";

	public static final String DATABASE_NAME = "offline_club_db";
	public static final int DATABASE_VERSION = 1;

	public static final String USER_TABLE = "gg_user";
	public static final String USER_CLUB_RELATION_TABLE = "gg_user_club_relation";
	public static final String CLUB_TABLE = "gg_club";
	public static final String CHAT_ROOM_MEMBER_TABLE = "gg_chat_room_memeber";
	public static final String CHAT_ROOM_TABLE = "gg_chat_room";
	public static final String CHAT_HISTORY_TABLE = "gg_chat_history";

	static final String CREATE_USER_TABLE_QUERY = "CREATE TABLE IF NOT EXISTS "
			+ USER_TABLE + " (" + KEY_USER_TABLE_ID
			+ " INTEGER PRIMARY KEY AUTOINCREMENT, " + KEY_USER_TABLE_USER_ID
			+ " INTEGER NOT NULL DEFAULT 0, " + KEY_USER_TABLE_USER_NICKNAME
			+ " TEXT NOT NULL DEFAULT ''," + KEY_USER_TABLE_USER_PHONE_NUM
			+ " TEXT NOT NULL DEFAULT '');";
	static final String CREATE_USER_CLUB_RELATION_TABLE_QUERY = "CREATE TABLE IF NOT EXISTS "
			+ USER_CLUB_RELATION_TABLE
			+ " ("
			+ KEY_USER_CLUB_RELATION_TABLE_ID
			+ " INTEGER PRIMARY KEY AUTOINCREMENT, "
			+ KEY_USER_CLUB_RELATION_TABLE_CLUB_ID
			+ " INTEGER NOT NULL DEFAULT 0, "
			+ KEY_USER_CLUB_RELATION_TABLE_POST
			+ " INTEGER NOT NULL DEFAULT 0);";
	static final String CREATE_CLUB_TABLE_QUERY = "CREATE TABLE IF NOT EXISTS "
			+ CLUB_TABLE + " (" + KEY_CLUB_TABLE_ID
			+ " INTEGER PRIMARY KEY AUTOINCREMENT, " + KEY_CLUB_TABLE_CLUB_ID
			+ " INTEGER NOT NULL DEFAULT 0, " + KEY_CLUB_TABLE_CLUB_NAME
			+ " TEXT NULL DEFAULT 0);";
	static final String CREATE_CHAT_ROOM_MEMBER_TABLE_QUERY = "CREATE TABLE IF NOT EXISTS "
			+ CHAT_ROOM_MEMBER_TABLE
			+ " ("
			+ KEY_CHAT_ROOM_MEMBER_TABLE_ID
			+ " INTEGER PRIMARY KEY AUTOINCREMENT, "
			+ KEY_CHAT_ROOM_MEMBER_TABLE_CHAT_ROOM_ID
			+ " INTEGER NOT NULL DEFAULT 0, "
			+ KEY_CHAT_ROOM_MEMBER_TABLE_STATE
			+ " INTEGER NOT NULL DEFAULT 0, "
			+ KEY_CHAT_ROOM_MEMBER_TABLE_OPTION
			+ " INTEGER NOT NULL DEFAULT 0);";
	static final String CREATE_CHAT_ROOM_TABLE_QUERY = "CREATE TABLE IF NOT EXISTS "
			+ CHAT_ROOM_TABLE
			+ " ("
			+ KEY_CHAT_ROOM_TABLE_ID
			+ " INTEGER PRIMARY KEY AUTOINCREMENT, "
			+ KEY_CHAT_ROOM_TABLE_CHAT_ROOM_ID
			+ " INTEGER NOT NULL DEFAULT 0, "
			+ KEY_CHAT_ROOM_TABLE_CHAT_ROOM_TITLE
			+ " TEXT NOT NULL DEFAULT 0, "
			+ KEY_CHAT_ROOM_TABLE_CHAT_TYPE
			+ " INTEGER NOT NULL DEFAULT 0, "
			+ KEY_CHAT_ROOM_TABLE_CREATE_DATETIME
			+ " DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00');";
	static final String CREATE_CHAT_HISTORY_TABLE_QUERY = "CREATE TABLE IF NOT EXISTS "
			+ CHAT_HISTORY_TABLE
			+ " ("
			+ KEY_CHAT_HISTORY_TABLE_ID
			+ " INTEGER PRIMARY KEY AUTOINCREMENT, "
			+ KEY_CHAT_HISTORY_TABLE_CHAT_ROOM_ID
			+ " INTEGER NOT NULL DEFAULT 0, "
			+ KEY_CHAT_HISTORY_TABLE_SENDER_ID
			+ " INTEGER NOT NULL DEFAULT 0, "
			+ KEY_CHAT_HISTORY_TABLE_CONTENT
			+ " TEXT NOT NULL DEFAULT '', "
			+ KEY_CHAT_HISTORY_TABLE_SENDTIME
			+ " DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',"
			+ KEY_CHAT_HISTORY_TABLE_TYPE
			+ " INTEGER NOT NULL DEFAULT 0,"
			+ KEY_CHAT_HISTORY_TABLE_STATE + " INTEGER NOT NULL DEFAULT 0);";

	static final String DROP_USER_TABLE_QUERY = "DROP TABLE IF EXISTS "
			+ USER_TABLE;
	static final String DROP_USER_CLUB_RELATION_TABLE_QUERY = "DROP TABLE IF EXISTS "
			+ USER_CLUB_RELATION_TABLE;
	static final String DROP_CLUB_TABLE_QUERY = "DROP TABLE IF EXISTS "
			+ CLUB_TABLE;
	static final String DROP_CHAT_ROOM_MEMBER_TABLE_QUERY = "DROP TABLE IF EXISTS "
			+ CHAT_ROOM_MEMBER_TABLE;
	static final String DROP_CHAT_ROOM_TABLE_QUERY = "DROP TABLE IF EXISTS "
			+ CHAT_ROOM_TABLE;
	static final String DROP_CHAT_HISTORY_TABLE_QUERY = "DROP TABLE IF EXISTS "
			+ CHAT_HISTORY_TABLE;

	final Context context;

	DatabaseHelper DBHelper;

	SQLiteDatabase db;

	public OfflineClubChattingDbAdapter(Context ctx) {
		this.context = ctx;
		DBHelper = new DatabaseHelper(context);
	}

	private static class DatabaseHelper extends SQLiteOpenHelper {

		public DatabaseHelper(Context context) {
			super(context, DATABASE_NAME, null, DATABASE_VERSION);
		}

		public void onCreate(SQLiteDatabase db) {

			try {
				db.execSQL(CREATE_USER_TABLE_QUERY);
				db.execSQL(CREATE_USER_CLUB_RELATION_TABLE_QUERY);
				db.execSQL(CREATE_CLUB_TABLE_QUERY);
				db.execSQL(CREATE_CHAT_ROOM_MEMBER_TABLE_QUERY);
				db.execSQL(CREATE_CHAT_ROOM_TABLE_QUERY);
				db.execSQL(CREATE_CHAT_HISTORY_TABLE_QUERY);
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}

		public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
			db.execSQL(DROP_CHAT_HISTORY_TABLE_QUERY);
			db.execSQL(DROP_CHAT_ROOM_MEMBER_TABLE_QUERY);
			db.execSQL(DROP_CHAT_ROOM_TABLE_QUERY);
			db.execSQL(DROP_CLUB_TABLE_QUERY);
			db.execSQL(DROP_USER_CLUB_RELATION_TABLE_QUERY);
			db.execSQL(DROP_USER_TABLE_QUERY);
			onCreate(db);
		}
	}

	public void removeAll() {
		DBHelper.onUpgrade(db, 0, 0);
	}

	public OfflineClubChattingDbAdapter open() throws SQLException {
		db = DBHelper.getWritableDatabase();
		return this;
	}

	public void close() {
		DBHelper.close();
	}

	// //////////user table functions///////////////////
	public long userTableInsert(int user_id, String nickname, String phone_num) {
		ContentValues initialValues = new ContentValues();
		initialValues.put(KEY_USER_TABLE_USER_ID, user_id);
		initialValues.put(KEY_USER_TABLE_USER_NICKNAME, nickname);
		initialValues.put(KEY_USER_TABLE_USER_PHONE_NUM, phone_num);
		return db.insert(USER_TABLE, null, initialValues);
	}

	public void userTableDelete(int id) {

	}

	public void userTableUpdate(int id) {

	}

	// //////////user-club-relation table functions///////////////////
	public long userClubRelationTableInsert(int club_id, int post) {
		ContentValues initialValues = new ContentValues();
		initialValues.put(KEY_USER_CLUB_RELATION_TABLE_CLUB_ID, club_id);
		initialValues.put(KEY_USER_CLUB_RELATION_TABLE_POST, post);
		return db.insert(USER_CLUB_RELATION_TABLE, null, initialValues);
	}

	public void userClubRelationDelete(int id) {

	}

	public void userClubRelationUpdate(int id) {

	}

	// //////////club table functions///////////////////
	public long clubTableInsert(int club_id, String club_name) {
		ContentValues initialValues = new ContentValues();
		initialValues.put(KEY_CLUB_TABLE_CLUB_ID, club_id);
		initialValues.put(KEY_CLUB_TABLE_CLUB_NAME, club_name);
		return db.insert(CLUB_TABLE, null, initialValues);
	}

	public void clubTableDelete(int id) {

	}

	public void clubTableUpdate(int id) {

	}

	// //////////chat room table functions///////////////////

	public long chatRoomTableInsert(int chat_room_id, String chat_room_title,
			int chat_type, String create_datetime) {
		ContentValues initialValues = new ContentValues();
		initialValues.put(KEY_CHAT_ROOM_TABLE_CHAT_ROOM_ID, chat_room_id);
		initialValues.put(KEY_CHAT_ROOM_TABLE_CHAT_ROOM_TITLE, chat_room_title);
		initialValues.put(KEY_CHAT_ROOM_TABLE_CHAT_TYPE, chat_type);
		initialValues.put(KEY_CHAT_ROOM_TABLE_CREATE_DATETIME, create_datetime);
		return db.insert(CHAT_ROOM_TABLE, null, initialValues);
	}

	public void chatRoomTableDelete(int id) {

	}

	public void chatRoomTableUpdate(int id) {

	}

	// //////////chat room member table functions///////////////////

	public long chatRoomMemberTableInsert(int chat_room_id, int state,
			int chat_option) {
		ContentValues initialValues = new ContentValues();
		initialValues
				.put(KEY_CHAT_ROOM_MEMBER_TABLE_CHAT_ROOM_ID, chat_room_id);
		initialValues.put(KEY_CHAT_ROOM_MEMBER_TABLE_STATE, state);
		initialValues.put(KEY_CHAT_ROOM_MEMBER_TABLE_OPTION, chat_option);
		return db.insert(CHAT_ROOM_MEMBER_TABLE, null, initialValues);
	}

	public void chatRoomMemberTableDelete(int id) {

	}

	public void chatRoomMemberTableUpdate(int id) {

	}

	// //////////chat history table functions///////////////////

	public long chatHistoryTableInsert(int chat_room_id, int sender_id,
			String content, String sendtime, int type, int state) {
		ContentValues initialValues = new ContentValues();
		initialValues.put(KEY_CHAT_HISTORY_TABLE_CHAT_ROOM_ID, chat_room_id);
		initialValues.put(KEY_CHAT_HISTORY_TABLE_SENDER_ID, sender_id);
		initialValues.put(KEY_CHAT_HISTORY_TABLE_CONTENT, content);
		initialValues.put(KEY_CHAT_HISTORY_TABLE_SENDTIME, sendtime);
		initialValues.put(KEY_CHAT_HISTORY_TABLE_TYPE, type);
		initialValues.put(KEY_CHAT_HISTORY_TABLE_STATE, state);
		return db.insert(CHAT_HISTORY_TABLE, null, initialValues);
	}

	public void chatHistoryTableDelete(int id) {

	}

	public void chatHistoryTableUpdate(int id) {

	}

	public void updateOfflineTable(OfflineDataHttp post) {

		Hashtable<String, Integer> table_hash = new Hashtable<String, Integer>();
		table_hash.put(USER_CLUB_RELATION_TABLE, 0);
		table_hash.put(USER_TABLE, 1);
		table_hash.put(CLUB_TABLE, 2);
		table_hash.put(CHAT_ROOM_MEMBER_TABLE, 3);
		table_hash.put(CHAT_ROOM_TABLE, 4);
		table_hash.put(CHAT_HISTORY_TABLE, 5);

		try {
			String json = post.getData();
			JSONObject offline_data = new JSONObject(json);
			String lasttimestr;
			OfflineClubChattingDbAdapter db = new OfflineClubChattingDbAdapter(
					context);
			db.open();
			JSONArray content = new JSONArray();
			content = offline_data.getJSONArray("content");
			lasttimestr = offline_data.getString("last_updated_time");
			JSONObject[] table_array = new JSONObject[6];
			String table_name;
			JSONArray table_raw_array = new JSONArray();
			JSONObject table_result = new JSONObject();
			JSONObject table_raw = new JSONObject();
			for (int i = 0; i < content.length(); i++) {
				table_array[i] = content.getJSONObject(i);
				table_result = table_array[i];
				table_name = table_result.getString("table_name");
				switch (table_hash.get(table_name)) {
				case 0:
					table_raw_array = table_result.getJSONArray("table_data");
					for (int j = 0; j < table_raw_array.length(); j++) {
						table_raw = table_raw_array.getJSONObject(j);
						int club_id = table_raw.getInt("club_id");
						int post_chat = table_raw.getInt("post");
						db.userClubRelationTableInsert(club_id, post_chat);
					}

					break;
				case 1:
					table_raw_array = table_result.getJSONArray("table_data");
					for (int j = 0; j < table_raw_array.length(); j++) {
						table_raw = table_raw_array.getJSONObject(j);
						int user_id = table_raw.getInt("user_id");
						String nickname = table_raw.getString("nickname");
						String phone_num = table_raw.getString("phone_num");
						db.userTableInsert(user_id, nickname, phone_num);
					}
					break;
				case 2:
					table_raw_array = table_result.getJSONArray("table_data");
					for (int j = 0; j < table_raw_array.length(); j++) {
						table_raw = table_raw_array.getJSONObject(j);
						int club_id = table_raw.getInt("club_id");
						String club_name = table_raw.getString("club_name");
						db.clubTableInsert(club_id, club_name);
					}
					break;
				case 3:
					table_raw_array = table_result.getJSONArray("table_data");
					for (int j = 0; j < table_raw_array.length(); j++) {
						table_raw = table_raw_array.getJSONObject(j);
						int chat_room_id = table_raw.getInt("chat_room_id");
						int state = table_raw.getInt("state");
						int chat_option = table_raw.getInt("chat_option");
						db.chatRoomMemberTableInsert(chat_room_id, state,
								chat_option);
					}
					break;
				case 4:
					table_raw_array = table_result.getJSONArray("table_data");
					for (int j = 0; j < table_raw_array.length(); j++) {
						table_raw = table_raw_array.getJSONObject(j);
						int chat_room_id = table_raw.getInt("chat_room_id");
						String chat_room_title = table_raw
								.getString("chat_room_title");
						int chat_type = table_raw.getInt("chat_type");
						String create_datetime = table_raw
								.getString("create_datetime");
						db.chatRoomTableInsert(chat_room_id, chat_room_title,
								chat_type, create_datetime);
					}
					break;
				case 5:
					table_raw_array = table_result.getJSONArray("table_data");
					for (int j = 0; j < table_raw_array.length(); j++) {
						table_raw = table_raw_array.getJSONObject(j);
						int chat_room_id = table_raw.getInt("chat_room_id");
						int sender_id = table_raw.getInt("sender_id");
						String chat_content = table_raw.getString("content");
						String sendtime = table_raw.getString("sendtime");
						int type = table_raw.getInt("type");
						int state = table_raw.getInt("state");
						db.chatHistoryTableInsert(chat_room_id, sender_id,
								chat_content, sendtime, type, state);
					}
					break;
				}
			}
			db.close();
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
