package com.goalgroup.http;

import java.util.ArrayList;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.chat.info.history.ChatBean;
import com.goalgroup.chat.info.history.ChatHistoryDB;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.DateUtil;
import com.goalgroup.utils.JSONUtil;

public class LoginHttp extends GoalGroupHttpPost {
	
	private int loginError;
	private String datas;
	
	public LoginHttp() {
		super();		
		loginError = GgHttpErrors.LOGIN_CONNECTION;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "user_login"));
		post_params.add(new BasicNameValuePair("account_num", (String)params[0]));
		post_params.add(new BasicNameValuePair("password", (String)params[1]));
		post_params.add(new BasicNameValuePair("last_updated_time", GgApplication.getInstance().getPrefUtil().getLastChatTime()));
	}

	@Override
	public boolean run() {
		GgApplication.getInstance().setClientTime(DateUtil.getCurDateTime());
		
		TIME_OUT = 20000;
		try {
			postExecute();			
			getResult();
			checkResult();
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		
		return true;
	}
	
	public String getData() {
		return datas;
	}
	
	public int getLoginError() {
		return loginError;
	}
	
	private void checkResult() {
		String clubInfo[];
		String clubId[];
		String clubName[];
		int post[];
		String stadiumInfo[];
		String stadiumId[];
		String stadiumName[];
		
		String city_info[];
		String city_id[];
		String city_name[];
		String district_info[];
		String district_id[];
		String district_city_id[];
		String district_name[];
		String all_club_info[];
		String all_club_id[];
		String all_club_name[];
		
		int inv_count;
		int temp_inv_count;
		String user_photo;
		int playing_city;
		loginError = JSONUtil.getValueInt(result, "login_status");
		if (loginError == GgHttpErrors.LOGIN_SUCCESS) {
			String user_id = JSONUtil.getValue(result, "user_id");
			String user_name = JSONUtil.getValue(result, "user_name");
			int option = JSONUtil.getValueInt(result, "option");
			
			datas = JSONUtil.getValue(result, "data");
			
			clubInfo = JSONUtil.getArrays(datas, "club_info");
			clubId = new String[clubInfo.length];
			clubName = new String[clubInfo.length];
			post = new int[clubInfo.length];
			for(int i=0;i<clubInfo.length;i++) {
				clubId[i] = JSONUtil.getValue(clubInfo[i], "club_id");
				clubName[i] = JSONUtil.getValue(clubInfo[i], "club_name");
				post[i] = JSONUtil.getValueInt(clubInfo[i], "post");
			}
			
			inv_count = JSONUtil.getValueInt(result, "inv_count");
			temp_inv_count = JSONUtil.getValueInt(result, "temp_inv_count");
			user_photo = JSONUtil.getValue(result, "user_photo");
			playing_city = JSONUtil.getValueInt(result, "playing_city");
			
			GgApplication.getInstance().setUserId(user_id);
			GgApplication.getInstance().setUserName(user_name);
			GgApplication.getInstance().setOption(option);
			GgApplication.getInstance().setClubInfo(clubId, clubName, post, CommonConsts.MY_CLUB);

			GgApplication.getInstance().setInvCount(inv_count);
			GgApplication.getInstance().setTempInvCount(temp_inv_count);
			GgApplication.getInstance().setUserPhoto(user_photo);
			GgApplication.getInstance().setPlayingCity(playing_city);
			
			GgApplication.getInstance().getChatInfo().initChatRooms();
			
			GgApplication app = GgApplication.getInstance();
			app.getChatInfo().openChatHistDB(app);
			app.getChatInfo().openChatRoomDB(app);
			GgApplication.getInstance().getChatInfo().initClubChatRoom(clubInfo);
			
			String[] discuss_room = JSONUtil.getArrays(datas, "discuss_chat_room");
			GgApplication.getInstance().getChatInfo().initDiscussRoom(discuss_room);
			
			stadiumInfo = JSONUtil.getArrays(datas, "stadium_info");
			stadiumId = new String[stadiumInfo.length];
			stadiumName = new String[stadiumInfo.length];			
			for(int i = 0; i < stadiumInfo.length; i++) {
				stadiumId[i] = JSONUtil.getValue(stadiumInfo[i], "stadium_id");
				stadiumName[i] = JSONUtil.getValue(stadiumInfo[i], "stadium_name");
			}
			
			city_info = JSONUtil.getArrays(datas, "city_info");
			district_info = JSONUtil.getArrays(datas, "district_info");
			
			city_id = new String[city_info.length];
			city_name = new String[city_info.length];
			for (int i = 0; i < city_info.length; i++) {
				city_id[i] = JSONUtil.getValue(city_info[i], "id");
				city_name[i] = JSONUtil.getValue(city_info[i], "city");
			}
			
			district_id = new String[district_info.length];
			district_city_id = new String[district_info.length];
			district_name = new String[district_info.length];
			for (int i = 0; i < district_info.length; i++) {
				district_id[i] = JSONUtil.getValue(district_info[i], "id");
				district_city_id[i] = JSONUtil.getValue(district_info[i], "city");
				district_name[i] = JSONUtil.getValue(district_info[i], "district");
			}
			
			all_club_info = JSONUtil.getArrays(datas, "all_club");
			all_club_id = new String[all_club_info.length];
			all_club_name = new String[all_club_info.length];
			for (int i = 0; i < all_club_info.length; i++) {
				all_club_id[i] = JSONUtil.getValue(all_club_info[i], "club_id");
				all_club_name[i] = JSONUtil.getValue(all_club_info[i], "club_name");
			}
			
			GgApplication.getInstance().setClubInfo(all_club_id, all_club_name, null, CommonConsts.ALL_CLUB);
			GgApplication.getInstance().setStadiumInfo(stadiumId, stadiumName);
			GgApplication.getInstance().setCityInfo(city_id, city_name);
			GgApplication.getInstance().setDistrictInfo(district_id, district_city_id, district_name);
			
			String[] offlineMsgs = JSONUtil.getArrays(datas, "offline_chat_content");
			if (offlineMsgs != null && offlineMsgs.length != 0) {
				GgApplication.getInstance().getChatInfo().setOfflineChatData(offlineMsgs);
			}
			
			ChatHistoryDB historyDB = GgApplication.getInstance().getChatInfo().getChatHistDB();
			ArrayList<ChatRoomInfo> rooms = GgApplication.getInstance().getChatInfo().getChatRooms();
			
			ArrayList<ChatRoomInfo> loopRooms = rooms;
			
			for (ChatRoomInfo room : loopRooms) {
				if (room.getRoomType() != ChatConsts.CHAT_ROOM_DISCUSS)
					continue;
				
				int room_id = room.getRoomId();
				ArrayList<ChatBean> beans = historyDB.fetchMsgs(String.valueOf(room_id));
				
				int lastChatId = beans.size() - 1;
				if (lastChatId != -1) {
					ChatBean lastBean = beans.get(lastChatId);
					String lastContext = lastBean.getBuddy() + ": ";
					if (lastBean.getType() == ChatConsts.MSG_IMAGE)
						lastContext = lastContext + "图片";
					else if (lastBean.getType() == ChatConsts.MSG_AUDIO)
						lastContext = lastContext + "语音邮件";
					else if (!"".equals(lastBean.getMsg())) 
						lastContext = lastContext + lastBean.getMsg();
					else {
						rooms.remove(room);
						continue;
					}
					
					room.setLastContent(lastContext);
					room.setLastTime(beans.get(lastChatId).getTime());
				}
			}
			
			GgApplication.getInstance().getChatInfo().setChatRooms(rooms);
			
			String server_time = JSONUtil.getValue(result, "server_time");
			GgApplication.getInstance().setServerTime(server_time);
		}
		return;
	}
}