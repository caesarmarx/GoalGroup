package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.app.Activity;
import android.app.AlertDialog;
import android.support.v4.app.Fragment;
import android.content.DialogInterface;
import android.content.Intent;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.component.ChatEngine;
import com.goalgroup.chat.info.GgChatInfo;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.ChallengeItem;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.CreateDiscussRoomTask;
import com.goalgroup.task.ResponseToGameTask;
import com.goalgroup.ui.ChatActivity;
import com.goalgroup.ui.ClubInfoActivity;
import com.goalgroup.ui.CreateClubActivity;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.fragment.ChallengeFragment;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class ChallengeListAdapter extends BaseAdapter {
	private final int CLUB_INFO = 0;
	private final int FROM_DISCUSS = 2;
	
	private final int HIDE_MENU = 0;
	private final int SHOW_MENU = 1;
	
	private Activity ctx;
	private ChallengeFragment frg;
	private ArrayList<ChallengeItem> datas;
	private int challType;
	
	
	private MyClubData mClubData;
	private GgProgressDialog dlg;
	
	private ImageLoader imgLoader;

	public ChallengeListAdapter(Activity aCtx, Fragment frgment) {
		ctx = aCtx;
		frg = (ChallengeFragment)frgment;
		datas = new ArrayList<ChallengeItem>();
		mClubData = new MyClubData();
		
		imgLoader = GgApplication.getInstance().getImageLoader();
	}
	
	@Override
	public int getCount() {
		return datas.size();
	}

	@Override
	public Object getItem(int position) {
		return datas.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}
	
	public void notifyItems() {
		notifyDataSetChanged();
	}

	private int dp2px(int dp) {
		return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp,
				GgApplication.getInstance().getBaseContext().getResources().getDisplayMetrics());	
	}
	
	@Override
	public View getView(int position, View view, ViewGroup parent) {
		ChallengeItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.challenge_list_adapter, null);
			
			holder = new ViewHolder();
			holder.total_area = (FrameLayout)view.findViewById(R.id.chall_item_total_area);
			holder.chall_area = (RelativeLayout)view.findViewById(R.id.chall_item_area);
//			holder.chall_bk = (RelativeLayout)view.findViewById(R.id.chall_item_area_bk);
			holder.datetime = (TextView)view.findViewById(R.id.game_datetime);
			holder.challTime = (TextView)view.findViewById(R.id.game_time);
			holder.stadium = (TextView)view.findViewById(R.id.stadium);
			holder.playernum = (TextView)view.findViewById(R.id.player_number);
			holder.clubmark01 = (ImageView)view.findViewById(R.id.club_mark_01);
			holder.clubname01 = (TextView)view.findViewById(R.id.club_name_01);
			holder.clubmark02 = (ImageView)view.findViewById(R.id.club_mark_02);
			holder.clubname02 = (TextView)view.findViewById(R.id.club_name_02);
			holder.chall_funcs = (LinearLayout)view.findViewById(R.id.chall_funcs);
			holder.chall_func_meeting = (RelativeLayout)view.findViewById(R.id.chall_func_meeting);
			holder.chall_func_discuss = (RelativeLayout)view.findViewById(R.id.chall_func_discuss);
			holder.chall_func_response = (RelativeLayout)view.findViewById(R.id.chall_func_response);
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}

		holder.initHolder(data, position);
		
		return view;
	}
	
	private class ViewHolder {
		private FrameLayout total_area;
		private RelativeLayout chall_area;
//		private RelativeLayout chall_bk;
		private ImageView clubmark01;
		private TextView clubname01;
		private ImageView clubmark02;
		private TextView clubname02;
		private TextView datetime;
		private TextView challTime;
		private TextView stadium;
		private TextView playernum;
		private LinearLayout chall_funcs;
		private RelativeLayout chall_func_meeting;
		private RelativeLayout chall_func_discuss;
		private RelativeLayout chall_func_response;
		private int index;
		
		private String club_id_01;
		private String club_id_02;
		
		private AlertDialog dialog;
		private boolean[] sel_club_01;
		private boolean[] sel_club_02;
		private int sel_discuss_club_01;
		private int sel_discuss_club_02;
		private int sel_response;
		
		public void initHolder(final ChallengeItem data, final int position) {
			index = position;
			total_area.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					setHideMenu();
					chall_funcs.setVisibility(chall_funcs.getVisibility() == View.GONE ? View.VISIBLE : View.GONE);
					
					if(chall_funcs.getVisibility() == View.GONE){
						stadium.setText(data.getStadiumAddress()+" >>");
//						chall_bk.setBackgroundResource(R.color.white);
						chall_area.setX(0);
//						chall_bk.setX(0);
						data.setShowMenu(HIDE_MENU);
					} else {
						stadium.setText("<< " + data.getStadiumAddress());
						int nLayerWidth = chall_funcs.getWidth(); 
						if(nLayerWidth <= 0)
							nLayerWidth = dp2px(60);
						chall_area.setX(0-(nLayerWidth-10));
//						chall_bk.setBackgroundResource(R.color.pattern_green);
//						chall_bk.setX(-10);
						data.setShowMenu(SHOW_MENU);
					}
					notifyItems();
				}
			});
			
			String item;
			mClubData = new MyClubData();
			item = data.getGameDate().concat("/");
			item = item.concat(StringUtil.getWeekDay(data.getGameWday()));
