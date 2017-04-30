package com.goalgroup.model;

public class ClubHistoryItem {
	private String season;
	private String total;
	private String win;
	private String draw;
	private String lose;
	private String goal01;
	private String goal02;
	private String goalDiff;
	
	public ClubHistoryItem(String season, String total, String win, String draw, String lose, String goal01, String goal02, String goalDiff) {
		this.season = season;
		this.total = total;
		this.win = win;
		this.draw = draw;
		this.lose = lose;
		this.goal01 = goal01;
		this.goal02 = goal02;
		this.goalDiff = goalDiff;
	}
	
	public String getSeason() {
		return season;
	}
	
	public String getTotal() {
		return total;
	}
	
	public String getWin() {
		return win;
	}
	
	public String getDraw() {
		return draw;
	}
	
	public String getLose() {
		return lose;
	}
	
	public String getGoal01() {
		return goal01;
	}
	
	public String getGoal02() {
		return goal02;
	}
	
	public String getGoalDiff() {
		return goalDiff;
	}
}
