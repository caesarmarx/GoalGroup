package com.goalgroup.model;

public class SettingItem {
	
	private int icon;
	private int title;
	
	public SettingItem(int icon, int title) {
		this.icon = icon;
		this.title = title;
	}
	
	public int getIconID() {
		return icon;
	}
	
	public int getTitleID() {
		return title;
	}
}
