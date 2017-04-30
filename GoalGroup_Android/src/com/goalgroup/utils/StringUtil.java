package com.goalgroup.utils;

import java.util.Date;

import com.goalgroup.GgApplication;
import com.goalgroup.constants.CommonConsts;

public class StringUtil {
	
	public static boolean isEmpty(String src) {
		return ((src == null) || ("".equals(src)));
	}
	
	public static String getPicURL(String src) {
		if (StringUtil.isEmpty(src))
			return "";
		return "http://218.61.196.230:9449".concat(src);
	}
	
	public static String validFloat(String src) {
		String ret = "";
		
		try {
			float value = Float.parseFloat(src);
			ret = String.format("%.02f", value);
		} catch (NumberFormatException ex) {
			ex.printStackTrace();
		}
		
		return ret;
	}
	
	public static String validInt(String src) {
		String ret = "";
		
		try {
			int value = Integer.parseInt(src);
			ret = String.format("%d", value);
		} catch (NumberFormatException ex) {
			ex.printStackTrace();
		}
		
		return ret;
	}
	
	private static String[] ageCond = {
		"18岁以下", "18-25", "26-33", "34-41", "42-49", "50以上"
	};
	
	public static int getAge(boolean[] selAgeConds, int type) {
		int age;
		int i = 0;
		
		while(i < 6 && selAgeConds[i] == false) {
			i++;
		}
		
		if (i == 0)
			age = (type == CommonConsts.MAX_AGE) ? 18 : 0; 
		else if (i == 5)
			age = (type == CommonConsts.MAX_AGE) ? 100 : 50;
		else if (i == 6)
			age = (type == CommonConsts.MAX_AGE) ? 100 : 0;
		else {
			String ages[] = new String[2];
			ages = ageCond[i].split("-");
			age = (type == CommonConsts.MAX_AGE) ? Integer.valueOf(ages[1]) : Integer.valueOf(ages[0]);
		}
		return age;
			
	}
	
	private static String[] week_day = {
		"周一", "周二", "周三", "周四", "周五", "周六", "周日"
	};
	
	public static int getWeekDayIndex(String dateTime) {
		Date date = new Date(Integer.parseInt(dateTime.split("-")[0]) - 1900,
				Integer.parseInt(dateTime.split("-")[1]) - 1,
				Integer.parseInt(dateTime.split("-")[2]));
		return date.getDay();
	}
	
	public static String getWeekDay(String index) {
		int idx = Integer.parseInt(index);
		if (idx == 0)
			return week_day[6];
		return week_day[idx-1]; 
			
	}
	
	public static String getWeekDay(int index) {
		if (index == 0)
			return week_day[6];
		return week_day[index-1];
	}
	
//	public static String getWeekDays(int value) {
//		int a, b, index = 0;
//		String ret = "";
//		
//		do {
//			a = value / 2;
//			b = value % 2;
//			if (b != 0) {
//				ret = ret.concat(week_day[index]);
//				if (a != 0)
//					ret = ret.concat(", ");
//			}
//			index++;
//		} while ((value = a) != 0);
//		
//		return ret;
//	}
	
	private static String[] sex = {
		"男", "女"
	};
	
	public static String getSex(int value) {
		if (value == 1)
			return sex[0];
		else if(value == 2)
			return sex[1];
		else 
			return "";
	}
	
	public static int getSexID(String strSex) {
		int val;
		if (strSex.equals(sex[0]))
			val = 1;
		else if (strSex.equals(sex[1]))
			val = 2;
		else val = 1;
		return val;
	}
	
	public static int getCityID(String strCity) {
		int cityID = 0;
		String cityName[] = new String[GgApplication.getInstance().getCityID().length];
		cityName = GgApplication.getInstance().getCityName();
		for (int i = 0; i < cityName.length; i++)
			if (strCity.equals(cityName[i]))
				 cityID = Integer.valueOf(GgApplication.getInstance().getCityID()[i]);
		return cityID;
	}
	
	public static String getIDsFromSelected(String[] IDs, boolean[] selected) {
		
		String ret = "";
		int count = IDs.length;
		int i = 0;
		
		do {
			if (selected[i]){
				ret = ret.concat(IDs[i]);
				ret = ret.concat(", ");
			}
			i++;
		} while (i < count);
		if (!isEmpty(ret))
			ret = ret.substring(0, ret.length()-2);
		return ret;
	}
	
	public static int getDistrictID(String strDistrict) {
		int districtID = 0;
		String districtName[] = new String[GgApplication.getInstance().getDistrictID().length];
		districtName = GgApplication.getInstance().getDistrictName();
		for (int i = 0; i < districtName.length; i++)
			if (strDistrict.equals(districtName[i]))
				districtID = Integer.valueOf(GgApplication.getInstance().getDistrictID()[i]);
		return districtID;
	}
	
