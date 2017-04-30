package com.goalgroup.chat.info;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;

import android.content.Context;
import android.util.Log;

import com.goalgroup.GgApplication;
import com.goalgroup.chat.component.ChatEngine;
import com.goalgroup.chat.info.history.ChatBean;
import com.goalgroup.chat.info.history.ChatHistoryDB;
import com.goalgroup.chat.info.history.ChatRoomDB;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.chat.util.ChatUtil;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.ui.chat.EmoteUtil;
import com.goalgroup.utils.FileUtil;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.BinaryHttpResponseHandler;
import com.loopj.android.http.GgHttpResponseHandler;

public class GgChatInfo {
	
	ChatHistoryDB historyDB;
	ChatRoomDB roomDB;
	ArrayList<ChatRoomInfo> rooms;
	
	private String download_filename = "";
	private File dir = new File(FileUtil.getFullPath(""));
	
	public GgChatInfo() {
		rooms = new ArrayList<ChatRoomInfo>();
		
		initChatRooms();
	}
	
	public void initChatRooms() {
		rooms.clear();
		
		ChatRoomInfo info = new ChatRoomInfo();
		rooms.add(info);
	}

	public ArrayList<ChatRoomInfo> getChatRooms() {
		return rooms;
	}
	
	public void setChatRooms(ArrayList<ChatRoomInfo> rooms) {
		this.rooms = rooms;
	}
	public void initClubChatRoom(String[] infos) {
		for (String info : infos) {
			int room_id = JSONUtil.getValueInt(info, "room_id");
			addClubChatRoom(Integer.parseInt(JSONUtil.getValue(info, "club_id")), 
						JSONUtil.getValue(info, "club_name"), 
						room_id, 
						ChatConsts.CHAT_ROOM_MEETING);
			roomDB.insertRoom(room_id);
		}
	}
	
	/**
	 * 구락부마당의 대화방을 추가하는 메쏘드
	 * 
	 * @param club_id : 추가되는 대화방의 구락부 ID
	 * @param club_name : 추가되는 대화방의 구락부이름
	 * @param room_id : 추가되는 대화방의 ID
	 * @param chat_type : 대화방의 형식
	 */
	public void addClubChatRoom(int club_id, String club_name, int room_id, int chat_type) {
		if (getChatRoom(room_id) != null)
			return;
		
		ChatRoomInfo roomInfo = new ChatRoomInfo(room_id, chat_type, club_id, club_name);
		rooms.add(roomInfo);
		roomDB.insertRoom(room_id);
	}
	
	/**
	 * 상의마당대화방을 초기화한다.
	 * 
	 * @param infos: 로그인시 봉사기로부터 접수받은 상의마당대화방정보문자렬의 배렬
	 */
	public void initDiscussRoom(String[] infos) {
		for (String info : infos) {
			int room_id = JSONUtil.getValueInt(info, "chat_room_id");
			addDiscussChatRoom(room_id, JSONUtil.getValue(info, "chat_room_title"));
			roomDB.insertRoom(room_id);
		}
	}
	
	/**
	 * 상의마당의 대화방을 추가하는 메쏘드
	 * 
	 * @param room_id: 추가되는 상의마당의 대화방ID
	 * @param room_title: 추가되는 상의마당의 대화방이름
	 */
	public void addDiscussChatRoom(int room_id, String room_title) {
		if (getChatRoom(room_id, room_title) != null)
			return;
		
		ChatRoomInfo roomInfo = new ChatRoomInfo(room_id, room_title);
		roomDB.insertRoom(room_id);
		rooms.add(roomInfo);
	}
	
