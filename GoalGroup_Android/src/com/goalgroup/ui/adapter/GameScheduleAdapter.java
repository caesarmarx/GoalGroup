package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.model.ScheduleItem;
import com.goalgroup.ui.ClubInfoActivity;
import com.goalgroup.ui.CreateClubActivity;
import com.goalgroup.ui.GameScheduleActivity;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class GameScheduleAdapter extends BaseAdapter {
	
	private GameScheduleActivity parent;
	
	private Context ctx;
	private ArrayList<ScheduleItem> datas;
	private int type;
	private int myClubId;
	
	private ImageLoader imgLoader;
	private MyClubData myClubData;
	
	public GameScheduleAdapter(Context aCtx) {
		parent = (GameScheduleActivity)aCtx;
		ctx = aCtx;
		datas = new ArrayList<ScheduleItem>();
		myClubData = new MyClubData();
//		initTestData();
		
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

	@Override
	public View getView(int position, View view, ViewGroup parent) {
		ScheduleItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.game_schedule_adapter, null);
			
			holder = new ViewHolder();
			holder.dateTimeArea = (View)view.findViewById(R.id.date_time_ly);
			holder.dateTime = (TextView)view.findViewById(R.id.date_time);
			holder.playerNumber01 = (TextView)view.findViewById(R.id.player_number_01);
			holder.clubMark01 = (ImageView)view.findViewById(R.id.club_mark_01);
			holder.clubName01 = (TextView)view.findViewById(R.id.club_name_01);
			holder.playerNumber02 = (TextView)view.findViewById(R.id.player_number_02);
			holder.clubMark02 = (ImageView)view.findViewById(R.id.club_mark_02);
			holder.clubName02 = (TextView)view.findViewById(R.id.club_name_02);
			holder.result = (TextView)view.findViewById(R.id.game_result);
			holder.playerNumberMode = (TextView)view.findViewById(R.id.player_number_mode);
			holder.resultBG = (RelativeLayout)view.findViewById(R.id.result_bg);
			
//			holder.areaResult = view.findViewById(R.id.area_result);
			holder.areaInvite = view.findViewById(R.id.area_invite);
			holder.areaDisable =  view.findViewById(R.id.disable_area);
			
			holder.applyPlayer01 = (View)view.findViewById(R.id.player_number_ly_01);
			holder.applyPlayer02 = (View)view.findViewById(R.id.player_number_ly_02);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		view.setEnabled(isGameEnable(data) ? true : false);
		holder.initHolder(data);
		
		return view;
	}
	
	private class ViewHolder {
		public View dateTimeArea;
		public TextView dateTime;
		public TextView playerNumber01;
		public ImageView clubMark01;
		public TextView clubName01;
		public TextView playerNumber02;
		public ImageView clubMark02;
		public TextView clubName02;
		public TextView result;
		public TextView playerNumberMode;
		public View resultBG;

//		public View areaResult;
		public View areaInvite;
		public View areaDisable;
		
		public View applyPlayer01;
		public View applyPlayer02;
		
		public void initHolder(final ScheduleItem data) {
			dateTimeArea.setVisibility(data.showDateTime() ? View.VISIBLE : View.GONE);
			
			dateTime.setText(data.getDate() + "/" + StringUtil.getWeekDay(data.getWDay()) + " " + data.getTime());
			playerNumber01.setText(Integer.toString(data.getPlayerNumber01()));
			clubName01.setText(data.getClubName01());
			imgLoader.displayImage(data.getClubMark01(), clubMark01, GgApplication.img_opt_club_mark);
			clubMark01.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					clubInfo(Integer.valueOf(data.getClubId01()));
				}
			});
			playerNumber02.setText(Integer.toString(data.getPlayerNumber02()));
			clubName02.setText(data.getClubName02());
			imgLoader.displayImage(data.getClubMark02(), clubMark02, GgApplication.img_opt_club_mark);
			
			if (data.getType() != CommonConsts.CUSTOM_GAME) {
				clubMark02.setOnClickListener(new View.OnClickListener() {
					
					@Override
					public void onClick(View arg0) {
						clubInfo(Integer.valueOf(data.getClubId02()));
					}
				});
			}
			result.setText(getResult(data));
			playerNumberMode.setText(String.format("%d%s", data.getPlayerCounts(), ctx.getString(R.string.player_number)));
			
			boolean isHome = true;
			if (myClubId == Integer.valueOf(data.getClubId02()))
				isHome = false;
			resultBG.setBackgroundResource(!isLoseGame(data, isHome) ? R.drawable.vs_center_bg : R.drawable.vs_center_bg_02);
