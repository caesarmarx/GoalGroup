package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.app.AlertDialog;
import android.content.Context;
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
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.ClubChallengeItem;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.ResponseToGameTask;
import com.goalgroup.ui.ChatActivity;
import com.goalgroup.ui.ClubChallengesActivity;
import com.goalgroup.ui.ClubInfoActivity;
import com.goalgroup.ui.CreateClubActivity;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class ClubChallengeAdapter extends BaseAdapter {
	private final int CLUB_INFO = 0;
	private final int FROM_DISCUSS = 2;
	
	private final int HIDE_MENU = 0;
	private final int SHOW_MENU = 1;

	private ClubChallengesActivity parent;
	private Context ctx;
	private ArrayList<ClubChallengeItem> datas;
	private MyClubData myClubData;
	
	private int challType;
	private int clubID;
	
	private GgProgressDialog dlg;
	private ImageLoader imgLoader;
	
	public ClubChallengeAdapter(Context aCtx, int clubID) {
		parent = (ClubChallengesActivity)aCtx;
		ctx = aCtx;
		datas = new ArrayList<ClubChallengeItem>();
		myClubData = new MyClubData();
		this.clubID = clubID;
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

	private int dp2px(int dp) {
		return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp,
				GgApplication.getInstance().getBaseContext().getResources().getDisplayMetrics());	
	}
	
	@Override
	public View getView(int position, View view, ViewGroup parent) {
		ClubChallengeItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.club_challenge_adapter, null);
			
			holder = new ViewHolder();
			holder.total_area = (FrameLayout)view.findViewById(R.id.total_area);
			holder.chall_area = (FrameLayout)view.findViewById(R.id.chall_area);
			holder.gamedate = (TextView)view.findViewById(R.id.game_date);
			holder.gametime = (TextView)view.findViewById(R.id.game_time);
			holder.stadium = (TextView)view.findViewById(R.id.stadium);
			holder.playernum = (TextView)view.findViewById(R.id.player_number);
			holder.clubmark01 = (ImageView)view.findViewById(R.id.club_mark_01);
			holder.clubname01 = (TextView)view.findViewById(R.id.club_name_01);
			holder.clubmark02 = (ImageView)view.findViewById(R.id.club_mark_02);
			holder.clubname02 = (TextView)view.findViewById(R.id.club_name_02);
			holder.tvGameRemainTime = (TextView)view.findViewById(R.id.game_remain_time);
			holder.btnDelete = (ImageView)view.findViewById(R.id.delete_game);
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
		private FrameLayout chall_area;
		private ImageView clubmark01;
		private TextView clubname01;
		private ImageView clubmark02;
		private TextView clubname02;
		private TextView playernum;
		private TextView gamedate;
		private TextView gametime;
		private TextView stadium;
		private TextView tvGameRemainTime;
		private ImageView btnDelete;
		private LinearLayout chall_funcs;
		private RelativeLayout chall_func_meeting;
		private RelativeLayout chall_func_discuss;
		private RelativeLayout chall_func_response;
		
		private String club_id_01;
		private String club_id_02;
		
//		private void startCountDown() {
//			
//			timerRunnable = new Runnable() {
//				
//				@Override
//				public void run() {
//					String countdown = DateUtil.getDiffTime(org_game_datetime);
//					if(countdown.split(":")[2].startsWith("-"))
//					{
//						countdown = "00:00:00";
//						System.out.println("Remain_Time:" + countdown);
//						stopCountDown();
//					}
//					tvGameRemainTime.setText(countdown);
//					
//					timerHandler.postDelayed(timerRunnable, 1000);
//				}
//			};
//			
//			timerHandler = new Handler();
//			timerHandler.post(timerRunnable);
//		}
		
//		private void stopCountDown() {
//			if (timerHandler == null)
//				return;
//			timerHandler.removeCallbacks(timerRunnable);
//			timerHandler = null;
//		}
		
		public void initHolder(final ClubChallengeItem data, final int position) {
			
			if (parent.challType == CommonConsts.CHALL_TYPE_ALL_PROCLAIM)
			total_area.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					setHideMenu();
					chall_funcs.setVisibility(chall_funcs.getVisibility() == View.GONE ? View.VISIBLE : View.GONE);
					
					if(chall_funcs.getVisibility() == View.GONE){
						stadium.setText(data.getStadiumAddress()+" >>");
						chall_area.setX(0);
//						btnDelete.setX(0);
						data.setShowMenu(HIDE_MENU);
					} else {
						stadium.setText("<< " + data.getStadiumAddress());
						int nLayerWidth = chall_funcs.getWidth(); 
						if(nLayerWidth <= 0)
							nLayerWidth = dp2px(60);
						chall_area.setX(0-(nLayerWidth-10));
//						btnDelete.setX(0-(nLayerWidth-10));
						data.setShowMenu(SHOW_MENU);
					}
					notifyItems();
				}
			});
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
			tvGameRemainTime.setText(data.getRemainTime());
			club_id_02 = data.getClubId02();
			clubmark02.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					if (challType == CommonConsts.CHALL_TYPE_MY_CHALLENGE)
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
			
			playernum.setText(String.format("%s%s", data.getPlayerCount(), ctx.getString(R.string.player_number)));
			
			String date = data.getGameDate();
			date = date.concat("/");
			date = date.concat(StringUtil.getWeekDay(data.getGameWday()));
			gamedate.setText(date);
			gametime.setText(data.getGameTime());
			stadium.setText(data.getStadiumAddress());
