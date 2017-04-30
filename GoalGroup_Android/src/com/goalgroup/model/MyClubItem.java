package com.goalgroup.model;

public class MyClubItem {
	private int club_id;
	private String mark_url;
	private String name;
	
	public MyClubItem(int club_id, String mark_url, String name) {
		this.club_id = club_id;
		this.mark_url = mark_url;
		this.name = name;
	}
	
	public int getClubId() {
		return club_id;
	}
	
	public String getClubMarkURL() {
		return mark_url;
	}
	
	public String getName() {
		return name;
	}
}
