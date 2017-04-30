package com.goalgroup.model;

public class BbsReplyItem {
	private int id;
	private int user_id;
	private int reply_id;
	private String username;
	private String datetime;
	private String contents;
	private int depth;
	
	public BbsReplyItem(int id, int user_id, String username, String datetime, String contents, int reply_id, int depth) {
		this.id = id;
		this.user_id = user_id;
		this.username = username;
		this.datetime = datetime;
		this.contents = contents;
		this.reply_id = reply_id;
		this.depth = depth;
	}
	
	public int getId() {
		return id;
	}
	
	public int getUserId() {
		return user_id;
	}
	
	public String getUserName() {
		return username;
	}
	
	public String getDateTime() {
		return datetime;
	}
	
	public String getContents() {
		return contents;
	}
	
	public int getReplyId() {
		return reply_id;
	}
	
	public int getDepth() {
		return depth;
	}

	public void setId(int id) {
		this.id = id;
	}

	public void setUser_id(int user_id) {
		this.user_id = user_id;
	}

	public void setReply_id(int reply_id) {
		this.reply_id = reply_id;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public void setDatetime(String datetime) {
		this.datetime = datetime;
	}

	public void setContents(String contents) {
		this.contents = contents;
	}

	public void setDepth(int depth) {
		this.depth = depth;
	}
}
