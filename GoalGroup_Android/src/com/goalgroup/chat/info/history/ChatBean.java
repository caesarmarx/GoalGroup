package com.goalgroup.chat.info.history;

import com.goalgroup.constants.DBConst;

import android.content.ContentValues;

public class ChatBean {
	public static final String BEAN_NAME = "CHATLOG_BEAN";
	
	private int id = 0;
	public int getID() {
		return id;
	}	
	public void setID(int value) {
		id = value;
	}
	
	private int user_id = 0;
	public int getUserID() {
		return user_id;
	}
	
	public void setUserID(int value) {
		user_id = value;
	}
	
	private int room_id = -1;
	public int getRoomId() {
		return room_id;
	}
	public void setRoomId(int value) {
		room_id = value;
	}
	
	private String buddy = "";
	public String getBuddy() {
		return buddy;
	}
	public void setBuddy(String value) {
		buddy = value;
	}
	
	
	private String buddyPhoto = "";
	public String getBuddyPhoto() {
		return buddyPhoto;
	}
	public void setBuddyPhoto(String value){
		buddyPhoto = value;
	}
	
	private int isMine = 0;
	public int getIsMine() {
		return isMine;
	}
	public void setIsMine(int value) {
		isMine = value;
	}
	
	private int isSent = 0;
	public int getIsSent() {
		return isSent;
	}
	public void setIsSent(int value) {
		isSent= value;
	}
	
	private int type = 0;
	public int getType() {
		return type;
	}
	public void setType(int value) {
		type = value;
	}
	
	private String message = "";
	public String getMsg() {
		return message;
	}
	public void setMsg(String value) {
		message = value;
	}
	
	private String time = "";
	public String getTime() {
		return time;
	}
	public void setTime(String value) {
		time = value;
	}
	
	public ContentValues getValues() {
		
		ContentValues values = new ContentValues();

		values.put(DBConst.FIELD_ID, id);
		values.put(DBConst.FIELD_ROOM_ID, room_id);
		values.put(DBConst.FIELD_BUDDY, buddy);
		values.put(DBConst.FIELD_IS_MINE, isMine);
		values.put(DBConst.FIELD_MESSAGE, message);
		values.put(DBConst.FIELD_MSG_TYPE, type);
		values.put(DBConst.FIELD_TIME, time);
		values.put(DBConst.FIELD_USER_ID, user_id);
		values.put(DBConst.FIELD_SEND_STATE, isSent);

		return values;
	}
}
