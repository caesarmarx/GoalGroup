 	package com.goalgroup.receiver;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Handler;
import android.webkit.JsPromptResult;
import cn.jpush.android.api.JPushInterface;

import com.goalgroup.GgApplication;
import com.goalgroup.chat.component.ChatEngine;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.constants.ExtraConst;
import com.goalgroup.http.RunTimeDetailHttp;
import com.goalgroup.task.RunTimeDetailTask;
import com.goalgroup.ui.ChatActivity;
import com.goalgroup.ui.EnterReqListActivity;
import com.goalgroup.ui.GameDetailActivity;
import com.goalgroup.ui.GameResultActivity;
import com.goalgroup.ui.GameScheduleActivity;
import com.goalgroup.ui.HomeActivity;
import com.goalgroup.ui.InvGameActivity;
import com.goalgroup.ui.InvitationActivity;
import com.goalgroup.ui.NewChallengeActivity;
import com.goalgroup.ui.NewsAlarmActivity;
import com.goalgroup.ui.chat.ChatEntity;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.NetworkUtil;

public class JPushReceiver extends BroadcastReceiver {
	private Context context;
	public Handler loaderHandler = new Handler();
	public Runnable runtimeDetailLoader = new Runnable() {
		
		@Override
		public void run() {
			// TODO Auto-generated method stub
			if (!NetworkUtil.isNetworkAvailable(context))
				return;
			
			// reconnect ChatServer
			ChatEngine chatEngine = GgApplication.getInstance().getChatEngine();
			if (!chatEngine.onConnectState()){
				chatEngine.disconnect();
				chatEngine.createSocketIOManager();
				chatEngine.netConnect();
			}
						
			RunTimeDetailTask runDetailTask = new RunTimeDetailTask();
			
			String[] clubs= GgApplication.getInstance().getClubId();
			String clubIds = "";
			
			if (clubs != null) {
				for (int i = 0;i < clubs.length; i++) {
					if (clubIds.equals("")) {
						clubIds = clubs[i];
					}
					else {
						clubIds = clubIds + "," + clubs[i];
					}
				}
			}
			runDetailTask.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, GgApplication.getInstance().getUserId(), clubIds);
		}
	};
	
