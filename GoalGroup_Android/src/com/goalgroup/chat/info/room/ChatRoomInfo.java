package com.goalgroup.chat.info.room;

import com.goalgroup.GgApplication;
import com.goalgroup.chat.info.history.ChatRoomDB;
import com.goalgroup.chat.util.ChatUtil;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.utils.StringUtil;

public class ChatRoomInfo {
	private int room_id;
	private String room_title;
	private int type;
	private int club_id_01 = -1;
	private String club_mark_01 = "";
	private String club_name_01 = "";
	private int club_id_02 = -1;
	private String club_mark_02 = "";
	private String club_name_02 = "";
	private int game_type;
	private int game_id;
	private int chall_state;
	private int game_state;
	private String game_date = "";
	private String game_time = "";
	private int player_count = 0;
	private String lastchat_content = "";
	private String lastchat_time = "";
	
	public ChatRoomInfo() {
		this.type = ChatConsts.CHAT_ROOM_MANAGER;
		setRoomTitle();
	}
	
	public ChatRoomInfo(int room_id, int type, int club_id_01, String club_name_01) {
		this.room_id = room_id;
		this.type = type;
		this.club_id_01 = club_id_01;
		this.club_name_01 = club_name_01;
		setRoomTitle(club_name_01);
	}
	
	public ChatRoomInfo(int room_id, String room_title) {
		this.room_id = room_id;
		this.type = ChatConsts.CHAT_ROOM_DISCUSS;
		if (getRoomInfoByTitle(room_title)) {
			setRoomTitle();
		}
	}
	
	public void setRoomTitle(Object... params) {
		room_title = "";
		switch (type) {
		case ChatConsts.CHAT_ROOM_MEETING:
			room_title = (String)params[0];
			room_title = room_title.concat(" - ");
			room_title = room_title.concat("俱乐部大厅");
			break;
		case ChatConsts.CHAT_ROOM_DISCUSS:
			room_title = club_id_01 + "::" 
					+ club_name_01 + "::"
					+ club_id_02 + "::"
					+ club_name_02 + "::"
					+ game_type + "::"
					+ game_id + "::"
					+ game_date + " " + game_time + "::"
					+ player_count + "::"
					+ club_mark_01 + "::"
					+ club_mark_02 + "::"
					+ chall_state + "::"
					+ game_state;
			break;
		case ChatConsts.CHAT_ROOM_MANAGER:
			room_title = "平台信息";
			break;
		}
	}
	
	public String getRoomTitle() {
		return room_title;
	}
	
	public int getRoomId() {
		return room_id;
	}
	
	public int getClubId01() {
		return club_id_01;
	}
	
	public String getClubName01() {
		return club_name_01;
	}
	
	public int getClubId02() {
		return club_id_02;
	}
	
	public String getClubName02() {
		return club_name_02;
	}
	
	public void setClubMark01(String value) {
		this.club_mark_01 = value;
	}
	
	public String getClubMark01() {
		return club_mark_01;
	}
	
	public void setClubMark02(String value) {
		this.club_mark_02 = value;
	}
	
	public String getClubMark02() {
		return club_mark_02;
	}
	
	public int getRoomType() {
		return type;
	}
	
	public void setRoomType(int value) {
		this.type = value;
	}
	
	public int getGameType() {
		return game_type;
	}
	
	public void setGameType(int type) {
		this.game_type = type;
	}
	
	public int getGameId() {
		return game_id;
	}
	
	public int getPlayerCount() {
		return player_count;
	}
	
	public void setPlayerCount(int value) {
		this.player_count = value;
	}
	
	public void setGameDate(String date) {
		this.game_date = date;
	}
	
	public void setGameTime(String time) {
		this.game_time = time;
	}

	public void setLastContent(String value) {
		lastchat_content = value;
	}
	
	public String getLastContent() {
		return lastchat_content;
	}
	
	public void setLastTime(String value) {
		lastchat_time = value;
	}
	
	public String getLastTime() {
		return lastchat_time;
	}
	
	public void setChallState(int value) {
		chall_state = value;
	}
	
	public int getChallState() {
		return chall_state;
	}
	
	public void setGameState(int value) {
		game_state = value;
	}
	
	public int getGameState() {
		return game_state;
	}
	
