package com.goalgroup.constants;

public class CommonConsts {
	
	public static final String CHALL_TYPE_TAG = "challenge_type";
	
	public static final int CHALL_TYPE_ALL_CHALLENGE = 0;
	public static final int CHALL_TYPE_ALL_PROCLAIM = 1;
	public static final int CHALL_TYPE_MY_CHALLENGE = 2;
	
	public static final int CHALLENGE_GAME = 0;
	public static final int PROCLAIM_GAME =1;
	public static final int CUSTOM_GAME = 2;
	
	public static final String PROCLAIM_START_TYPE = "proclaim_start_type";
	
	public static final int FROM_CHALLENGE = 0;
	public static final int FROM_CHAT = 0;
	
	public static final String CLUB_TYPE_TAG = "create_club_type";
	
	public static final int CREATE_CLUB = 0;
	public static final int EDIT_CLUB = 1;
	public static final int CLUB_INFO = 2;
	
	public static final int NORMAL = 0;
	public static final int BREAK_CLUB = 1;
	public static final int JOIN_CLUB =2;
	
	public static final int EDIT_PROFILE = 0;
	public static final int SHOW_PROFILE = 1;
	
	public static final int FROM_MARKET = 1;
	public static final int FROM_INVITE = 2;
	
	public static final int NEW_CHALLENGE = 0;
	public static final int EDIT_GAME = 1;
	public static final int NEW_GAME = 2;
	public static final int SHOW_GAME = 3;
	
	public static final int ACCEPT_REQ = 1;
	public static final int REJECT_REQ = 2;
	
	public static final int REPORT_TYPE = 0;
	public static final int OPINION_TYPE = 1;
	
	public static final int GAME_STATE_WAIT = 0;
	public static final int GAME_STATE_READY = 1;
	public static final int GAME_STATE_PLAYING = 2;
	public static final int GAME_STATE_CANCELED = 3;
	public static final int GAME_STATE_FINISHED = 4;
	
	public static final int GAME_STATE_WIN = 0;
	public static final int GAME_STATE_DEFEAT = 1;
	public static final int GAME_STATE_DRAW = 2;
	public static final int GAME_STATE_TEAM1 = 3;
	public static final int GAME_STATE_TEAM1_CONF = 4;
	public static final int GAME_STATE_TEAM2 = 5;
	public static final int GAME_STATE_TEAM2_CONF = 6;
	
	public static final int MAX_AGE = 1;
	public static final int MIN_AGE = 0;
	
	public static final String SCHEDULE_FROM_TAG = "Game Schedule Source Activity";
	public static final int SCHEDULE_FROM_CHAT = 0;
	public static final int SCHEDULE_FROM_INVT = 1;
	
	public static final String CLUB_ID_TAG = "Current Club Id";
	public static final String OPP_CLUB_ID_TAG = "Opponent Club Id";
	public static final String GAME_ID_TAG = "Game Id";
	public static final String BREAKUP_CLUB = "break_club";
	
	public static final int UNBREAKED_CLUB = 0;
	public static final int BREAKED_CLUB = 1;
	
	public static final int CITY = 0;
	public static final int DISTRICT = 1;
	public static final int STADIUM = 2;
	public static final int POSITION = 3;
	public static final int ACT_DAY = 4;
	
	public static final int MY_CLUB = 0;
	public static final int ALL_CLUB = 1;
	
	public static final int GAME_DETAIL = 0;
	public static final int APPLY_LIST = 1;
	
	public static final int NOTIFY_ID = 0x1010;
	
	public static final String NOTIFY_TYPE = "Notification type";
	public static final String NOTIFY_ROOM_ID = "NotifyRooomID";
	public static final String NOTIFY_CONTENT = "NotifyContent";
	
	public static final String LOGIN_ERROR = "LoginError";
	public static final String LOGOUT_ERROR = "LogoutError";
	public static final String LOGOUT_REASON = "LogoutReason";
	public static final int LOGOUT_REASON_USER = 1;
	public static final int LOGOUT_REASON_NETWORK = 2;
}
