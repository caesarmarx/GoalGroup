package com.goalgroup.model;

public class InvitationItem {
	private int club_id;
	private String club_mark;
	private String club_name;
	private String inv_date;
	private int show_menu;
	
	public InvitationItem(int club_id, String club_mark, String club_name, String inv_date) {
		this.club_id = club_id;
		this.club_mark = club_mark;
		this.club_name = club_name;
		this.inv_date = inv_date;
		this.show_menu = 0;
	}
	
	public int getClubID() {
		return club_id;
	}
	
	public String getClubMark() {
		return club_mark;
	}
	
	public String getClubName() {
		return club_name;
	}
	
	public String getInvDate() {
		return inv_date;
	}
	
	public int getShowMenu() {
		return show_menu;
	}
	
	public void setShowMenu(int value) {
		show_menu = value;
	}
}
