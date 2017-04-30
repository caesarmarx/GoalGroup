package com.goalgroup.chat.info.history;

import java.util.ArrayList;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.goalgroup.constants.DBConst;
import com.goalgroup.utils.DBHelper;

public class ChatHistoryDB extends DBHelper {
	
	private static final String TABLE_NAME = "tbl_chat_history";
	private static final Object[] DB_LOCK 		= new Object[0];

	public ChatHistoryDB(Context context) {
		super(context);
	}
	
	public long addMsg(ChatBean bean) {
		long ret = -1;
		try {
			ContentValues value = new ContentValues();
			value.put(DBConst.FIELD_MESSAGE, bean.getMsg());
			value.put(DBConst.FIELD_ROOM_ID, bean.getRoomId());
			value.put(DBConst.FIELD_BUDDY, bean.getBuddy());
			value.put(DBConst.FIELD_TIME, bean.getTime());
			value.put(DBConst.FIELD_IS_MINE, bean.getIsMine());
			value.put(DBConst.FIELD_MSG_TYPE, bean.getType());
			value.put(DBConst.FIELD_USER_ID, bean.getUserID());
			value.put(DBConst.FIELD_USER_PHOTO, bean.getBuddyPhoto());
			value.put(DBConst.FIELD_SEND_STATE, bean.getIsSent());
			synchronized (DB_LOCK) {
				SQLiteDatabase db = getWritableDatabase();
				ret = db.insert(TABLE_NAME, null, value);
				bean.setID((int)ret);
				db.close();
			}			
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
		
		return ret;
	}
	
	public void updateState(int id) {
		try {
			String szWhere = DBConst.FIELD_ID + "=" + id;
			ContentValues value = new ContentValues();
			value.put(DBConst.FIELD_SEND_STATE, 1);
			
			synchronized (DB_LOCK) {
				SQLiteDatabase db = getReadableDatabase();
				db.update(TABLE_NAME, value, szWhere, null);
				db.close();
			}
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
	}
	
	public ArrayList<ChatBean> fetchMsgs(String roomId) {		
		ArrayList<ChatBean> ret = null;
		try {
			String szWhere = DBConst.FIELD_ROOM_ID + "=" + Integer.parseInt(roomId);
			String szOrderBy = DBConst.FIELD_ID;
			
			synchronized (DB_LOCK) {
				SQLiteDatabase db = getReadableDatabase();
				Cursor cursor = db.query(TABLE_NAME, null, szWhere, null, null, null, szOrderBy);
				ret = createChatBeans(cursor);
				db.close();
			}
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
		
		return ret;
	}
	
	public ArrayList<ChatBean> fetchMsgs(int state) {		
		ArrayList<ChatBean> ret = null;
		try {
			String szWhere = DBConst.FIELD_SEND_STATE + "=" + state;
			String szOrderBy = DBConst.FIELD_ID;
			
			synchronized (DB_LOCK) {
				SQLiteDatabase db = getReadableDatabase();
				Cursor cursor = db.query(TABLE_NAME, null, szWhere, null, null, null, szOrderBy);
				ret = createChatBeans(cursor);
				db.close();
			}
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
		
		return ret;
	}
	
	public void removeMsgs(String roomId) {
		try {
			String szWhere = DBConst.FIELD_ROOM_ID + "=" + Integer.parseInt(roomId);
			
			synchronized (DB_LOCK) {
				SQLiteDatabase db = getReadableDatabase();
				db.delete(TABLE_NAME, szWhere, null);
				db.close();
			}
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
	}
	
	public void removeMsgs() {
		try {
//			String szWhere = DBConst.FIELD_ROOM_ID + "=" + Integer.parseInt(roomId);
			
			synchronized (DB_LOCK) {
				SQLiteDatabase db = getReadableDatabase();
				db.delete(TABLE_NAME, "", null);
				db.close();
			}
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
	}
	
	private ArrayList<ChatBean> createChatBeans(Cursor c) {
		ArrayList<ChatBean> ret = null;
		try {
			ret = new ArrayList<ChatBean>();
			
			final int COL_ID	= c.getColumnIndexOrThrow(DBConst.FIELD_ID),
				COL_ROOM_ID 	= c.getColumnIndexOrThrow(DBConst.FIELD_ROOM_ID),
				COL_USER_ID		= c.getColumnIndexOrThrow(DBConst.FIELD_USER_ID),
				COL_BUDDY 		= c.getColumnIndexOrThrow(DBConst.FIELD_BUDDY),
				COL_ISMINE	 	= c.getColumnIndexOrThrow(DBConst.FIELD_IS_MINE),
				COL_TYPE 		= c.getColumnIndexOrThrow(DBConst.FIELD_MSG_TYPE),
				COL_MESSAGE 	= c.getColumnIndexOrThrow(DBConst.FIELD_MESSAGE),
				COL_TIME 		= c.getColumnIndexOrThrow(DBConst.FIELD_TIME),
				COL_USER_PHOTO  = c.getColumnIndexOrThrow(DBConst.FIELD_USER_PHOTO),
				COL_SEND_STATE	= c.getColumnIndexOrThrow(DBConst.FIELD_SEND_STATE);
				
			while (c.moveToNext()) {
				ChatBean bean = new ChatBean();
	
				bean.setID(c.getInt(COL_ID));
				bean.setRoomId(c.getInt(COL_ROOM_ID));
				bean.setBuddy(c.getString(COL_BUDDY));
				bean.setIsMine(c.getInt(COL_ISMINE));
				bean.setType(c.getInt(COL_TYPE));
				bean.setMsg(c.getString(COL_MESSAGE));
				bean.setTime(c.getString(COL_TIME));
				bean.setUserID(c.getInt(COL_USER_ID));
				bean.setBuddyPhoto(c.getString(COL_USER_PHOTO));
				bean.setIsSent(c.getInt(COL_SEND_STATE));
				ret.add(bean);
			}
			
			c.close();
			getReadableDatabase().close();
		} catch (IllegalStateException ex) {
			ex.printStackTrace();
		}
		
		return ret;
	}
}