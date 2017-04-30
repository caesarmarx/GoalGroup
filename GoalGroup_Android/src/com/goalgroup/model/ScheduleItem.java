package com.goalgroup.model;

public class ScheduleItem {
	private int game_id;
	private String game_date;
	private String game_time;
	private String game_wday;
	private String clubmark1;
	private String clubname1;
	private String clubid1;
	private int player_number1;
	private String clubmark2;
	private String clubname2;
	private String clubid2;
	private int player_number2;
	private int player_number_mode;
	private String stadium_area;
	private String stadium_address;
	private String result;
	private boolean show_date_time;
	private int type;
	private int state;
	private String remain_time;
	
	public ScheduleItem(int game_id, String game_date, String game_time, String game_wday,
			String clubmark1, String clubname1, String clubid1, int player_number1, 
			String clubmark2, String clubname2, String clubid2, int player_number2, 
			int player_number_mode, String stadium_area, String stadium_address, String result, boolean show_date_time, String remain_time, int type, int state) {
		this.game_id = game_id;
		this.game_date = game_date;
		this.game_time = game_time;
		this.game_wday = game_wday;
		this.clubmark1 = clubmark1;
		this.clubname1 = clubname1;
		this.clubid1 = clubid1;
		this.player_number1 = player_number1;
		this.clubmark2 = clubmark2;
		this.clubname2 = clubname2;
		this.player_number2 = player_number2;
		this.clubid2 = clubid2;
		this.player_number_mode = player_number_mode;
		this.stadium_area = stadium_area;
		this.stadium_address = stadium_address;
		this.result = result;
		this.show_date_time = show_date_time;
		this.type = type;
		this.state = state;
		this.remain_time = remain_time;
	}
	
	public int getGameId() {
		return game_id;
	}
	
	public String getDate() {
		return game_date;
	}
	
	public String getTime() {
		return game_time;
	}
	
	public String getWDay() {
		return game_wday;
	}
	
	public String getClubMark01() {
		return clubmark1;
	}
	
	public String getClubName01() {
		return clubname1;
	}
	
	public String getClubId01() {
		return clubid1;
	}
	
	public int getPlayerNumber01() {
		return player_number1;
	}
	
	public String getClubMark02() {
		return clubmark2;
	}
	
	public String getClubName02() {
		return clubname2;
	}
	
	public String getClubId02() {
		return clubid2;
	}
	
	public int getPlayerNumber02() {
		return player_number2;
	}
	
	public int getPlayerCounts() {
		return player_number_mode;
	}
	
	public String getStadiumArea(){
		return stadium_area;
	}
	
	public String getStadiumAddress(){
		return stadium_address;
	}
	
	public String getResult() {
		return result;
	}
	
	public boolean showDateTime() {
		return show_date_time;
	}
	
	public int getType() {
		return type;
	}
	
	public int getState() {
		return state;
	}
	
	public String getRemainTime() {
		return remain_time;
	}
	
	public void setPlayerNumber01(int playernum) {
		this.player_number1 = playernum;
	}
	
	public void setPlayerNumber02(int playernum) {
		this.player_number2 = playernum;
	}
}