	// 함수기능: 로그인을 진행한 다음 로그오프상태에서 받지 못하였던 메쎄지들을 처리한다.
	// 파라메터:
	// value - 변환하려는 문자렬
	// 출력값:
	// 없음
	public void setOfflineChatData(String[] offlineDatas) {
		int lastType = -1;
		for (String data : offlineDatas) {
			int room_id = JSONUtil.getValueInt(data, "chat_room_id");
			String msg = JSONUtil.getValue(data, "content");
			String newMsg = "";
			int len = msg.length();
			for (int k = 0; k < len; k++) {
				if (msg.charAt(k) == '`') {
					int next = msg.indexOf("`", k + 1);
					String idstr = msg.substring(k, next+1);

					int index = StringUtil.findIDfromArray(EmoteUtil.emoArgs, idstr);
					String str = "╬" + EmoteUtil.emoImageIDs[index] + "╬";

					newMsg = newMsg + str;

					k = next;
				} else {
					newMsg = newMsg + msg.charAt(k);
				}
			}
			msg = newMsg;
			String time = JSONUtil.getValue(data, "sendtime");
			
			ChatEngine chatEngine = GgApplication.getInstance().getChatEngine();
			if (chatEngine.isNewDiscussRoom(msg) || chatEngine.isUpdateDiscussRoom(msg))
				continue;
				
			if(msg.endsWith("jpg")) {
				
				download_filename = "pic_down_" + GgApplication.getInstance().getUserId() + "_";

				long now = System.currentTimeMillis();
				String nowMilliSecString = String.valueOf(now);
				download_filename = download_filename.concat(nowMilliSecString);
				download_filename = download_filename.concat(".jpg");
				
				AsyncHttpClient httpIMGClient = new AsyncHttpClient();
				httpIMGClient.setTimeout(10000);
				String[] allowContents = { "image/jpeg", "image/bmp", "image/png" };

				httpIMGClient.get(msg, new BinaryHttpResponseHandler(allowContents) {
					@Override
					public void onSuccess(byte[] buffer) {
						FileUtil.writeFile(FileUtil.getFullPath(download_filename), buffer);
					}

					@Override
					public void onFailure(Throwable error, String content) {
					}
				});
				
			} else if(msg.endsWith("gga")) {
				download_filename = "audio_user_" + GgApplication.getInstance().getUserId() + "_";
				
				long now = System.currentTimeMillis();
				String nowMilliSecString = String.valueOf(now);
				download_filename = download_filename.concat(nowMilliSecString);
				download_filename = download_filename.concat(".gga");
				
				AsyncHttpClient httpIMGClient = new AsyncHttpClient();
				httpIMGClient.setTimeout(10000);

				httpIMGClient.get(msg, new GgHttpResponseHandler() {
					@Override
					public void onSuccess(byte[] buffer) {
						FileUtil.writeFile(FileUtil.getFullPath(download_filename), buffer);
					}

					@Override
					public void onFailure(Throwable error, String content) {
					}
				});
			}			
			
			msg = (msg.endsWith("jpg") || msg.endsWith("gga")) ? download_filename : msg;
			String sender_name = JSONUtil.getValue(data, "sender_name");
			
			chatEngine.updateMsgHistory(msg, ChatUtil.getMsgType(msg), room_id, sender_name, JSONUtil.getValueInt(data, "sender_id"), 
					time, JSONUtil.getValue(data, "sender_photo"), false, true);
			
			ChatRoomInfo room = getChatRoom(room_id);
			room.incUnreadCount();
			
			lastType = room.getRoomType();
			GgApplication.getInstance().getChatEngine().showNotification(lastType, sender_name, msg, room_id);
		}
	}
	
	//함수기능: 실시간변동자료에 의한 대화방의 읽지 않은 기사개수를 설정한다.
	//파라메터:
	//room_id - 대화방아이디
	//count - 읽지않은 대화개수
	public void setUnreadMsgCountInRoom(int room_id, int count)
	{
		ChatRoomInfo room = getChatRoom(room_id);
		
		if (room == null) return;
		
		room.setUnreadCount(count);
	}
	
	
	public int getClubChatRoomId(int clubId) {
		int ret = -1;
		for (ChatRoomInfo room : rooms) {
			if (room.getClubId01() == clubId && room.getRoomType() == 0) {
				ret = room.getRoomId();
				break;
			}
		}
		
		return ret;
	}
	
	public ChatRoomInfo getClubChatRoom(int clubId) {
		return getChatRoom(getClubChatRoomId(clubId));
	}
	