//			stopCountDown();
//			startCountDown();
			if (myClubData.isOwner(Integer.valueOf(club_id_01)) && Integer.valueOf(club_id_01) == clubID)
				btnDelete.setVisibility(View.VISIBLE);
			else 
				btnDelete.setVisibility(View.GONE);
			btnDelete.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					if (!myClubData.isOwner(Integer.valueOf(club_id_01))){
						Toast.makeText(ctx, R.string.no_manager, Toast.LENGTH_SHORT).show();
						return;
					}
					procDelete(position);
				}
			});
			
			chall_func_meeting.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {					
					if (myClubData.isOwnClub(Integer.valueOf(club_id_01)) && Integer.valueOf(club_id_01) == clubID){
						Toast.makeText(ctx, R.string.manager_club, Toast.LENGTH_SHORT).show();
						return;
					}
					if (myClubData.isOwnClub(Integer.valueOf(club_id_02))){
						Toast.makeText(ctx, R.string.proclaim_recommnad, Toast.LENGTH_SHORT).show();
						// ++code++ value에 추가된 구락부마당에 선택한 도전ID(data.getChallengeID())에 대한 관련표어를 발송한다.
						String msg = "我推荐这个";
						msg = msg.concat("战书。\r\n");
						msg = msg.concat(data.getClubName01() + " VS " + data.getClubName02() + "\r\n");
						msg = msg.concat(data.getGameDate() + " " + data.getGameTime());
						
						GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
						
//							int cur_user_id = Integer.valueOf(GgApplication.getInstance().getUserId());
						
						int room_id = chatInfo.getClubChatRoomId(Integer.parseInt(club_id_02));
							
						String time = GgApplication.getInstance().getCurServerTime();
						ChatEngine chatEngine = GgApplication.getInstance().getChatEngine();
						chatEngine.sendMessage(msg, ChatConsts.MSG_TEXT, room_id, time, true);
						return;
					}
				}
			});
			
			chall_func_discuss.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					if (!myClubData.isOwner()) {
						Toast.makeText(ctx, R.string.no_manager, Toast.LENGTH_SHORT).show();
						return;
					}
					
					if (!myClubData.isManagerOfClub(Integer.valueOf(data.getClubId01())) && 
						!myClubData.isManagerOfClub(Integer.valueOf(data.getClubId02()))) {
						Toast.makeText(ctx, R.string.no_manager, Toast.LENGTH_SHORT).show();
						return;
					}
					
					GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
					int room_id = chatInfo.getDiscussRoomId(Integer.valueOf(data.getClubId01()), 
							Integer.valueOf(data.getClubId02()), 
							1, Integer.valueOf(data.getChallId()));
					
					Intent intent = new Intent(ctx, ChatActivity.class);
					intent.putExtra(ChatConsts.CHAT_TYPE_TAG, ChatConsts.FROM_DISCUSS);
					intent.putExtra(ChatConsts.CREATE_CLUB_ID_TAG, Integer.valueOf(data.getClubId01()));
					if (myClubData.isManagerOfClub(Integer.valueOf(data.getClubId01()))){
						intent.putExtra(ChatConsts.OPP_CLUB_ID_TAG, data.getClubId02());
						intent.putExtra(ChatConsts.CLUB_ID_TAG, Integer.valueOf(data.getClubId01()));
					} else {
						intent.putExtra(ChatConsts.OPP_CLUB_ID_TAG, data.getClubId01());
						intent.putExtra(ChatConsts.CLUB_ID_TAG, Integer.valueOf(data.getClubId02()));
					}
					intent.putExtra(ChatConsts.CHALLENGE_ID, Integer.valueOf(data.getChallId()));
					intent.putExtra(ChatConsts.ROOM_ID, room_id);
					intent.putExtra("type", CommonConsts.CHALL_TYPE_ALL_PROCLAIM);
					parent.startActivityForResult(intent, FROM_DISCUSS);
				}
			});
			
			chall_func_response.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					if (Integer.valueOf(club_id_02) != clubID) {
						Toast.makeText(ctx, R.string.no_manager, Toast.LENGTH_SHORT).show();
						return;
					}
					
					if (myClubData.isOwner()) {
						if (!myClubData.isOwner(Integer.valueOf(club_id_02))) {
							Toast.makeText(ctx, R.string.no_manager, Toast.LENGTH_SHORT).show();
							return;
						}
						else if (myClubData.isOwner(Integer.valueOf(club_id_01))){
							Toast.makeText(ctx, R.string.manager_club, Toast.LENGTH_SHORT).show();
							return;
						}
						else {
							startResponseToChallenge(Integer.valueOf(data.getChallId()), Integer.valueOf(club_id_02), true, 1, position);
						}
					} else {
						Toast.makeText(ctx, R.string.no_manager, Toast.LENGTH_SHORT).show();
						return;
					}
				}
			});
		}
		
		private void getClubInfo(String club_id) {
			if (myClubData.isManagerOfClub(Integer.valueOf(club_id))){
				Intent intent = new Intent(ctx, CreateClubActivity.class);
				intent.putExtra(CommonConsts.CLUB_ID_TAG, Integer.valueOf(club_id));
				intent.putExtra(CommonConsts.CLUB_TYPE_TAG, CommonConsts.EDIT_CLUB);
				parent.startActivityForResult(intent, CLUB_INFO);
				return;
			}
			Intent intent = new Intent(ctx, ClubInfoActivity.class);
			intent.putExtra(GgIntentParams.CLUB_ID, club_id);
			parent.startActivityForResult(intent, CLUB_INFO);
		}
	}
	
	public void addData(ArrayList<ClubChallengeItem> newdatas) {
		for (ClubChallengeItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void setChallType(int value) {
		challType = value;
	}
	
	public void clearData() {
		datas.clear();
	}
	
	public void deleteData(int index) {
		datas.remove(index);
	}
	
	public void notifyItems() {
		notifyDataSetChanged();
	}
	
	public void setHideMenu() {
		for (int i = 0; i < datas.size(); i++) {
			ClubChallengeItem item = datas.get(i);
			item.setShowMenu(HIDE_MENU);
		}
	}
	
	public void procDelete(int position) {
		ClubChallengeItem item = datas.get(position);
		showConfirmDialog(position, Integer.parseInt(item.getChallId()));
	}
	
	private void showConfirmDialog(final int position, final int gameId) {
		AlertDialog dialog;
		dialog = new AlertDialog.Builder(ctx)
		.setTitle(challType == CommonConsts.CHALL_TYPE_MY_CHALLENGE ? R.string.delete_challenge : R.string.delete_proclaim)
		.setMessage(challType == CommonConsts.CHALL_TYPE_MY_CHALLENGE ? R.string.delete_challenge_conf : R.string.delete_proclaim_conf)
		.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int item) {
				parent.startDeleteChallenge(true, position, gameId);
			}
		})
		.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int item) {
				dialog.dismiss();
			}
		})
		.create();
		
		dialog.show();
	}
	
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
		
		ResponseToGameTask task = new ResponseToGameTask(ClubChallengeAdapter.this, param, index);
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
}
