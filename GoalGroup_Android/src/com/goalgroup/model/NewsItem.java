package com.goalgroup.model;

public class NewsItem {
	private int type;
	private String title;
	private String content;
	private String datetime;
	
	public NewsItem(int type, String title, String content, String datetime) {
		this.type = type;
		this.title = title;
		this.content = content;
		this.datetime = datetime;
	}
	
	public int getType() {
		return type;
	}
	
	public String getTitle() {
		return title;
	}
	
	public String getContent() {
		return content;
	}
	
	public String getDateTime() {
		return datetime;
	}
}
