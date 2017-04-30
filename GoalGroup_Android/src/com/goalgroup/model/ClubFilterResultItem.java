package com.goalgroup.model;

public class ClubFilterResultItem {
	private int club_id;
	private String club_mark;
	private String name;
	private int members;
	private int points;
	private int aver_age;
	private int play_dates;
	private String play_areas;
	private int show_menu;
	
	public ClubFilterResultItem(int club_id, String club_mark, String name, int member, int points, int age, int dates, String areas) {
		this.club_id = club_id;
		this.club_mark = club_mark;
		this.name = name;
		this.members = member;
		this.points = points;
		this.aver_age = age;
		this.play_dates = dates;
		this.play_areas = areas;
		this.show_menu = 0;
	}
	
	public int getClubID() {
		return club_id;
	}
	
	public String getClubMark() {
		return club_mark;
	}
	
	public String getName() {
		return name;
	}
	
	public int getMembers() {
		return members;
	}
	
	public int getPoints() {
		return points;
	}
	
	public int getAverAge() {
		return aver_age;
	}
	
	public int getPlayDates() {
		return play_dates;
	}
	
	public String getPlayAreas() {
		return play_areas;
	}
	
	public int getShowMenu() {
		return show_menu;
	}
	
	public void setShowMenu(int value) {
		show_menu = value;
	}
}
