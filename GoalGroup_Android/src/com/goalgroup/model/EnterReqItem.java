package com.goalgroup.model;

public class EnterReqItem {
	private int user_id;
	private String nick_name;
	private String req_date;
	private String photo_url;
	private String position;
	private int showMenu = 0;
	private int viewPosition = 0;
	
	public EnterReqItem(int userID, String nickName, String date, String photoUrl, String position) {
		this.user_id = userID;
		this.nick_name = nickName;
		this.req_date = date;
		this.photo_url = photoUrl;
		this.position = position;
		
	}
	
	public int getUserId() {
		return user_id;
	}
	
	public String getNickName() {
		return nick_name;
	}
	
	public String getPhotoUrl() {
		return photo_url;
	}
	
	public String getInfo() {
		return position;
	}
	
	public String getDate() {
		return req_date;
	}

	public int getShowMenu() {
		return showMenu;
	}

	public void setShowMenu(int showItem) {
		this.showMenu = showItem;
	}
}
