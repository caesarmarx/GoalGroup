package com.goalgroup.model;

public class ClubChallengeItem {
	
	private String chall_id;
	private String club_id_01;
	private String club_name_01;
	private String club_mark_01;
	private String club_id_02;
	private String club_name_02;
	private String club_mark_02;
	private String game_date;
	private String game_wday;
	private String game_time;
	private String stadium_area;
	private String stadium_address;
	private String player_count;
	private String money_split;
	private String vs_status;
	private String remain_time;
	private int show_menu;
	
	public ClubChallengeItem(String chall_id, 
			String club_id_01, String club_name_01, String club_mark_01, 
			String club_id_02, String club_name_02, String club_mark_02,  
			String game_date, String game_wday, String game_time, 
			String stadium_area, String stadium_address, String player_count, String money_split, String vs_status, String remain_time) {
		this.chall_id = chall_id;
		this.club_id_01 = club_id_01;
		this.club_name_01 = club_name_01;
		this.club_mark_01 = club_mark_01;
		this.club_id_02 = club_id_02;
		this.club_name_02 = club_name_02;
		this.club_mark_02 = club_mark_02;
		this.game_date = game_date;
		this.game_wday = game_wday;
		this.game_time = game_time;
		this.stadium_area = stadium_area;
		this.stadium_address = stadium_address;
		this.player_count = player_count;
		this.money_split = money_split;
		this.vs_status = vs_status;
		this.remain_time = remain_time;
		this.show_menu = 0;
	}
	
	public String getChallId() {
		return chall_id;
	}
	
	public String getClubId01() {
		return club_id_01;
	}
	
	public String getClubName01() {
		return club_name_01;
	}
	
	public String getClubMark01() {
		return club_mark_01;
	}
	
	public String getClubId02() {
		return club_id_02;
	}
	
	public String getClubName02() {
		return club_name_02;
	}
	
	public String getClubMark02() {
		return club_mark_02;
	}
	
	public String getGameDate() {
		return game_date;
	}
	
	public String getGameWday() {
		return game_wday;
	}
	
	public String getGameTime() {
		return game_time;
	}
	
	public String getStadiumArea() {
		return stadium_area;
	}
	
	public String getStadiumAddress() {
		return stadium_address;
	}
	
	public String getPlayerCount() {
		return player_count;
	}
	
	public String getMoneySplit() {
		return money_split;
	}
	
	public String getRemainTime() {
		return remain_time;
	}
	
	public String getVsStatus() {
		return vs_status;
	}
	
	public int getShowMenu() {
		return show_menu;
	}
	
	public void setShowMenu(int value) {
		show_menu = value;
	}
}