//	private class RunTimeDetailTask extends AsyncTask<String, String, String> {
//		
//		private RunTimeDetailHttp post;
//		
//		@Override
//		protected void onPreExecute() {
//			super.onPreExecute();
//		}
//		
//		@Override
//		protected String doInBackground(String... params) {
//			post = new RunTimeDetailHttp();
//			post.setParams(params);
//			post.run();
//			return null;
//		}
//		
//		@Override
//		protected void onPostExecute(String result) {
//			super.onPostExecute(result);
//		}
//	}
	@Override
	public void onReceive(Context ctx, Intent intent) {
		this.context = ctx;
		
		if (JPushInterface.ACTION_NOTIFICATION_RECEIVED.equals(intent.getAction())){
			String jpushExtra = (String) intent.getExtras().get(JPushInterface.EXTRA_EXTRA);
			
			switch (JSONUtil.getValueInt(jpushExtra, "FLAG")) {
			case ExtraConst.ACCEPT_INVITE_REQUEST:			//초청요청수락(2captain)- 해당구락부
			case ExtraConst.ACCEPT_TEMP_INVITE_REQUEST:		//림시초청요청수락- 해당구락부
			case ExtraConst.ACCEPT_JOIN_REQUEST:			//가맹요청수락(2player)
			case ExtraConst.SET_MEMBER_POSITION_REQUEST:	//선수배치요청- 해당구락부
				loaderHandler.post(runtimeDetailLoader);
			}
		} else if (JPushInterface.ACTION_NOTIFICATION_OPENED.equals(intent.getAction())) {
			
			String jpushExtra = (String) intent.getExtras().get(JPushInterface.EXTRA_EXTRA);
			
			switch (JSONUtil.getValueInt(jpushExtra, "FLAG")) {
			case ExtraConst.INVITE_REQUEST:					//초청요청(2player)
				
				intent = new Intent(context, InvitationActivity.class);
				intent.putExtra("FLAG", ExtraConst.INVITE_REQUEST);
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(intent);
				break;
			
			case ExtraConst.TEMP_INVITE_REQUEST:			//림시초청요청
				
				intent = new Intent(context, InvGameActivity.class);
				intent.putExtra("FLAG", ExtraConst.TEMP_INVITE_REQUEST);
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(intent);
				break;
				
			case ExtraConst.ACCEPT_INVITE_REQUEST:			//초청요청수락(2captain)- 해당구락부
			case ExtraConst.ACCEPT_TEMP_INVITE_REQUEST:	//림시초청요청수락- 해당구락부
			case ExtraConst.ACCEPT_JOIN_REQUEST:			//가맹요청수락(2player)
			case ExtraConst.SET_MEMBER_POSITION_REQUEST:	//선수배치요청- 해당구락부
				
				/*intent = new Intent(context, ChatActivity.class);
				intent.putExtra(ChatConsts.CHAT_TYPE_TAG, ChatConsts.FROM_MEETING);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, JSONUtil.getValueInt(jpushExtra, "CLUB_ID"));
				intent.putExtra("FLAG", ExtraConst.ACCEPT_INVITE_REQUEST);
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(intent);*/
				intent = new Intent(context, HomeActivity.class);
				intent.putExtra("FLAG", ExtraConst.ACCEPT_INVITE_REQUEST);
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(intent);
				break;
			
			case ExtraConst.ADD_PROCLAIM_REQUEST:			//포고추가요청- 해당구락부 포고목록
			case ExtraConst.CREATE_DISCUSS_CHATROOM_REQUEST:	//대화방챠팅창조요청
				
				/*intent = new Intent(context, ChatActivity.class);
				intent.putExtra(ChatConsts.CHAT_TYPE_TAG, ChatConsts.FROM_DISCUSS);
				intent.putExtra(ChatConsts.CREATE_CLUB_ID_TAG, JSONUtil.getValueInt(jpushExtra, "CREATE_CLUB_ID"));
				intent.putExtra(ChatConsts.CLUB_ID_TAG, JSONUtil.getValueInt(jpushExtra, "CLUB_ID"));
				intent.putExtra(ChatConsts.GAME_ID, JSONUtil.getValueInt(jpushExtra, "GAME_ID"));
				intent.putExtra(ChatConsts.CHALLENGE_ID, JSONUtil.getValueInt(jpushExtra, "CHALLENGE_ID"));
				intent.putExtra("FLAG", ExtraConst.ADD_PROCLAIM_REUQEUST);
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(intent);*/
				
				intent = new Intent(context, NewsAlarmActivity.class);
				intent.putExtra("FLAG", ExtraConst.ADD_PROCLAIM_REQUEST);
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(intent);
				break;
				
			case ExtraConst.REGISTER_USER2CLUB_REQUEST:		//구락부사용자등록(2captain)- 해당구락부가맹신청화면

				intent = new Intent(context, EnterReqListActivity.class);
				intent.putExtra("FLAG", ExtraConst.REGISTER_USER2CLUB_REQUEST);
				intent.putExtra("CLUB_ID", JSONUtil.getValueInt(jpushExtra, "CLUB_ID"));
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(intent);
				break;
				
			case ExtraConst.DISMISS_CLUB_REQUEST:			//구락부탈퇴
			case ExtraConst.BREAK_CLUB_REQUEST:				//구락부해체
				
				intent = new Intent(context, HomeActivity.class);
				intent.putExtra("FLAG", ExtraConst.DISMISS_CLUB_REQUEST);
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(intent);
				break;
				
			case ExtraConst.DELETE_CHALLEANGE_REQUEST:		//도전취소요청
				
				intent = new Intent(context, HomeActivity.class);
				intent.putExtra("FLAG", ExtraConst.DELETE_CHALLEANGE_REQUEST);
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(intent);
				break;
				
			case ExtraConst.RESIGN_GAME_REQUEST:				//경기포기요청-해당 경기일정
			case ExtraConst.AGREE_GAME_REQUEST:				//경기응전요청-해당 경기일정
				
				intent = new Intent(context, GameScheduleActivity.class);
				//intent = new Intent(context, HomeActivity.class);
				intent.putExtra("FLAG", ExtraConst.RESIGN_GAME_REQUEST);
				intent.putExtra(CommonConsts.SCHEDULE_FROM_TAG, CommonConsts.SCHEDULE_FROM_CHAT);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, JSONUtil.getValueInt(jpushExtra, "CLUB_ID"));
				intent.putExtra(ChatConsts.REQ_USER_ID, Integer.valueOf(GgApplication.getInstance().getUserId()));
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(intent);
				break;
			
			case ExtraConst.SET_GAME_RESULT_REQUEST:			//경기결과설정요청-경기성적입력화면
								
				intent = new Intent(context, GameResultActivity.class);
				intent.putExtra("FLAG", ExtraConst.RESIGN_GAME_REQUEST);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, JSONUtil.getValueInt(jpushExtra, "CLUB_ID"));
				intent.putExtra(ChatConsts.GAME_ID, JSONUtil.getValueInt(jpushExtra, "GAME_ID"));
				intent.putExtra(ChatConsts.GAME_STATE, CommonConsts.GAME_STATE_FINISHED);
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(intent);
				break;
				
			default:
				break;
			}
		}
	}
}