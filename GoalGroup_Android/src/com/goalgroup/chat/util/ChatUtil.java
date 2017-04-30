package com.goalgroup.chat.util;

import com.goalgroup.constants.ChatConsts;
import com.goalgroup.utils.StringUtil;

public class ChatUtil {
	
	public static int getMsgType(String msg) {
		int ret = ChatConsts.MSG_TEXT;
		if (msg.endsWith("jpg")) {
			ret = ChatConsts.MSG_IMAGE;
		} else if(msg.endsWith("gga")) {
			ret = ChatConsts.MSG_AUDIO;
		}
		
		return ret;		
	}
	
	public static String getMsgTypeStr(String userName, String msg) {
		if (!StringUtil.isEmpty(userName))
			userName = userName + ": ";
		String ret = userName + msg;
		if (getMsgType(msg) == ChatConsts.MSG_IMAGE) {
			ret = userName + "图片";
		} else if (getMsgType(msg) == ChatConsts.MSG_AUDIO) {
			ret = userName + "语音邮件";
		}
		
		return ret;
	}
}
