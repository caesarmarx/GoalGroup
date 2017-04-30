package com.goalgroup.model;

public class PlayerHistoryItem {
	private String season;
	private String total;
	private String goal;
	private String assist;
	private String point;
	
	public PlayerHistoryItem(String season, String total, String goal, String assist, String point) {
		this.season = season;
		this.total = total;
		this.goal = goal;
		this.assist = assist;
		this.point = point;
	}
	
	public String getSeason() {
		return season;
	}
	
	public String getTotal() {
		return total;
	}
	
	public String getGoal() {
		return goal;
	}
	
	public String getAssist() {
		return assist;
	}
	
	public String getPoint() {
		return point;
	}
}
