package com.goalgroup.model;

public class ChatRoomItem {
	private String photo_url;
	private String room_name;
	private String last_chat;
	private String last_time;
	
	public ChatRoomItem(String photo_url, String room_name, String last_chat, String last_time) {
		this.photo_url = photo_url;
		this.room_name = room_name;
		this.last_chat = last_chat;
		this.last_time = last_time;
	}
	
	public String getPhotoURL() {
		return photo_url;
	}
	
	public String getRoomName() {
		return room_name;
	}
	
	public String getLastChat() {
		return last_chat;
	}
	
	public String getLastTime() {
		return last_time;
	}
}
