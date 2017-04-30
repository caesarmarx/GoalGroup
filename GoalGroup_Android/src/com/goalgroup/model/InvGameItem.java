package com.goalgroup.model;

public class InvGameItem {
	
	private int game_id;
	private int club_id_01;
	private String club_name_01;
	private String club_mark_01;
	private int club_id_02;
	private String club_name_02;
	private String club_mark_02;
	private int inv_team;
	private int player_num;
	private String date;
	private String time;
	private int wday;
	private String stadium;
	private int show_menu;
	
	public InvGameItem(int game_id, 
			int club_id_01, String club_name_01, String club_mark_01, 
			int club_id_02, String club_name_02, String club_mark_02, 
			int inv_team, int player_num, String date, String time, int wday, String stadium) {
		this.game_id = game_id;
		this.club_id_01 = club_id_01;
		this.club_name_01 = club_name_01;
		this.club_mark_01 = club_mark_01;
		this.club_id_02 = club_id_02;
		this.club_name_02 = club_name_02;
		this.club_mark_02 = club_mark_02;
		this.inv_team = inv_team;
		this.player_num = player_num;
		this.date = date;
		this.wday = wday;
		this.time = time;
		this.stadium = stadium;
		this.show_menu = 0;
		
		switchTeam();
	}
	
	private void switchTeam() {
		if (inv_team == 1)
			return;
		
		String tmp01;
		tmp01 = club_name_01; club_name_01 = club_name_02; club_name_02 = tmp01;
		tmp01 = club_mark_01; club_mark_01 = club_mark_02; club_mark_02 = tmp01;
		int tmp02;
		tmp02 = club_id_01; club_id_01 = club_id_02; club_id_02 = tmp02;
	}
	
	public int getGameId() {
		return game_id;
	}
	
	public int getClubId01() {
		return club_id_01;
	}
	
	public String getClubName01() {
		return this.club_name_01;
	}
	
	public String getClubMark01() {
		return this.club_mark_01;
	}
	
	public int getClubId02() {
		return club_id_02;
	}
	
	public String getClubName02() {
		return this.club_name_02;
	}
	
	public String getClubMark02() {
		return this.club_mark_02;
	}
	
	public int whichIsInvTeam() {
		return inv_team;
	}
	
	public int getPlayerNumber() {
		return player_num;
	}
	
	public String getDate() {
		return date;
	}
	
	public int getWday() {
		return wday;
	}
	
	public String getTime() {
		return time;
	}
	
	public String getStadium() {
		return stadium;
	}
	
	public int getInvTeamId() {
		return inv_team == 1 ? club_id_01 : club_id_02;
	}
	
	public int getShowMenu() {
		return show_menu;
	}
	
	public void setShowMenu(int value) {
		show_menu = value;
	}
}
