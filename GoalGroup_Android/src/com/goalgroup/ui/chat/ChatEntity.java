package com.goalgroup.ui.chat;

public class ChatEntity {
	private String id;
	private int user_id;
	private String datetime;
	private String body;
	private int type; // 1: image_chat, 0: normal chat
	private boolean isMe;
	private String user_photo;
	private boolean state;
	private boolean sending;

	public ChatEntity(int user_id, String id, String datetime, String body, int type, boolean isMe, String user_photo, boolean state) {
		this.id = id;
		this.user_id = user_id;
		this.datetime = datetime;
		this.body = body;
		this.isMe = isMe;
		this.type = type;
		this.user_photo = user_photo;
		this.state = state;
	}
	
	public ChatEntity(int user_id, String id, String datetime, String body, int type, boolean isMe, String user_photo, boolean state, boolean sending) {
		this.id = id;
		this.user_id = user_id;
		this.datetime = datetime;
		this.body = body;
		this.isMe = isMe;
		this.type = type;
		this.user_photo = user_photo;
		this.state = state;
		this.sending = sending;
	}
	
	public String getID() {
		return id;
	}
	
	public int getType() {
		return type;
	}
	
	public int getUserID() {
		return user_id;
	}

	public String getDateTime() {
		return datetime;
	}

	public String getMsgBody() {
		return body;
	}

	public boolean isMe() {
		return isMe;
	}
	
	public String getUserPhoto() {
		return user_photo;
	}
	
	public void setState(boolean state) {
		this.state = state;
	}
	
	public boolean getState() {
		return state;
	}

	public boolean isSending() {
		return sending;
	}

	public void setSending(boolean sending) {
		this.sending = sending;
	}
}
