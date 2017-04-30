package com.goalgroup.model;

import android.R.bool;

public class PlayerFilterResultItem {
	private int user_id;
	private String photo;
	private String name;
	private String age;
	private String term;
	private String height;
	private String weight;
	private int position;
	private int play_days;
	private String play_areas;
	private int show_menu;
	
	public PlayerFilterResultItem(int user_id, String photo, String name, String age, String term, String height, String weight, 
			int pos, int dates, String areas) {
		this.user_id = user_id;
		this.photo = photo;
		this.name = name;
		this.age = age;
		this.term = term;
		this.height = height;
		this.weight = weight;
		this.position = pos;
		this.play_days = dates;
		this.play_areas = areas;
		this.show_menu = 0;
	}
	
	public int getUserID() {
		return user_id;
	}
	
	public String getPhoto() {
		return photo;
	}
	
	public String getName() {
		return name;
	}
	
	public String getAge() {
		return age;
	}
	
	public String getTerm() {
		return term;
	}
	
	public String getHeight() {
		return height;
	}
	
	public String getWeight() {
		return weight;
	}
	
	public int getPosition() {
		return position;
	}
	
	public int getPlayDays() {
		return play_days;
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