//			disableArea.setVisibility(isGameEnable(data) ? View.GONE : View.VISIBLE);
			
			if (type == CommonConsts.SCHEDULE_FROM_CHAT) {
				result.setVisibility(View.VISIBLE);
				areaInvite.setVisibility(View.GONE);
			} else {
				result.setVisibility(View.GONE);
				areaInvite.setVisibility(View.VISIBLE);
			}
			
			if (isFinishedGame(data))
				areaDisable.setVisibility(View.VISIBLE);
			else
				areaDisable.setVisibility(View.GONE);
			
			areaInvite.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					parent.inviteGame(data.getGameId());
				}
			});

		}
	}
	
	public void setPlayerNumber(int clubId, int position, int direction) {
		ScheduleItem item = datas.get(position);
		if (Integer.parseInt(item.getClubId01()) == clubId)
			item.setPlayerNumber01(item.getPlayerNumber01() + 1 * direction);
		else
			item.setPlayerNumber02(item.getPlayerNumber02() + 1 * direction);
	}
	
	public void setType(int value) {
		type = value;
	}
	
	public void setClubId(int value) {
		myClubId = value;
	}
	
	public void addData(ArrayList<ScheduleItem> newdatas) {
		for (ScheduleItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void clearData() {
		datas.clear();
	}
	
	private boolean isGameEnable(ScheduleItem data) {
		int state = data.getState();
		if (state == CommonConsts.GAME_STATE_CANCELED || state == CommonConsts.GAME_STATE_FINISHED) {
			return false;
		}
		
		return true;
	}
	
	private boolean isFinishedGame(ScheduleItem data) {
		if (data.getState() == CommonConsts.GAME_STATE_FINISHED || data.getState() == CommonConsts.GAME_STATE_CANCELED) {
			return true;
		}
		
		return false;
	}
	
	private boolean isLoseGame(ScheduleItem data, Boolean isHome) {
		if (!isFinishedGame(data))
			return false;
		
		String result = data.getResult();
		String[] mark = result.split(":");
		
		int mark01;
		int mark02;
		
		if (isHome) {
			mark01 = Integer.parseInt(mark[0]);
			mark02 = Integer.parseInt(mark[1]);
		} else {
			mark01 = Integer.parseInt(mark[1]);
			mark02 = Integer.parseInt(mark[0]);
		}
		return mark01 < mark02;
	}
	
	public String getResult(ScheduleItem data) {
		return (isFinishedGame(data) ? data.getResult() : ctx.getString(R.string.versus));
	}
	
	public int getOppClubId(ScheduleItem data) {
		int club_id_01 = Integer.parseInt(data.getClubId01());
		int club_id_02 = Integer.parseInt(data.getClubId02());
		
		return (myClubId != club_id_01) ? club_id_01 : club_id_02;
	}
	
	public void clubInfo(int clubId){
		if (myClubData.isManagerOfClub(Integer.valueOf(clubId))){
			Intent intent = new Intent(ctx, CreateClubActivity.class);
			intent.putExtra(CommonConsts.CLUB_ID_TAG, clubId);
			intent.putExtra(CommonConsts.CLUB_TYPE_TAG, CommonConsts.EDIT_CLUB);
			ctx.startActivity(intent);
			return;
		}
		Intent intent = new Intent(ctx, ClubInfoActivity.class);
		intent.putExtra(GgIntentParams.CLUB_ID, String.valueOf(clubId));
		ctx.startActivity(intent);
	}
	
//	private void initTestData() {
//		datas = new ArrayList<ScheduleItem>();
//		for (int i = 0; i < testData.length; i++)
//			datas.add(testData[i]);
//	}
//	
//	private ScheduleItem[] testData = {
//		new ScheduleItem("02-17 15:00", "俱乐部A", "5", "俱乐部D", "7", "5人制", "VS", true, 0),
//		new ScheduleItem("02-16 15:00", "俱乐部A", "11", "俱乐部E", "10", "9人制", "VS", true, 0), 
//		new ScheduleItem("02-16 10:00", "俱乐部A", "6", "俱乐部C", "6", "6人制", "VS", false, 0),
//		new ScheduleItem("02-15 15:00", "俱乐部A", "7", "俱乐部B", "8", "7人制", "3:0", true, 1),
//		new ScheduleItem("02-15 10:00", "俱乐部A", "13", "俱乐部F", "11", "11人制", "1:2", false, 3),
//	};
}
