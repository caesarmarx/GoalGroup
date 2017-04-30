package com.goalgroup.chat.util;


import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import org.json.JSONException;
import org.json.JSONObject;

import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.chat.component.ChatEngine;
import com.goalgroup.chat.imageupload.MOHttpClient;
import com.goalgroup.chat.imageupload.MOHttpRequest;
import com.goalgroup.chat.imageupload.MOHttpRequester;
import com.goalgroup.common.GgBroadCast;
import com.goalgroup.ui.ChatActivity;
import com.goalgroup.utils.FileUtil;
import com.goalgroup.utils.StringUtil;



public class UserFunctions {

	ChatEngine chatEngine;
	
    public UserFunctions() {
    	chatEngine = GgApplication.getInstance().getChatEngine();
	}
	
	public void loginUser(String nickname, String password) {
		JSONObject jsonObject = new JSONObject();
		try {
			jsonObject.put("nickname", nickname);
			jsonObject.put("password", password);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		chatEngine.getSocketIO().emit(ChatEngine.LOGIN, jsonObject);
	}
	
	public void registerUser(String nickname, String password) {
		JSONObject jsonObject = new JSONObject();
		try {
			jsonObject.put("nickname", nickname);
			jsonObject.put("password", password);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		chatEngine.getSocketIO().emit(ChatEngine.REGISTER, jsonObject);
	}
	
	public void sendMessage(String message, int roomID) {
		JSONObject json = new JSONObject();
		try {
			json.put("msg", message);
			json.put("room_id", roomID);
			json.put("sender_id", GgApplication.getInstance().getUserId());
			json.put("sender_name", GgApplication.getInstance().getUserName());
			json.put("sender_photo", GgApplication.getInstance().getUserPhoto());
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();		
		}
		
		if (chatEngine.getSocketIOManager() == null || chatEngine.getSocketIO() == null) {
			chatEngine.createSocketIOManager();
			chatEngine.netConnect();
		}
		
		chatEngine.getSocketIO().emit(ChatEngine.SEND_CHAT, json);
	}
	
	public void uploadImage(final String photoPath, final MOHttpRequester requester, int idx) {
		//using the normal HttpClient
		
		if(StringUtil.isEmpty(photoPath))
			return;
		
		MOHttpRequest	request = null;
		MOHttpClient	httpClient = null;
    	
    	httpClient = new MOHttpClient(idx);   
    	if(request == null)
    		request = new MOHttpRequest(ChatEngine.BASE_URL, requester);
    	
    	File file = new File(photoPath);
    	FileInputStream input = null;
    	
		try {
			input = new FileInputStream(file);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
    	
		byte[] file_buffer = new byte[ChatEngine.FILE_MAX_SIZE];
    	
    	try {
			input.read(file_buffer);
		} catch (IOException e) {
			e.printStackTrace();
		}
    	
    	request.addBinaryPostData("image_data", file_buffer, "multipart/form-data");
    	
//    	file.delete();
    	if(!httpClient.receiveRequest(request, 1)) {
    		Toast.makeText(ChatActivity.instance, "not receive the request", Toast.LENGTH_LONG).show();
    		return;
    	}
	}	
	
	public void sendImageChat(final String photo_name, final int senderID, final int roomID) {		
		
		//using the normal HttpClient
		
		MOHttpRequest	request = null;
		MOHttpClient	httpClient = null;
    	
    	httpClient = new MOHttpClient(0);   
    	if(request == null)
    		request = new MOHttpRequest(ChatEngine.BASE_URL, ChatActivity.instance);
    	
    	File file = new File(FileUtil.getFullPath(photo_name));
    	FileInputStream input = null;
    	
		try {
			input = new FileInputStream(file);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
    	
		byte[] file_buffer = new byte[ChatEngine.FILE_MAX_SIZE];
    	
    	try {
			input.read(file_buffer);
		} catch (IOException e) {
			e.printStackTrace();
		}
    	
    	request.addBinaryPostData("image_data", file_buffer, "multipart/form-data;type=img");
    	
    	if(!httpClient.receiveRequest(request, 1)) {
    		Toast.makeText(ChatActivity.instance, "not receive the request", Toast.LENGTH_LONG).show();
    		return;
    	}    	
	}
	
	public boolean sendAudioChat(final String audio_name, final int senderID, final int roomID) {		
		
		//using the normal HttpClient
		
		MOHttpRequest	request = null;
		MOHttpClient	httpClient = null;
    	
    	httpClient = new MOHttpClient(0);   
    	if(request == null)
    		request = new MOHttpRequest(ChatEngine.BASE_URL, ChatActivity.instance);
    	
    	File file = new File(FileUtil.getFullPath(audio_name));
    	FileInputStream input = null;
    	
		try {
			input = new FileInputStream(file);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return false;
		}
    	
		byte[] file_buffer = new byte[ChatEngine.FILE_MAX_SIZE];
    	
    	try {
			input.read(file_buffer);
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
    	
//    	request.setPostType(100);
    	
    	request.addBinaryPostData("audio_data", file_buffer, "multipart/form-data;type=aud");
    	
    	if(!httpClient.receiveRequest(request, 2)) {
    		Toast.makeText(ChatActivity.instance, "not receive the request", Toast.LENGTH_LONG).show();
    		return false;
    	}
    	
    	return true;
	}
	
	public void getHistoryList(String latest_time_str) {		
		JSONObject json = new JSONObject();
		try {
			json.putOpt("latest_time", latest_time_str);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();		
		}
		chatEngine.getSocketIO().emit(ChatEngine.GET_CHATHISTORY, json);
	}
	
	public void logOutUser() {
		chatEngine.getSocketIO().emit(ChatEngine.LOGOUT);
	}
	
}
