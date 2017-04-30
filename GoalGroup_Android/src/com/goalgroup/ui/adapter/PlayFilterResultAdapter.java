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
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.component.ChatEngine;
import com.goalgroup.chat.info.GgChatInfo;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.model.PlayerFilterResultItem;
import com.goalgroup.task.CheckMemberTask;
import com.goalgroup.task.SendInvReqTask;
import com.goalgroup.ui.PlayerMarketActivity;
import com.goalgroup.ui.ProfileActivity;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class PlayFilterResultAdapter extends BaseAdapter {
	
	public static final int BTN_RECOMMEND = 0;
	public static final int BTN_TEMP_INVITE = 1;
	public static final int BTN_INVITE = 2;
	
	private final int HIDE_MENU = 0;
	private final int SHOW_MENU = 1;
	
	private PlayerMarketActivity parent;
	private Context ctx;
	private ArrayList<PlayerFilterResultItem> datas;
	private MyClubData myClubData;
	
	private ImageLoader imgLoader;
	private GgProgressDialog dlg;
	
	private int user_id;
	private int club_id;
	
	private AlertDialog dialog;
	private int sel_club;
	private String multi_sel_clubs;
	
	private static int PLAYER_FILTER_ADAPTER = 0;
	
	public PlayFilterResultAdapter(Context aCtx) {
		parent = (PlayerMarketActivity)aCtx;
		ctx = aCtx;
		datas = new ArrayList<PlayerFilterResultItem>();
		myClubData = new MyClubData();
		
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
		PlayerFilterResultItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.player_filter_result_adapter, null);
			
			holder = new ViewHolder();
			holder.total_area = (FrameLayout)view.findViewById(R.id.player_area);
			holder.player_area = (LinearLayout)view.findViewById(R.id.player_market_total);
			holder.photo = (ImageView)view.findViewById(R.id.player_photo);
			holder.name = (TextView)view.findViewById(R.id.player_name);
			holder.infos_age = (TextView)view.findViewById(R.id.player_base_infos_age);
			holder.infos_term = (TextView)view.findViewById(R.id.player_base_infos_term);
			holder.infos_height = (TextView)view.findViewById(R.id.player_base_infos_height);
			holder.infos_weight = (TextView)view.findViewById(R.id.player_base_infos_weight);
			holder.position = (TextView)view.findViewById(R.id.play_position);
			holder.dates = (TextView)view.findViewById(R.id.play_dates);
			holder.areas = (TextView)view.findViewById(R.id.play_areas);
			holder.more_funcs = (LinearLayout)view.findViewById(R.id.player_market_funcs);
			holder.recommend = (ImageView)view.findViewById(R.id.market_recommend);
			holder.temp_inv = (ImageView)view.findViewById(R.id.market_temp_inv);
			holder.inv = (ImageView)view.findViewById(R.id.market_inv);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data);
		
		return view;
	}
	
	private class ViewHolder {
		public FrameLayout total_area;
		public LinearLayout player_area;
		public ImageView photo;
		public TextView name;
		public TextView infos_age;
		public TextView infos_term;
		public TextView infos_height;
		public TextView infos_weight;
		public TextView position;
		public TextView dates;
		public TextView areas;
		
		private LinearLayout more_funcs;
		private ImageView recommend;
		private ImageView temp_inv;
		private ImageView inv;

		public void initHolder(final PlayerFilterResultItem data) {
			
			total_area.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					setHideMenu();
					more_funcs.setVisibility(more_funcs.getVisibility() == View.GONE ? View.VISIBLE : View.GONE);
					
					if(more_funcs.getVisibility() == View.GONE){
						player_area.setX(0);
						data.setShowMenu(HIDE_MENU);
					} else {
						int nLayerWidth = more_funcs.getWidth(); 
						if(nLayerWidth <= 0)
							nLayerWidth = dp2px(60);
						player_area.setX(0-nLayerWidth+10);
						data.setShowMenu(SHOW_MENU);
					}
					notifyItems();
				}
			});
			imgLoader.displayImage(data.getPhoto(), photo, GgApplication.img_opt_photo);
			photo.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					Intent intent;
					intent = new Intent(ctx, ProfileActivity.class);
					intent.putExtra("user_id", data.getUserID());
					if (data.getUserID() == Integer.valueOf(GgApplication.getInstance().getUserId()))
						intent.putExtra("type", CommonConsts.EDIT_PROFILE);
					else {
						intent.putExtra("type", CommonConsts.SHOW_PROFILE);
						intent.putExtra("from", CommonConsts.FROM_MARKET);
					}
						
					ctx.startActivity(intent);
				}
			});
			name.setText(data.getName());
			
			String baseinfo;
			baseinfo = (ctx.getString(R.string.age)).concat(": ").concat(data.getAge());
			infos_age.setText(baseinfo);
			
			baseinfo = (ctx.getString(R.string.term)).concat(": ").concat(data.getTerm());
			infos_term.setText(baseinfo);
			
			baseinfo = (ctx.getString(R.string.height)).concat(": ").concat(data.getHeight());
			infos_height.setText(baseinfo);
			
			baseinfo = (ctx.getString(R.string.weight)).concat(": ").concat(data.getWeight());
			infos_weight.setText(baseinfo);
			
			position.setText(StringUtil.getStrFromSelValue(data.getPosition(), CommonConsts.POSITION));
			dates.setText(StringUtil.getStrFromSelValue(data.getPlayDays(), CommonConsts.ACT_DAY));
			areas.setText(data.getPlayAreas());
			
			if (data.getShowMenu() == SHOW_MENU) {
				more_funcs.setVisibility(View.VISIBLE);
				int nLayerWidth = more_funcs.getWidth(); 
				if(nLayerWidth <= 0)
					nLayerWidth = dp2px(60);
				player_area.setX(0-nLayerWidth+10);
			} else {
				more_funcs.setVisibility(View.GONE);
				player_area.setX(0);
			}
			
			recommend.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					if (!myClubData.isPlayerOfClub()){
						Toast.makeText(parent, R.string.no_club_member, Toast.LENGTH_SHORT).show();
						return;
					}
					if (Integer.valueOf(GgApplication.getInstance().getUserId()) == data.getUserID()){
						Toast.makeText(parent, R.string.recommend_error, Toast.LENGTH_SHORT).show();
						return;
					}
						
					showTeamMultiSelDialog(PlayFilterResultAdapter.BTN_RECOMMEND, 
							data);					
				}
			});
			
			temp_inv.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					if (!myClubData.isOwner()){
						Toast.makeText(ctx, R.string.no_manager, Toast.LENGTH_SHORT).show();
						return;
					}
					showTeamSelDialog(PlayFilterResultAdapter.BTN_TEMP_INVITE, 
							data);					
				}
			});
			
			inv.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					if (!myClubData.isOwner()){
						Toast.makeText(ctx, R.string.no_manager, Toast.LENGTH_SHORT).show();
						return;
					}
					showTeamMultiSelDialog(PlayFilterResultAdapter.BTN_INVITE, 
							data);
				}
			});
		}
	}
	
	public void startSendInvReq(boolean showdlg) {
		if(!NetworkUtil.isNetworkAvailable(ctx))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ctx, ctx.getString(R.string.wait));
			dlg.show();
		}
		
		Object[] param = new Object[2];
		param[0] = multi_sel_clubs;
		param[1] = user_id;
		
		SendInvReqTask task = new SendInvReqTask(PlayFilterResultAdapter.this, param, PLAYER_FILTER_ADAPTER);
		task.execute();
	}

	public void stopSendInvReq(int result) {
		if (dlg != null){
			dlg.dismiss();
			dlg = null;
		}
		if (result == 1 ) 
			Toast.makeText(ctx, R.string.invitatoin_succeed, Toast.LENGTH_SHORT).show();
		 else if (result == 2)
			Toast.makeText(ctx, R.string.invitatoin_exist, Toast.LENGTH_SHORT).show();
		 else if (result == 3)
			Toast.makeText(ctx, R.string.invite_game_already_member, Toast.LENGTH_SHORT).show();
		 else if (result == 4)
			 Toast.makeText(ctx, R.string.invitation_rec_reject, Toast.LENGTH_SHORT).show();
		 else 
			Toast.makeText(ctx, R.string.invitatoin_reject, Toast.LENGTH_SHORT).show();
	}
	
	public void addData(ArrayList<PlayerFilterResultItem> newdatas) {
		for (PlayerFilterResultItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void notifyItems(){
		notifyDataSetChanged();
	}
	
	public void clearData() {
		datas.clear();
	}
	
	public void setHideMenu() {
		for (int i = 0; i < datas.size(); i++) {
			PlayerFilterResultItem item = datas.get(i);
			item.setShowMenu(HIDE_MENU);
		}
	}
	
	private String[] clubNames;
	private int[] clubIds;
	private PlayerFilterResultItem selData;
	
	public void showTeamSelDialog(final int from, PlayerFilterResultItem data) {
		selData = data;
		
		clubNames = myClubData.getOwnerClubNames();
		clubIds = myClubData.getOwnerClubIDs();
		if (clubIds.length == 0)
			return;
		
		sel_club = clubIds[0];
		if (clubIds.length > 1) {
			dialog = new AlertDialog.Builder(ctx)
			.setTitle(R.string.select_club)
			.setCancelable(true)
			.setSingleChoiceItems(clubNames, 0, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int item) {
					sel_club = Integer.valueOf(clubIds[item]);								
				}
			}).setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int item) {
					onClickedOkButton(from);
				}
			}).create();
			dialog.show();
		} else {
			onClickedOkButton(from);
		}
	}
	
	public void showTeamMultiSelDialog(final int from, PlayerFilterResultItem data) {
		final boolean[] sel_multi_club;
		selData = data;
		
		if (from == BTN_RECOMMEND) {
			clubNames = GgApplication.getInstance().getClubName();
			String[] multi_clubIds;
			multi_clubIds = GgApplication.getInstance().getClubId();
			clubIds = new int[multi_clubIds.length];
			for (int i = 0; i < multi_clubIds.length; i++)
				clubIds[i] = Integer.valueOf(multi_clubIds[i]);
		} else if (from == BTN_INVITE) {
			clubNames = myClubData.getOwnerClubNames();
			clubIds = myClubData.getOwnerClubIDs();
		}
		if (clubIds.length == 0)
			return;
		
		if (clubIds.length > 1) {
			sel_multi_club = new boolean[clubNames.length];
			for (int i = 0; i < clubNames.length; i++)
				sel_multi_club[i] = false;
			dialog = new AlertDialog.Builder(ctx)
			.setTitle(R.string.select_club)
			.setCancelable(true)
			.setMultiChoiceItems(clubNames, sel_multi_club, new DialogInterface.OnMultiChoiceClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which, boolean isChecked) {
					sel_multi_club[which] = isChecked;								
				}
			}).setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int item) {
					multi_sel_clubs = "";
					for (int i = 0, count = 0; i < clubIds.length; i++ ){
						if (!sel_multi_club[i])
							continue;
						if (count != 0)
							multi_sel_clubs = multi_sel_clubs.concat(",");
						multi_sel_clubs = multi_sel_clubs.concat(String.valueOf(clubIds[i]));
						count++;
					}
					onClickedOkButton(from);
				}
			}).create();
			dialog.show();
		} else {
			multi_sel_clubs = String.valueOf(clubIds[0]);
			onClickedOkButton(from);
		}
	}
	
	public void stopTempInv(int result) {
		
		if(result == 0)
			parent.selectInviteGame(club_id, user_id);
		else {
			Toast.makeText(ctx, R.string.invite_game_already_member, Toast.LENGTH_SHORT).show();
			return;
		}
	}
	
	private void onClickedOkButton(int from) {
		
		user_id = selData.getUserID();
		club_id = sel_club;
		
		switch (from) {
		case BTN_RECOMMEND:
			// ++code++ 선택된 multi_sel_clubs값에 들어있는 구락부마당들에 선택한 선수가 추천되였다는 관련표어가 현시되는 코드 실장
			if (StringUtil.isEmpty(multi_sel_clubs)) {
				Toast.makeText(ctx, R.string.please_select_club, Toast.LENGTH_SHORT).show();
				return;
			}
			
			String msg = "我推荐这个球员\r\n";
			msg = msg.concat(selData.getName());
			
			GgChatInfo chatInfo = GgApplication.getInstance().getChatInfo();
			
			ChatEngine chatEngine = GgApplication.getInstance().getChatEngine();
			
			String[] clubIds = multi_sel_clubs.split(",");
			for (int i = 0; i < clubIds.length; i++) {
				int room_id = chatInfo.getClubChatRoomId(Integer.parseInt(clubIds[i]));
				String time = GgApplication.getInstance().getCurServerTime();				
				chatEngine.sendMessage(msg, ChatConsts.MSG_TEXT, room_id, time, true);
			}
			
			Toast.makeText(ctx, R.string.recommend_success, Toast.LENGTH_SHORT).show();
			
			break;
		case BTN_TEMP_INVITE:
			CheckMemberTask m_CheckTask = new CheckMemberTask(this, user_id, club_id);
			m_CheckTask.execute();
			
			break;
		case BTN_INVITE:
			if(StringUtil.isEmpty(multi_sel_clubs)) {
				Toast.makeText(ctx, R.string.please_select_club, Toast.LENGTH_SHORT).show();
				showTeamMultiSelDialog(BTN_INVITE, selData);
				return;
			}
			else
				startSendInvReq(true);
			break;
		}
	}
}