	public String getSimple() {
		String result = "";
		if(!lastchat_time.equals("")) {
			result = lastchat_time.split(" ")[0].split("-")[1] + "-"
					+ lastchat_time.split(" ")[0].split("-")[2];
			result = result + " " + lastchat_time.split(" ")[1].split(":")[0] + ":"
					+ lastchat_time.split(" ")[1].split(":")[1];
		}
		return result;
	}
	
	public String getSimpleGameDate() {
		String result = "";
		if(!game_date.equals("")) {
			result = game_date.split("-")[1] + "-"
					+ game_date.split("-")[2];
			String date = result;
			date = date.concat("/");
			date = date.concat(StringUtil.getWeekDay(StringUtil.getWeekDayIndex(game_date)));
			result = date + " " + game_time.split(":")[0] + ":"
					+ game_time.split(":")[1];
		}
		return result;
	}
	
//	public void updateLastContentTime(String content, String time) {
//		if (lastchat_time.compareTo(time) > 0)
//			return;
//		
//		setLastContent(ChatUtil.getMsgTypeStr(content));
//		setLastTime(time);
//	}
	
	public int getUnreadCount() {
		int ret = 0;
		ChatRoomDB roomDB = GgApplication.getInstance().getChatInfo().getChatRoomDB();
		if (roomDB != null) {
			ret = roomDB.getUnreadCount(room_id);
		}
		
		return ret;
	}
	
	public void incUnreadCount() {
		ChatRoomDB roomDB = GgApplication.getInstance().getChatInfo().getChatRoomDB();
		if (roomDB != null) {
			roomDB.incUnreadCount(room_id);
		}
	}
	
	public void resetUnreadCount() {
		ChatRoomDB roomDB = GgApplication.getInstance().getChatInfo().getChatRoomDB();
		if (roomDB != null) {
			roomDB.resetUnreadCount(room_id);
		}
	}
	
	public void setUnreadCount(int count){
		ChatRoomDB roomDB = GgApplication.getInstance().getChatInfo().getChatRoomDB();
		if (roomDB != null) {
			roomDB.setUnreadCount(room_id, count);
		}
	}
	
	private static final int TITLE_INFO_ITEM_COUNT = 12;
	private static final int IDX_CLUB_ID_01 = 0;
	private static final int IDX_CLUB_NAME_01 = 1;
	private static final int IDX_CLUB_ID_02 = 2;
	private static final int IDX_CLUB_NAME_02 = 3;
	private static final int IDX_GAME_TYPE = 4;
	private static final int IDX_GAME_INDEX = 5;
	private static final int IDX_GAME_DATE_TIME = 6;
	private static final int IDX_GAME_PLAYER_COUNT = 7;
	private static final int IDX_CLUB_MARK_01 = 8;
	private static final int IDX_CLUB_MARK_02 = 9;
	private static final int IDX_CHALL_STATE = 10;
	private static final int IDX_GAME_STATE = 11;
	
	/**
	 * 대화방의 이름으로부터 대화방의 정보를 얻는다.
	 * 
	 * @param title: 봉사기로부터 받은 형식의 대방화방이름
	 * 
	 * 귀환값: 정보얻기결과
	 */
	public boolean getRoomInfoByTitle(String title) {
		if (StringUtil.isEmpty(title))
			return false;
		
		String[] items = title.split("::");
		if (items == null || items.length != TITLE_INFO_ITEM_COUNT)
			return false;
		
		club_id_01 = Integer.parseInt(items[IDX_CLUB_ID_01]);
		club_name_01 = items[IDX_CLUB_NAME_01];
		club_id_02 = Integer.parseInt(items[IDX_CLUB_ID_02]);
		club_name_02 = items[IDX_CLUB_NAME_02];
		game_type = Integer.parseInt(items[IDX_GAME_TYPE]);
		game_id = Integer.parseInt(items[IDX_GAME_INDEX]);
		String game_date_time = items[IDX_GAME_DATE_TIME];
		String[] dateArray = game_date_time.split(" ");
		game_date = dateArray[0];
		game_time = dateArray[1];
		player_count = Integer.parseInt(items[IDX_GAME_PLAYER_COUNT]);
		club_mark_01 = items[IDX_CLUB_MARK_01];
		club_mark_02 = items[IDX_CLUB_MARK_02];
		chall_state = Integer.parseInt(items[IDX_CHALL_STATE]);
		game_state = Integer.parseInt(items[IDX_GAME_STATE]);
		return true;
	}
}
