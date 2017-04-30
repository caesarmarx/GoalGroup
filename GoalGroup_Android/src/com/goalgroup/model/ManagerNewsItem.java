package com.goalgroup.model;

public class ManagerNewsItem {
	private String date;
	private String time;
	private String weekday;
	private String user_name;
	private String appealContent;
	private String answerContent;
	
	public ManagerNewsItem(String date, String time, String weekday, String user_name, String appealContent, String answerContent) {
		this.date = date;
		this.time = time;
		this.weekday = weekday;
		this.user_name = user_name;
		this.appealContent = appealContent;
		this.answerContent = answerContent;
	}
	
	public String getUserName() {
		return user_name;
	}
	
	public String getDate() {
		return date;
	}
	
	public String getTime() {
		return time;
	}
	
	public String getWeekDay() {
		return weekday;
	}
	
	public String getAppealContent() {
		return appealContent;
	}
	
	public String getAnswerContent() {
		return answerContent;
	}
}
