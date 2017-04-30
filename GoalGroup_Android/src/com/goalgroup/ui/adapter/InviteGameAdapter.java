package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Handler;
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

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.InvGameItem;
import com.goalgroup.model.InvitationItem;
import com.goalgroup.model.MyClubData;
import com.goalgroup.ui.ClubInfoActivity;
import com.goalgroup.ui.CreateClubActivity;
import com.goalgroup.ui.InvGameActivity;
import com.goalgroup.utils.DateUtil;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class InviteGameAdapter extends BaseAdapter {

	public final static int BTN_ACCEPT = 0;
	public final static int BTN_DELETE = 1;
	public final int CLUB_INFO = 2;
	
	private final int HIDE_MENU = 0;
	private final int SHOW_MENU = 1;
	
	private InvGameActivity parent;
	private Context ctx;
	private ArrayList<InvGameItem> datas;
	private MyClubData mClubData;
	
	private ImageLoader imgLoader;
	
	public boolean displayRemainTime = true;
	
	public InviteGameAdapter(Context aCtx) {
		parent = (InvGameActivity)aCtx;
		ctx = aCtx;
		datas = new ArrayList<InvGameItem>();
		mClubData = new MyClubData();
//		initTestDatas();
		
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
	
	public void notifyItems(){
		notifyDataSetChanged();
	}

	@Override
	public View getView(int position, View view, ViewGroup parent) {
		InvGameItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.inv_game_adapter, null);
			
			holder = new ViewHolder();
			holder.area_inv_total = (FrameLayout)view.findViewById(R.id.area_inv_total);
			holder.area_inv_item_bk = (RelativeLayout)view.findViewById(R.id.area_inv_item_bk);
			holder.area_inv_item = (RelativeLayout)view.findViewById(R.id.area_inv_item);
			holder.area_inv_funcs = (LinearLayout)view.findViewById(R.id.area_inv_funcs);
			holder.player_num = (TextView)view.findViewById(R.id.player_number);
			holder.game_date = (TextView)view.findViewById(R.id.game_date);
			holder.remained_time = (TextView)view.findViewById(R.id.game_remain_time);
			holder.club_name_01 = (TextView)view.findViewById(R.id.club_name_01);
			holder.club_mark_01 = (ImageView)view.findViewById(R.id.club_mark_01);
			holder.inv_mark_01 = view.findViewById(R.id.inv_mark_01);
			holder.club_name_02 = (TextView)view.findViewById(R.id.club_name_02);
			holder.club_mark_02 = (ImageView)view.findViewById(R.id.club_mark_02);
			holder.inv_mark_02 = view.findViewById(R.id.inv_mark_02);
			holder.game_time = (TextView)view.findViewById(R.id.game_time);
			holder.stadium = (TextView)view.findViewById(R.id.stadium);
			holder.func_accept = (ImageView)view.findViewById(R.id.inv_game_func_accept);
			holder.func_delete = (ImageView)view.findViewById(R.id.inv_game_func_delete);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data, position);
		
		return view;
	}

	private int select_index;
	
	private class ViewHolder {
		public FrameLayout area_inv_total;
		public RelativeLayout area_inv_item;
		public RelativeLayout area_inv_item_bk;
		public LinearLayout area_inv_funcs;
		public TextView player_num;
		public TextView game_date;
		public TextView remained_time;
		public TextView club_name_01;
		public ImageView club_mark_01;
		public View inv_mark_01;
		public TextView club_name_02;
		public ImageView club_mark_02;
		public View inv_mark_02;
		public TextView game_time;
		public TextView stadium;
		public ImageView func_accept;
		public ImageView func_delete;
		private Handler timerHandler;
		private Runnable timerRunnable;
		
		private String org_game_datetime;
		private String countdown = "";
		
		private int index;
		
//		private void startCountDown() {
//			
//			timerRunnable = new Runnable() {
//				
//				@Override
//				public void run() {
//					countdown = DateUtil.getDiffTime(org_game_datetime);
//					if(countdown.split(":")[2].startsWith("-"))
//					{
//						countdown = "00:00:00";
//						System.out.println("Remain_Time:" + countdown);
//						stopCountDown();
//					}
//					if(displayRemainTime)
//						remained_time.setText(countdown);
//					timerHandler.postDelayed(timerRunnable, 1000);
//				}
//			};
//			
//			timerHandler = new Handler();
//			timerHandler.post(timerRunnable);
//		}
//		
//		private void stopCountDown() {
//			if (timerHandler == null)
//				return;
//			timerHandler.removeCallbacks(timerRunnable);
//			timerHandler = null;
//		}
		
		public void initHolder(final InvGameItem data, final int position) {
			index = position;
			area_inv_total.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					setHideMenu();
					area_inv_funcs.setVisibility(area_inv_funcs.getVisibility() == View.GONE ? View.VISIBLE : View.GONE);
					
					if (area_inv_funcs.getVisibility() == View.GONE) {
						area_inv_item_bk.setX(0);
//						area_inv_item_bk.setX(0);
//						area_inv_item_bk.setBackgroundResource(R.color.white);
						data.setShowMenu(HIDE_MENU);
					} else {
						int nLayerWidth = area_inv_funcs.getWidth();
						if(nLayerWidth <= 0)
							nLayerWidth = dp2px(60);
						area_inv_item_bk.setX(0 - (nLayerWidth - 10));
//						area_inv_item_bk.setBackgroundResource(R.color.pattern_green);
//						area_inv_item_bk.setX(-10);
						data.setShowMenu(SHOW_MENU);
					}
					
					notifyItems();
				}
			});
			
			if (data.getShowMenu() == SHOW_MENU) {
				area_inv_funcs.setVisibility(View.VISIBLE);
				int nLayerWidth = area_inv_funcs.getWidth(); 
				if(nLayerWidth <= 0)
					nLayerWidth = dp2px(60);
				area_inv_item_bk.setX(0-(nLayerWidth-10));
			} else {
				area_inv_funcs.setVisibility(View.GONE);
				area_inv_item_bk.setX(0);
			}
			
			player_num.setText(String.format("%d%s", data.getPlayerNumber(), ctx.getString(R.string.player_number)));
			game_date.setText(String.format("%s / %s", data.getDate(), StringUtil.getWeekDay(data.getWday())));
			remained_time.setText(countdown);
			club_name_01.setText(data.getClubName01());
			imgLoader.displayImage(data.getClubMark01(), club_mark_01, GgApplication.img_opt_club_mark);
			club_mark_01.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
