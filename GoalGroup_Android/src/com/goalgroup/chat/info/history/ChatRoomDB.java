package com.goalgroup.chat.info.history;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.goalgroup.constants.DBConst;
import com.goalgroup.utils.DBHelper;

public class ChatRoomDB extends DBHelper {
	
	private static final String TABLE_NAME = "tbl_chat_room";
	private static final Object[] DB_LOCK 		= new Object[0];

	public ChatRoomDB(Context context) {
		super(context);
	}
	
	public int getUnreadCount(int room_id) {
		int ret = 0;
		try {
			String szWhere = DBConst.FIELD_ROOM_ID + "=" + room_id;
			
			synchronized (DB_LOCK) {
				SQLiteDatabase db = getReadableDatabase();
				Cursor cursor = db.query(TABLE_NAME, null, szWhere, null, null, null, null);
				final int UNREAD_CNT	= cursor.getColumnIndexOrThrow(DBConst.FIELD_UNREAD_COUNT);
				if(cursor.moveToNext()) {
					ret = cursor.getInt(UNREAD_CNT);
				}
				cursor.close();
				db.close();
			}
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
		return ret;
	}
	
	public void setUnreadCount(int room_id, int unread_cnt) {
		try {
			ContentValues value = new ContentValues();
			value.put(DBConst.FIELD_UNREAD_COUNT, unread_cnt);
			String szWhere = DBConst.FIELD_ROOM_ID + "=" + room_id;
			synchronized (DB_LOCK) {
				SQLiteDatabase db = getWritableDatabase();
				db.update(TABLE_NAME, value, szWhere, null);
				db.close();
			}			
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
	}
	
	public void resetUnreadCount(int room_id) {
		try {
			ContentValues value = new ContentValues();
			value.put(DBConst.FIELD_UNREAD_COUNT, 0);
			String szWhere = DBConst.FIELD_ROOM_ID + "=" + room_id;
			synchronized (DB_LOCK) {
				SQLiteDatabase db = getWritableDatabase();
				db.update(TABLE_NAME, value, szWhere, null);
				db.close();
			}			
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
	}
	
	public void incUnreadCount(int room_id) {
		int origin_cnt = getUnreadCount(room_id);
		origin_cnt ++;
		setUnreadCount(room_id, origin_cnt);
	}
	
	public void insertRoom(int room_id) {
		int result = 0;
		try {
			String szWhere = DBConst.FIELD_ROOM_ID + "=" + room_id;
			
			synchronized (DB_LOCK) {
				SQLiteDatabase db = getReadableDatabase();
				Cursor cursor = db.query(TABLE_NAME, null, szWhere, null, null, null, null);
				if(cursor.moveToNext()) {
					result = 1;
				}
				cursor.close();
				db.close();
			}
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
		
		if(result != 1) {
			try {
				ContentValues value = new ContentValues();
				value.put(DBConst.FIELD_ROOM_ID, room_id);
				value.put(DBConst.FIELD_UNREAD_COUNT, 0);
				synchronized (DB_LOCK) {
					SQLiteDatabase db = getWritableDatabase();
					db.insert(TABLE_NAME, null, value);
					db.close();
				}
			} catch (IllegalStateException ex) {
				ex.printStackTrace();
			}
		}
	}
	
	public boolean deleteRoom(int room_id) {
		boolean ret = false;
		SQLiteDatabase db = null;
		try {
			db = getWritableDatabase();
			synchronized (DB_LOCK) {
				int nID = db.delete(TABLE_NAME, DBConst.FIELD_ROOM_ID + "=" + room_id, null);
				ret = nID > 0;
			}
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		} finally {
			if (db != null)
				db.close();
		}
		
		return ret;
	}
}