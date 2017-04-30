package com.goalgroup.model;

public class BbsItem {
	private int bbs_id;
	private String userphoto;
	private String username;
	private String datetime;
	private String contentPic;
	private String contents;
	private int type;
	private int reply_num;
	
	public BbsItem(int bbs_id, String userphoto, String username, String datetime, String contentPic, String contents, int reply_num) {
		this.bbs_id = bbs_id;
		this.userphoto = userphoto;
		this.username = username;
		this.datetime = datetime;
		this.contentPic = contentPic;
		this.contents = contents;
		this.type = 0;
		this.reply_num = reply_num;
	}
	
	public int getBBSId() {
		return bbs_id;
	}
	
	public String getUserPhoto() {
		return userphoto;		
	}
	
	public String getUserName() {
		return username;
	}
	
	public String getDateTime() {
		return datetime;
	}
	
	public String getContentPic() {
		return contentPic;
	}
	
	public String getContents() {
		return contents;
	}
	
	public void setType(int value) {
		type = value;
	}
	
	public int getType() {
		return type;
	}
	
	public int getReplyNumber() {
		return reply_num;
	}
}
