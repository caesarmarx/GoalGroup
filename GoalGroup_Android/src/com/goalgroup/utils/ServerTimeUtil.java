package com.goalgroup.utils;

import java.util.Date;

public class ServerTimeUtil {
	
	private String clientTime;
	private String serverTime;
	private long diff = 0;
	
	public ServerTimeUtil() {
	}
	
	public void setClientTime(String value) {
		clientTime = value;
	}
	
	public void setServerTime(String value) {
		serverTime = value;
	}
	
	public void getTimeDiff() {
		Date serverDate = new Date();
		serverDate.setYear(Integer.parseInt(serverTime.substring(0, 4)) - 1900);
		serverDate.setMonth(Integer.parseInt(serverTime.substring(5, 7)) - 1);
		serverDate.setDate(Integer.parseInt(serverTime.substring(8, 10)));
		serverDate.setHours(Integer.parseInt(serverTime.substring(11, 13)));
		serverDate.setMinutes(Integer.parseInt(serverTime.substring(14, 16)));
		serverDate.setSeconds(Integer.parseInt(serverTime.substring(17, 19)));
		
		Date clientDate = new Date();
		clientDate.setYear(Integer.parseInt(clientTime.substring(0, 4)) - 1900);
		clientDate.setMonth(Integer.parseInt(clientTime.substring(5, 7)) - 1);
		clientDate.setDate(Integer.parseInt(clientTime.substring(8, 10)));
		clientDate.setHours(Integer.parseInt(clientTime.substring(11, 13)));
		clientDate.setMinutes(Integer.parseInt(clientTime.substring(14, 16)));
		clientDate.setSeconds(Integer.parseInt(clientTime.substring(17, 19)));
		
		diff = serverDate.getTime() - clientDate.getTime();
	}
	
	public String getCurServerTime() {
		Date curDate = new Date();
		long curServerTime = curDate.getTime() + diff;
		
		Date serverDate = new Date(curServerTime);
		String strDate = String.valueOf(serverDate.getYear() + 1900) + "-";
		if (serverDate.getMonth() + 1 < 10)
			strDate = strDate + "0" + String.valueOf(serverDate.getMonth() + 1) + "-";
		else
			strDate = strDate + String.valueOf(serverDate.getMonth() + 1) + "-";
		if (serverDate.getDate() < 10)
			strDate = strDate + "0" + String.valueOf(serverDate.getDate()) + " ";
		else
			strDate = strDate + String.valueOf(serverDate.getDate()) + " ";
		if (serverDate.getHours() < 10)
			strDate = strDate + "0" + String.valueOf(serverDate.getHours()) + ":";
		else
			strDate = strDate + String.valueOf(serverDate.getHours()) + ":";
		if (serverDate.getMinutes() < 10)
			strDate = strDate + "0" + String.valueOf(serverDate.getMinutes()) + ":";
		else
			strDate = strDate + String.valueOf(serverDate.getMinutes()) + ":";
		if (serverDate.getSeconds() < 10)
			strDate = strDate + "0" + String.valueOf(serverDate.getSeconds());
		else
			strDate = strDate + String.valueOf(serverDate.getSeconds());
		
		return strDate;
	}
}
