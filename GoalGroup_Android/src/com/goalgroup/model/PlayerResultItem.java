package com.goalgroup.model;

public class PlayerResultItem {
	private int user_id;
	private String photo_url;
	private String user_name;
	private int goal;
	private int assist;
	private int point;
	
	public PlayerResultItem(int user_id, String photo_url, String user_name, int goal, int assist, int point) {
		this.user_id = user_id;
		this.photo_url = photo_url;
		this.user_name = user_name;
		this.goal = goal;
		this.assist = assist;
		this.point = point;
	}
	
	public int getUserID() {
		return user_id;
	}
	
	public String getPhotoURL() {
		return photo_url;
	}
	
	public String getUserName() {
		return user_name;
	}
	
	public int getGoal() {
		return goal;
	}
	
	public void setGoal(int value) {
		goal = value;
	}
	
	public int getAssist() {
		return assist;
	}
	
	public void setAssist(int value) {
		assist = value;
	}
	
	public int getPoint() {
		return point;
	}
	
	public void setPoint(int value) {
		point = value;
	}
}