//					Intent intent = new Intent(ctx, ClubInfoActivity.class);
//					intent.putExtra(GgIntentParams.CLUB_ID, Integer.toString(data.getClubId01()));
//					ctx.startActivity(intent);
					getClubInfo(Integer.toString(data.getClubId01()));
				}
			});
			org_game_datetime = DateUtil.getCurrentYear() + "-" + data.getDate() + " " + data.getTime() + ":00";
			
//			stopCountDown();
//			startCountDown();
			
			club_name_02.setText(data.getClubName02());
			imgLoader.displayImage(data.getClubMark02(), club_mark_02, GgApplication.img_opt_club_mark);
			club_mark_02.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
//					Intent intent = new Intent(ctx, ClubInfoActivity.class);
//					intent.putExtra(GgIntentParams.CLUB_ID, Integer.toString(data.getClubId02()));
//					ctx.startActivity(intent);
					getClubInfo(Integer.toString(data.getClubId02()));
				}
			});

			game_time.setText(data.getTime());
			stadium.setText(data.getStadium());
			
			inv_mark_01.setVisibility(data.whichIsInvTeam() == 1 ? View.VISIBLE : View.GONE);
			inv_mark_02.setVisibility(data.whichIsInvTeam() == 0 ? View.VISIBLE : View.GONE);
			
			func_accept.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					select_index = index;
					showConfDialog(BTN_ACCEPT, datas.get(index), index);
				}
			});
			
			func_delete.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					select_index = index;
					showConfDialog(BTN_DELETE, datas.get(index), index);
				}
			});
		}
		
		private void getClubInfo(String club_id) {
			if (mClubData.isManagerOfClub(Integer.valueOf(club_id))){
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
	
	public void addData(ArrayList<InvGameItem> newdatas) {
		for (InvGameItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void clearData() {
		datas.clear();
	}
	
	public void deleteData(int index) {
		datas.remove(index);
	}
	
	private InvGameItem selectData;
	
	public void showConfDialog(final int from, InvGameItem data, int position) {
		selectData = data;
		
		int[] msgIds = {
			R.string.inv_game_accept_conf, R.string.inv_game_delete_conf
		};
		
		AlertDialog dialog = new AlertDialog.Builder(ctx)
		.setTitle(R.string.temp_invitation)
		.setMessage(msgIds[from])
		.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int item) {
				int type = (from == BTN_ACCEPT) ? 1 : 2;
				parent.startProcInvGame(type, selectData.getInvTeamId(), selectData.getGameId());
			}
		})
		.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int item) {
				dialog.dismiss();
			}
		}).create();		
		dialog.show();
	}
	
	private void setHideMenu() {
		for (int i = 0; i < datas.size(); i++) {
			InvGameItem item = datas.get(i);
			item.setShowMenu(HIDE_MENU);
		}
	}
	
	private int dp2px(int dp) {
		return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp,
				GgApplication.getInstance().getBaseContext().getResources().getDisplayMetrics());	
	}
	
//	private void initTestDatas() {
//		datas = new ArrayList<InvGameItem>();
//		for (int i = 0; i < testData.length; i++)
//			datas.add(testData[i]);
//	}
//	
//	private InvGameItem[] testData = {
//		new InvGameItem("俱乐部A", "", "俱乐部E", "", 0, 5, "03-07", "周六", "15:00", "东北路小学"),
//		new InvGameItem("俱乐部B", "", "俱乐部C", "", 0, 7, "03-06", "周五", "11:00", "东北路小学"), 
//		new InvGameItem("俱乐部C", "", "俱乐部F", "", 0, 6, "03-05", "周四", "11:00", "东北路小学"), 
//		new InvGameItem("俱乐部D", "", "俱乐部B", "", 0, 11, "03-04", "周三", "15:30", "东北路小学"), 
//		new InvGameItem("俱乐部E", "", "俱乐部G", "", 0, 9, "03-03", "周二", "10:00", "东北路小学")
//	};
}