	public static int getBinData(boolean selected[]) {
		int value = 0;
		for (int i = 0; i < selected.length; i++)
			if (selected[i]) {
				value = value + (int)(Math.pow(2, i));
			}
		return value;
	}
	
	public static int getPosData(boolean selected[]) {
		int value = 0;
		int startpos = 0;
		int endpos = 0;
		for (int i = 0; i < selected.length; i++)
			if (selected[i]) {
				switch (i){
				case 0:
					startpos = 0;
					endpos = 3;
					break;
				case 1:
					startpos = 3;
					endpos = 7;
					break;
				case 2:
					startpos = 7;
					endpos = 10;
					break;
				case 3:
					startpos = 10;
					endpos = 11;
				}
				for (int j = startpos; j < endpos; j++)
					value = value + (int)(Math.pow(2, j));
			}
		return value;
	}
	
//	private static int squareOf(int num, int count) {
//		int value = 1;
//		for (int i = 0; i < count; i++)
//			value = value * num;
//		return value;
//	}
	
	private static String[] position = {
		"前锋【中锋】", "前锋【二前锋】", "前锋【边锋】", "中场【前腰】", "中场【前卫】", "中场【边前卫】", "中场【后腰】", "后卫【边后卫】", "后卫【中后卫】", "后卫【盯人中卫】", "门将"
	};
	
//	public static String getPositions(int value) {
//		int a, b, index = 0;
//		String ret = "";
//		
//		do {
//			a = value / 2;
//			b = value % 2;
//			if (b != 0) {
//				ret = ret.concat(position[index]);
//				if (a != 0)
//					ret = ret.concat(", ");
//			}
//			
//			index++;
//		} while ((value = a) != 0);
//		
//		return ret;
//	}
	
	public static String getStrFromSelValue(int value, int type) {
		String name[] = new String[0];
		if (type == CommonConsts.POSITION)
			name = position;
		else if (type == CommonConsts.ACT_DAY)
			name = week_day;
		
		int a, b, index = 0;
		String ret = "";
		
		do {
			a = value / 2;
			b = value % 2;
			if (b != 0) {
				ret = ret.concat(name[index]);
				if (a != 0) {
					if(type == CommonConsts.POSITION)
						ret = ret + "\n";
					else
						ret = ret.concat(", ");
				}
			}
			
			index++;
		} while ((value = a) != 0);
		
		return ret;
	}
	
	public static boolean[] getSelectedFromValue(boolean[] selected, int value) {
		int a, b, index = 0;
		
		do {
			a = value / 2;
			b = value % 2;
			if (b != 0) {
				selected[index] = true;
			}
			index++;
		} while ((value = a) != 0);
		return selected;
	}
	
	public static String[] getOptions(int value) {
		int a, b, index = 0;
		String ret = "";
		
		do {
			a = value / 2;
			b = value % 2;
			if (b != 0) {
				ret = ret.concat(String.valueOf((int)Math.pow(2,index)));
				if (a != 0)
					ret = ret.concat(",");
			}
			
			index++;
		} while ((value = a) != 0);
		String[] option = ret.split(",");
		return option;
	}
	
	public static int getOption(String[] value) {
		int result = 0;
		for (int i = 0; i < value.length; i++)
			result += Integer.valueOf(value[i]);
		
		return result;
	}
	
	public static int getSelectedItem(String[] arrName, String name) {
		if (arrName == null)
			return 0;
		
		for (int i = 0; i < arrName.length; i++) {
			if (name.equals(arrName[i]))
				return i;
		}
		return 0;
	}
	
	public static int getValueTime(int month, int date, int hour) {
		int value;
		
		value = month * 30 * 24;
		value = value + date * 24;
		value = value + hour;
		
		return value;
	}
	
	public static boolean dateCompare4(int year, int month, int date, int hour) {
		Date now = new Date();
		if ((now.getYear()+1900) < year)
			return true;
		
		if (now.getMonth() < month)
			return true;
		
		int nowValue = getValueTime(now.getMonth(), now.getDate(), now.getHours()+4);
		int newValue = getValueTime(month, date, hour);
		
		if (nowValue > newValue)
			return false;
		
		return true;
	}
	
	public static int findIDfromArray(String[] strArr, String substr){
		if (strArr.length == 0)
			return 0;
		
		for (int i = 0; i < strArr.length; i++) {
			if (strArr[i].equals(substr))
				return i;
		}
		
		return 0;
	}
	
	public static int findIDfromArray(Integer[] intArr, int index){
		if (intArr.length == 0)
			return 0;
		
		for (int i = 0; i < intArr.length; i++) {
			if (intArr[i] == index)
				return i;
		}
		
		return 0;
	}
}