//			item = item.concat(data.getGameTime());
			datetime.setText(item);
			challTime.setText(data.getGameTime());			
			stadium.setText(data.getStadiumAddress() + " >>");
			playernum.setText(String.format("%s%s", data.getPlayerCount(), ctx.getString(R.string.player_number)));
			
			imgLoader.displayImage(data.getClubMark01(), clubmark01, GgApplication.img_opt_club_mark);
			club_id_01 = data.getClubId01();
			clubmark01.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					getClubInfo(club_id_01);
				}
			});
			clubname01.setText(data.getClubName01());
			
			imgLoader.displayImage(data.getClubMark02(), clubmark02, GgApplication.img_opt_club_mark);
			club_id_02 = data.getClubId02();
			clubmark02.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					if (challType == CommonConsts.CHALLENGE_GAME)
						return;
					
					getClubInfo(club_id_02);
				}
			});
			
			clubname02.setText(data.getClubName02());
			
			if (data.getShowMenu() == SHOW_MENU) {
				chall_funcs.setVisibility(View.VISIBLE);
				int nLayerWidth = chall_funcs.getWidth(); 
				if(nLayerWidth <= 0)
					nLayerWidth = dp2px(60);
				chall_area.setX(0-(nLayerWidth-10));
				stadium.setText("<< " + data.getStadiumAddress());
			} else {
				chall_funcs.setVisibility(View.GONE);
				chall_area.setX(0);
				stadium.setText(data.getStadiumAddress()+" >>");
			}
			
			chall_func_meeting.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {					
					String[] clubNames = GgApplication.getInstance().getClubName();
					final String[] clubIds = GgApplication.getInstance().getClubId();
					if (mClubData.isOwnClub(Integer.valueOf(club_id_01))){
						Toast.makeText(ctx, R.string.manager_club, Toast.LENGTH_SHORT).show();
						return;
					}
					if (challType == CommonConsts.PROCLAIM_GAME){
						if (mClubData.isOwnClub(Integer.valueOf(club_id_02))){
							Toast.makeText(ctx, R.string.proclaim_recommnad, Toast.LENGTH_SHORT).show();
							// ++code++ value에 추가된 구락부마당에 선택한 도전ID(data.getChallengeID())에 대한 관련표어를 발송한다.
							return;
						}
					} else {
						sel_club_01 = new boolean[clubNames.length];
						sel_club_02 = new boolean[clubNames.length];
						for (int i = 0; i < clubNames.length; i++){
							sel_club_01[i] = false;
							sel_club_02[i] = false;
						}
						
						if (clubIds.length > 1) {
							dialog = new AlertDialog.Builder(ctx)
							.setTitle(R.string.select_club)
							.setCancelable(true)
							.setMultiChoiceItems(clubNames, sel_club_01, new DialogInterface.OnMultiChoiceClickListener() {
								
								@Override
								public void onClick(DialogInterface dialog, int which, boolean isChecked) {
									sel_club_02[which] = isChecked;
								}
							})
							.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
								
								@Override
								public void onClick(DialogInterface dialog, int which) {
									int i, count;
									String value = "";
									for (i = 0, count = 0; i < clubIds.length; i++ ){
										if (!sel_club_02[i])
											continue;
										if (count != 0)
											value = value.concat(",");
										value = value.concat(clubIds[i]);
										count++;
									}
									
									if (value.equals("")) {
										Toast.makeText(ctx, R.string.please_select_club, Toast.LENGTH_SHORT).show();
										return;
									}
									
									boolean isChall = StringUtil.isEmpty(data.getClubId02());
									String msg = "我推荐这个";
									msg = msg.concat(isChall ? "擂台。\r\n" : "战书。\r\n");
									if (isChall) {
										msg = msg.concat("主队" + ": " + data.getClubName01() + "\r\n");
									} else {
										msg = msg.concat(data.getClubName01() + " VS " + data.getClubName02() + "\r\n");
									}
									msg = msg.concat(data.getGameDate() + " " + data.getGameTime());
									
									GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
									
//									int cur_user_id = Integer.valueOf(GgApplication.getInstance().getUserId());
									
									for (i = 0; i < clubIds.length; i++) {
										if (!sel_club_02[i])
											continue;
										
										int room_id = chatInfo.getClubChatRoomId(Integer.parseInt(clubIds[i]));
										
										String time = GgApplication.getInstance().getCurServerTime();
										ChatEngine chatEngine = GgApplication.getInstance().getChatEngine();
										chatEngine.sendMessage(msg, ChatConsts.MSG_TEXT, room_id, time, true);
									}
									
									// ++code++ value에 추가된 구락부마당에 선택한 도전ID(data.getChallengeID())에 대한 관련표어를 발송한다.
									Toast.makeText(ctx, R.string.challenge_recommnad, Toast.LENGTH_SHORT).show();
									
									return;
								}
							}).create();
							
							dialog.show();
						} else if(clubIds.length == 1) {
//							String value = clubIds[0];
							boolean isChall = StringUtil.isEmpty(data.getClubId02());
							String msg = "我推荐这个";
							msg = msg.concat(isChall ? "擂台。\r\n" : "战书。\r\n");
							if (isChall) {
								msg = msg.concat("主队" + ": " + data.getClubName01() + "\r\n");
							} else {
								msg = msg.concat(data.getClubName01() + " VS " + data.getClubName02() + "\r\n");
							}
							msg = msg.concat(data.getGameDate() + " " + data.getGameTime());
							
							GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
							
//							int cur_user_id = Integer.valueOf(GgApplication.getInstance().getUserId());
							int room_id = chatInfo.getClubChatRoomId(Integer.parseInt(clubIds[0]));
							
							String time = GgApplication.getInstance().getCurServerTime();
							ChatEngine chatEngine = GgApplication.getInstance().getChatEngine();
							chatEngine.sendMessage(msg, ChatConsts.MSG_TEXT, room_id, time, true);
							
							Toast.makeText(ctx, R.string.challenge_recommnad, Toast.LENGTH_SHORT).show();
							return;
						} else {
							Toast.makeText(ctx, R.string.no_club_member, Toast.LENGTH_SHORT).show();
							return;
						}
					}
				}
			});
			
			chall_func_discuss.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {	
					sel_discuss_club_01 = 0;
					if (!mClubData.isOwner()) {
						Toast.makeText(ctx, R.string.no_manager, Toast.LENGTH_SHORT).show();
						return;
					}
					
					String[] myClubName = mClubData.getOwnerClubNames();
					final int[] myClubId = mClubData.getOwnerClubIDs();
					sel_discuss_club_02 = myClubId[0];
					boolean res_flag = true;
					for (int i = 0; i < myClubId.length; i++) {
						if (myClubId[i] == Integer.valueOf(data.getClubId01())) {
							res_flag = false;
						}
					}
					
					if (StringUtil.isEmpty(club_id_02)){
						if (!res_flag) {
							Toast.makeText(ctx, R.string.manager_club, Toast.LENGTH_SHORT).show();
							return;
						}
						
						if (myClubId.length > 1){
							dialog = new AlertDialog.Builder(ctx)
							.setTitle(R.string.select_club)
							.setCancelable(true)
							.setSingleChoiceItems(myClubName, sel_discuss_club_01, new DialogInterface.OnClickListener() {
								
								@Override
								public void onClick(DialogInterface dialog, int item) {
									sel_discuss_club_02 = myClubId[item];
								}
							})
							.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
								
								@Override
								public void onClick(DialogInterface dialog, int item) {
									moveDiscuss(data);
								}
							}).create();
								
							dialog.show();
						} else {
							moveDiscuss(data);
						}
					} else {
						if (!mClubData.isManagerOfClub(Integer.valueOf(data.getClubId01())) && 
							!mClubData.isManagerOfClub(Integer.valueOf(data.getClubId02()))) {
							Toast.makeText(ctx, R.string.no_manager, Toast.LENGTH_SHORT).show();
							return;
						}
						
						GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
						int room_id = chatInfo.getDiscussRoomId(Integer.valueOf(data.getClubId01()), 
								Integer.valueOf(data.getClubId02()), 
								1, Integer.valueOf(data.getChallengeID()));
						
						Intent intent = new Intent(ctx, ChatActivity.class);
						intent.putExtra(ChatConsts.CHAT_TYPE_TAG, ChatConsts.FROM_DISCUSS);
						intent.putExtra(ChatConsts.CREATE_CLUB_ID_TAG, Integer.valueOf(data.getClubId01()));
						if (mClubData.isManagerOfClub(Integer.valueOf(data.getClubId01()))){
							intent.putExtra(ChatConsts.OPP_CLUB_ID_TAG, data.getClubId02());
							intent.putExtra(ChatConsts.CLUB_ID_TAG, Integer.valueOf(data.getClubId01()));
						} else {
							intent.putExtra(ChatConsts.OPP_CLUB_ID_TAG, data.getClubId01());
							intent.putExtra(ChatConsts.CLUB_ID_TAG, Integer.valueOf(data.getClubId02()));
						}
						intent.putExtra(ChatConsts.CHALLENGE_ID, Integer.valueOf(data.getChallengeID()));
						intent.putExtra(ChatConsts.ROOM_ID, room_id);
//							intent = setParam(intent, data);
						intent.putExtra("type", CommonConsts.CHALL_TYPE_ALL_PROCLAIM);
						frg.startActivityForResult(intent, FROM_DISCUSS);
					}
				}
			});
			
			sel_response = 0;
			chall_func_response.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					mClubData = new MyClubData();
					if (mClubData.isOwner()) {
						String[] myClubName = mClubData.getOwnerClubNames();
						final int[] myClubId = mClubData.getOwnerClubIDs();
						boolean res_flag = true;
						for (int i = 0; i < myClubId.length; i++) {
							if (myClubId[i] == Integer.valueOf(data.getClubId01())) {
								Toast.makeText(ctx, R.string.manager_club, Toast.LENGTH_SHORT).show();
								res_flag = false;
							}
						}
						if (res_flag == true) {
							if (StringUtil.isEmpty(club_id_02)){
								if (myClubId.length >1){
									dialog = new AlertDialog.Builder(ctx)
									.setTitle(R.string.select_club)
									.setCancelable(true)
									.setSingleChoiceItems(myClubName, sel_response, new DialogInterface.OnClickListener() {
										
										@Override
										public void onClick(DialogInterface dialog, int item) {
											sel_response = item;
										}
									})
									.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
										
										@Override
										public void onClick(DialogInterface arg0, int arg1) {
											startResponseToChallenge(Integer.valueOf(data.getChallengeID()), myClubId[sel_response], true, 0, index);
										}
									}).create();
									
									dialog.show();
								} else {
									startResponseToChallenge(Integer.valueOf(data.getChallengeID()), myClubId[0], true, 0, index);
								}
							} else {
								startResponseToChallenge(Integer.valueOf(data.getChallengeID()), Integer.valueOf(club_id_02), true, 1, index);
							}
						}
					} else {
						Toast.makeText(ctx, R.string.no_manager, Toast.LENGTH_SHORT).show();
						return;
					}
				}
			});
		}
		
		private void getClubInfo(String club_id) {
			if (mClubData.isManagerOfClub(Integer.valueOf(club_id))){
				Intent intent = new Intent(ctx, CreateClubActivity.class);
				intent.putExtra(CommonConsts.CLUB_ID_TAG, Integer.valueOf(club_id));
				intent.putExtra(CommonConsts.CLUB_TYPE_TAG, CommonConsts.EDIT_CLUB);
				frg.startActivityForResult(intent, CLUB_INFO);
				return;
			}
			Intent intent = new Intent(ctx, ClubInfoActivity.class);
			intent.putExtra(GgIntentParams.CLUB_ID, club_id);
			frg.startActivityForResult(intent, CLUB_INFO);
		}
		
		/**
		 * 상의마당으로 이행하는 메쏘드
		 * @param data : 도전정보자료
		 */
		private void moveDiscuss(ChallengeItem data){
			GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
			int room_id = chatInfo.getDiscussRoomId(Integer.valueOf(data.getClubId01()), sel_discuss_club_02, 0, Integer.valueOf(data.getChallengeID()));
			if (room_id == -1) {
				startCreateDiscussRoom(true, 
						Integer.valueOf(data.getClubId01()), 
						sel_discuss_club_02, 
						Integer.valueOf(data.getChallengeID()),
						Integer.valueOf(data.getPlayerCount()));
				return;
			}
			
			Intent intent = new Intent(ctx, ChatActivity.class);
			intent.putExtra(ChatConsts.CHAT_TYPE_TAG, ChatConsts.FROM_DISCUSS);
			intent.putExtra(ChatConsts.CREATE_CLUB_ID_TAG, Integer.valueOf(data.getClubId01()));
			intent.putExtra(ChatConsts.OPP_CLUB_ID_TAG, data.getClubId01());
			intent.putExtra(ChatConsts.CLUB_ID_TAG, Integer.valueOf(sel_discuss_club_02));
			intent.putExtra(ChatConsts.CHALLENGE_ID, Integer.valueOf(data.getChallengeID()));
			intent.putExtra(ChatConsts.ROOM_ID, room_id);
			intent.putExtra("type", CommonConsts.CHALL_TYPE_ALL_CHALLENGE);
			frg.startActivityForResult(intent, FROM_DISCUSS);
		}
	}
	
