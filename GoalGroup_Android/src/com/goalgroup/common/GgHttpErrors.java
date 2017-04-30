package com.goalgroup.common;

public class GgHttpErrors {
	public static final int GETOFFLINEDATA_ERROR=0;
	public static final int GETOFFLINEDATA_SUCCESS=1;
	
	public static final int NONE_NETWORK = 0;
	
	public static final int LOGIN_CONNECTION = 0;
	public static final int LOGIN_SUCCESS = 1;
	public static final int LOGIN_NO_REGISTED = 2;
	public static final int LOGIN_PASSWORD = 3;
	public static final int LOGIN_INAVAILABLE = 4;
	
	public static final String LOGIN_ERROR_SUCCESS = "1";
	public static final String LOGIN_ERROR_NO_REGISTED = "2";
	public static final String LOGIN_ERROR_PASSWORD = "3";
	public static final String LOGIN_ERROR_INAVAILABLE = "4";
	
	public static final int GET_CHALL_FAIL = 0;
	public static final int GET_CHALL_SUCCESS = 1;
	
	public static final int SEND_CHALL_FAIL = 0;
	public static final int SEND_CHALL_SUCCESS = 1;
	
	public static final int USER_REGISTER_FAIL1 = 0;
	public static final int USER_REGISTER_SUCCESS = 1;
	public static final int USER_REGISTER_FAIL2 = 2;
	
	public static final int INVITE_GAME_FAIL = 0;
	public static final int INVITE_GAME_SUCCESS = 1;
	public static final int INVITE_GAME_REPEATE = 2;
	
	public static final int HTTP_POST_FAIL = 0;
	public static final int HTTP_POST_SUCCESS = 1;

}
