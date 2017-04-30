package com.goalgroup.utils;

import com.goalgroup.GgApplication;
import com.goalgroup.constants.DBConst;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class DBHelper extends SQLiteOpenHelper {

	private static final String DB_NAME_PREFIX = "GOALGROUP_DB_";
	private static final int DB_VERSION = 2;
	
	protected static String CHAT_HISTORY_TABLE_CREATE_SQL =
			"CREATE TABLE IF NOT EXISTS tbl_chat_history (" +
				DBConst.FIELD_ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
				DBConst.FIELD_ROOM_ID + " INTEGER," +
				DBConst.FIELD_BUDDY + " TEXT," +
				DBConst.FIELD_IS_MINE + " INTEGER," +
				DBConst.FIELD_MSG_TYPE + " INTEGER," +
				DBConst.FIELD_MESSAGE + " TEXT," +
				DBConst.FIELD_USER_ID + " INTEGER," +
				DBConst.FIELD_USER_PHOTO + " TEXT," +
				DBConst.FIELD_TIME + " TEXT," +
				DBConst.FIELD_SEND_STATE + " INTEGER);";
	
	protected static String CHAT_ROOM_TABLE_CREATE_SQL =
			"CREATE TABLE IF NOT EXISTS tbl_chat_room (" +
				DBConst.FIELD_ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
				DBConst.FIELD_ROOM_ID + " INTEGER," +
				DBConst.FIELD_UNREAD_COUNT + " INTEGER);";
	
	public DBHelper(Context context) {
		super(context, DB_NAME_PREFIX + GgApplication.getInstance().getUserId(), null, DB_VERSION);
		this.getWritableDatabase().close();
	}
	
	@Override
	public void onCreate(SQLiteDatabase db) {
		
		try {
			db.execSQL(CHAT_HISTORY_TABLE_CREATE_SQL);
			db.execSQL(CHAT_ROOM_TABLE_CREATE_SQL);
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		try {
			onCreate(db);
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
	}

}