//	private Intent setParam(Intent intent, ChallengeItem data ) {
//		intent.putExtra("club1_name", data.getClubName01());
//		intent.putExtra("club2_name", data.getClubName02());
//		intent.putExtra("game_date", data.getGameDate());
//		intent.putExtra("game_time", data.getGameTime());
//		intent.putExtra("player_count", data.getPlayerCount());
//		intent.putExtra("stadium_area", data.getStadiumArea());
//		intent.putExtra("stadium_address", data.getStadiumAddress());
//		intent.putExtra("money_split", data.getMoneySplit());
//		return intent;
//	}
	
	public void startResponseToChallenge(int challenge_id, int sel_clubID, boolean showdlg, int type, int index) {
		if(!NetworkUtil.isNetworkAvailable(ctx))
			return;
		
		if (showdlg){
			dlg = new GgProgressDialog(ctx, ctx.getString(R.string.wait));
			dlg.show();
		}
		
		Object[] param;
		param = new Object[3];
		param[0] = challenge_id;
		param[1] = sel_clubID;
		param[2] = type;
		
		ResponseToGameTask task = new ResponseToGameTask(ChallengeListAdapter.this, param, index);
		task.execute();
	}
	
	public void stopResponseToChallenge(int result, int index){
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (result == GgHttpErrors.GET_CHALL_SUCCESS) {
			Toast.makeText(ctx, R.string.response_success, Toast.LENGTH_LONG).show();
			datas.remove(index);
			notifyDataSetChanged();
		} else if (result == GgHttpErrors.HTTP_POST_FAIL){
			Toast.makeText(ctx, R.string.response_failed, Toast.LENGTH_LONG).show();
		} else if (result == 2) {
			Toast.makeText(ctx, R.string.response_exist, Toast.LENGTH_LONG).show();
		}
	}
	
	public void startCreateDiscussRoom(boolean showdlg, int team1, int team2, int gameId, int player_count) {
		if(!NetworkUtil.isNetworkAvailable(ctx))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ctx, ctx.getString(R.string.wait));
			dlg.show();
		}
		
		CreateDiscussRoomTask task = new CreateDiscussRoomTask(ChallengeListAdapter.this, team1, team2, gameId, player_count);
		task.execute();
	}
	
	/**
	 * 도전과 관련한 상의마당대화방창조완료시의 처리를 진행한다.
	 */
	public void stopCreateDiscussRoom(boolean success, ChatRoomInfo room) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (!success) {
			Toast.makeText(ctx, R.string.response_exist, Toast.LENGTH_LONG).show();
			return;
		}
		
		Intent intent = new Intent(ctx, ChatActivity.class);
		intent.putExtra(ChatConsts.CHAT_TYPE_TAG, ChatConsts.FROM_DISCUSS);
		intent.putExtra(ChatConsts.CREATE_CLUB_ID_TAG, room.getClubId01());
		intent.putExtra(ChatConsts.OPP_CLUB_ID_TAG, String.valueOf(room.getClubId01()));
		intent.putExtra(ChatConsts.CLUB_ID_TAG, room.getClubId02());
		intent.putExtra(ChatConsts.CHALLENGE_ID, room.getGameId());
		intent.putExtra(ChatConsts.ROOM_ID, room.getRoomId());
		intent.putExtra("type", CommonConsts.CHALL_TYPE_ALL_CHALLENGE);
		frg.startActivityForResult(intent, FROM_DISCUSS);
	}
	
	public void addData(ArrayList<ChallengeItem> newdatas) {
		for (ChallengeItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void setChallType(int value) {
		challType = value;
	}
	
	public void clearData() {
		datas.clear();
	}
	
	public void setHideMenu() {
		for (int i = 0; i < datas.size(); i++) {
			ChallengeItem item = datas.get(i);
			item.setShowMenu(HIDE_MENU);
		}
	}
}
