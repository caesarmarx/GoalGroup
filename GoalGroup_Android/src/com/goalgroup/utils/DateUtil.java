package com.goalgroup.utils;

import java.util.Calendar;
import java.util.Date;

public class DateUtil {
	
	public static String getCurDateTime() {
		Calendar c = Calendar.getInstance();

		String year = String.valueOf(c.get(Calendar.YEAR));
		
		String month = String.valueOf(c.get(Calendar.MONTH) + 1);
		if (month.length() != 2)
			month = "0" + month;
		
		String day = String.valueOf(c.get(Calendar.DAY_OF_MONTH));
		if (day.length() != 2)
			day = "0" + day;
		
		String hour = String.valueOf(c.get(Calendar.HOUR_OF_DAY));
		if (hour.length() != 2)
			hour = "0" + hour;
		
		String mins = String.valueOf(c.get(Calendar.MINUTE));
		if (mins.length() != 2)
			mins = "0" + mins;
		
		String secs = String.valueOf(c.get(Calendar.SECOND));
		if (secs.length() != 2)
			secs = "0" + secs;
		
		StringBuffer sbBuffer = new StringBuffer();
		sbBuffer.append(year + "-" + month + "-" + day + " " + hour + ":" + mins + ":" + secs);
		
		return sbBuffer.toString();
	}
	
	// 함수기능: 파라메터로 입력된 날자시간값을 완성한다.
	//        실례: "2015-3-24 0:01:8" -> "2015-03-24 00:01:08"
	// 파라메터:
	// value - 변환하려는 문자렬
	// 출력값:
	// 변환된 문자렬
	public static String completeDatetTime(String value) {
		String[] elems = value.split(" ");
		
		String[] date_elems = elems[0].split("-");
		date_elems[1] = completePreZero2(date_elems[1]);
		date_elems[2] = completePreZero2(date_elems[2]);
		
		String[] time_elems = elems[1].split(":");
		time_elems[0] = completePreZero2(time_elems[0]);
		time_elems[1] = completePreZero2(time_elems[1]);
		time_elems[2] = completePreZero2(time_elems[2]);
		
		String ret = date_elems[0];
		ret = ret.concat("-").concat(date_elems[1]);
		ret = ret.concat("-").concat(date_elems[2]);
		
		ret = ret.concat(" ").concat(time_elems[0]);
		ret = ret.concat(":").concat(time_elems[1]);
		ret = ret.concat(":").concat(time_elems[2]);
		
		return ret;
	}
	
	// 함수기능: 파라메터로 입력된 값을 0이 포함된 2자리수문자렬로 변환한다.
	//        날자 및 시간문자렬보정에 리용한다.
	// 파라메터:
	// value - 변환하려는 문자렬
	// 출력값:
	// 변환된 문자렬
	public static String completePreZero2(String value) {
		String ret = "01";
		if (value.length() == 1) {
			ret = "0".concat(value);
		} else if (value.length() > 2) {
			ret = value.substring(0, 2);
		} else {
			ret = value;
		}
		
		return ret;
	}
	
	public static String getMonthDate(String dateTime) {
		String result = "";
		result = dateTime.split(" ")[0].split("-")[1] + "-"
				+ dateTime.split(" ")[0].split("-")[2];
		return result;
	}

	public static String getHourMin(String dateTime) {
		String result = "";
		result = dateTime.split(" ")[1].split(":")[0] + ":"
				+ dateTime.split(" ")[1].split(":")[1];
		return result;
	}
	
	private static String removeMilliSeconds(String value) {
		return value.substring(0, value.lastIndexOf("."));
	}
	
	public static int getCurrentYear() {
		int year = new Date().getYear() + 1900;
		return year;
	}
	
	public static String getDiffTime(String orgTime) {
		
		String ret = "";
		
		try {
			Date orgDate = new Date();
			orgDate.setYear(Integer.parseInt(orgTime.substring(0, 4)) - 1900);
			orgDate.setMonth(Integer.parseInt(orgTime.substring(5, 7)) - 1);
			orgDate.setDate(Integer.parseInt(orgTime.substring(8, 10)));
			orgDate.setHours(Integer.parseInt(orgTime.substring(11, 13)));
			orgDate.setMinutes(Integer.parseInt(orgTime.substring(14, 16)));
			orgDate.setSeconds(Integer.parseInt(orgTime.substring(17, 19)));
			
			Date curDate = new Date();		
			long diff = (orgDate.getTime() - curDate.getTime()) / 1000;
			
			int hours = (int)(diff / 3600);
			int mins = (int)((diff / 60) % 60);
			int secs = (int)(diff % 60);
			
			ret = String.format("%02d:%02d:%02d", hours, mins, secs);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return ret;
	}
}