	public ChatHistoryDB getChatHistDB() {
		return historyDB;
	}
	
	public ChatRoomDB getChatRoomDB() {
		return roomDB;
	}
	
	public void openChatHistDB(Context ctx) {
		historyDB = new ChatHistoryDB(ctx);
	}
	
	public void openChatRoomDB(Context ctx) {
		roomDB = new ChatRoomDB(ctx);
	}
	
	public void closeDBs() {
		if (historyDB != null) {
			historyDB.close();
			historyDB = null;
		}
		
		if (roomDB != null) {
			roomDB.close();
			roomDB = null;
		}
	}
	
	/**
	 * 
	 * @param id
	 * @return
	 */
	public int getDiscussRoomId(int team1, int team2, int type, int gameId) {
		int ret = -1;
		for (ChatRoomInfo room : rooms) {
			if (room.getClubId01() != team1) continue;
			if (room.getClubId02() != team2) continue;
			if (room.getGameType() != type) continue;
			if (room.getGameId() != gameId) continue;
			
			ret = room.getRoomId();
			break;
		}
		
		return ret;
	}
	
	// 함수기능: 대화방번호로부터 대화방정보를 얻는다.
	// 파라메터:
	// id - 대화방번호(room_id)
	// 출력값:
	// 파라메터로 들어온 방번호(room_id)에 해당한 대화방정보를 돌려준다.
	public ChatRoomInfo getChatRoom(int id) {
		ChatRoomInfo ret = null;
		for (ChatRoomInfo room : rooms) {
			if (room.getRoomId() == id) {
				ret = room;
				break;
			}
		}
		return ret;
	}
	
	public ChatRoomInfo getChatRoom(int id, String title) {
		ChatRoomInfo ret = null;
		for (ChatRoomInfo room : rooms) {
			if (room.getRoomId() == id) {
				if (!room.getRoomTitle().equals(title))
					room.getRoomInfoByTitle(title);
				ret = room;
				break;
			}
		}
		return ret;
	}
	
	/**
	 * 현재 상의마당에서 읽지 않은 전체대화개수를 얻는다. 
	 */
	public int getUnreadNewsCount() {
		int ret = 0;
		if (rooms == null)
			return 0;
		try { 
			for (ChatRoomInfo room : rooms) {
				if (room.getRoomType() != ChatConsts.CHAT_ROOM_DISCUSS)
					continue;
				ret = ret + room.getUnreadCount();
			}
			} catch (Exception e) {
				ret = -1;
			}
		return ret;
	}
	
	/**
	 * 지적된 대화방에 마지막대화내용과 대화시간을 설정한다.
	 * 파라메터:
	 * room_id - 대화방의 번호
	 * msg - 마지막대화내용
	 * time - 마지막대화시간
	 */
	public void setLastChatContent(int room_id, String userName, String msg, String time) {
		for (ChatRoomInfo room : rooms) {
			if (room.getRoomId() != room_id)
				continue;
			
			room.setLastContent(ChatUtil.getMsgTypeStr(userName, msg));
			room.setLastTime(time);
		}
	}
	
	/**
	 * 지적된 구락부아이드를 가진 대화방을 삭제한다.
	 */
	public void removeChatRooms(int clubId) {
		for (int nlp = rooms.size() - 1; nlp > 0; nlp--) {
			ChatRoomInfo room = rooms.get(nlp);
			if (room.getClubId01() == clubId || 
				room.getClubId02() == clubId) {
				roomDB.deleteRoom(room.getRoomId());
				rooms.remove(nlp);
			}
		}
	}
	
	/** 지적된 room_id의 대화방을 삭데한다.
	 * 
	 * @param roomId
	 */
	public void removeChatDiscussRoom(int roomId) {
		for (int nlp = rooms.size() - 1; nlp > 0; nlp--) {
			ChatRoomInfo room = rooms.get(nlp);
			if (room.getRoomId() == roomId){
//				roomDB.deleteRoom(roomId);
				room.setUnreadCount(0);
				room.setLastContent("");
//				rooms.remove(nlp);
			}
		}
	}
}
