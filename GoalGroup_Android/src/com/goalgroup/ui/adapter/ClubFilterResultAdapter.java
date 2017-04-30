package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.app.Activity;
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
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.ClubFilterResultItem;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.RegisterUserToClubTask;
import com.goalgroup.ui.ClubInfoActivity;
import com.goalgroup.ui.CreateClubActivity;
import com.goalgroup.ui.NewChallengeActivity;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class ClubFilterResultAdapter extends BaseAdapter {
	private final int CLUB_INFO = 0;
	
	private final int HIDE_MENU = 0;
	private final int SHOW_MENU = 1;
	
	private Activity ctx;
	private ArrayList<ClubFilterResultItem> datas;
	
	private ImageLoader imgLoader;
	private int clubID;
	private GgProgressDialog dlg;
	
	private MyClubData mClubData;
	
	public ClubFilterResultAdapter(Activity aCtx) {
		ctx = aCtx;
		datas = new ArrayList<ClubFilterResultItem>();
		
		mClubData = new MyClubData();
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
	
	private int dp2px(int dp) {
		return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp,
				GgApplication.getInstance().getBaseContext().getResources().getDisplayMetrics());	
	}

	@Override
	public View getView(int position, View view, ViewGroup parent) {
		ClubFilterResultItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.club_filter_result_adapter, null);
			
			holder = new ViewHolder();
			holder.total_area = (FrameLayout)view.findViewById(R.id.club_market_total);
			holder.club_area = (LinearLayout)view.findViewById(R.id.club_area);
			holder.mark = (ImageView)view.findViewById(R.id.club_mark);
			holder.name = (TextView)view.findViewById(R.id.club_name);
			holder.members = (TextView)view.findViewById(R.id.club_member_count);
			holder.points = (TextView)view.findViewById(R.id.club_points);
			holder.stars[0] = (ImageView)view.findViewById(R.id.star01);
			holder.stars[1] = (ImageView)view.findViewById(R.id.star02);
			holder.stars[2] = (ImageView)view.findViewById(R.id.star03);
			holder.aver_ages = (TextView)view.findViewById(R.id.club_aver_ages);
			holder.dates = (TextView)view.findViewById(R.id.club_dates);
			holder.areas = (TextView)view.findViewById(R.id.club_areas);
			holder.more_func = (LinearLayout)view.findViewById(R.id.club_market_funcs);
			holder.join_club = (ImageView)view.findViewById(R.id.market_join_club);
			holder.chall_club = (ImageView)view.findViewById(R.id.market_chall_club);

			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data);
		return view;
	}
	
	private class ViewHolder {

		public FrameLayout total_area;
		public LinearLayout club_area;
		public ImageView mark;
		public TextView name;
		public TextView members;
		public TextView points;
		public ImageView[] stars = new ImageView[3];
		public TextView aver_ages;
		public TextView dates;
		public TextView areas;
		
		private LinearLayout more_func;
		private ImageView join_club;
		private ImageView chall_club;
		
		private ClubFilterResultItem selectedItem;
		
		public void initHolder(final ClubFilterResultItem data) {
			total_area.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					setHideMenu();
					more_func.setVisibility(more_func.getVisibility() == View.GONE ? View.VISIBLE : View.GONE);
					
					if(more_func.getVisibility() == View.GONE){
						club_area.setX(0);
						data.setShowMenu(HIDE_MENU);
					} else {
						int nLayerWidth = more_func.getWidth(); 
						if(nLayerWidth <= 0)
							nLayerWidth = dp2px(60);
						club_area.setX(0-nLayerWidth+10);
						data.setShowMenu(SHOW_MENU);
					}
					notifyItems();
				}
			});
			selectedItem = data;
			imgLoader.displayImage(data.getClubMark(), mark, GgApplication.img_opt_club_mark);
			mark.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					clubID = selectedItem.getClubID();
//					Intent intent = new Intent(ctx, ClubInfoActivity.class);
//					intent.putExtra(GgIntentParams.CLUB_ID, String.valueOf(clubID));
//					ctx.startActivityForResult(intent, CLUB_INFO);
					
					if (mClubData.isManagerOfClub(Integer.valueOf(clubID))){
						Intent intent = new Intent(ctx, CreateClubActivity.class);
						intent.putExtra(CommonConsts.CLUB_ID_TAG, clubID);
						intent.putExtra(CommonConsts.CLUB_TYPE_TAG, CommonConsts.EDIT_CLUB);
						ctx.startActivityForResult(intent, CLUB_INFO);
						return;
					}
					Intent intent = new Intent(ctx, ClubInfoActivity.class);
					intent.putExtra("join_type", CommonConsts.JOIN_CLUB);
					intent.putExtra(GgIntentParams.CLUB_ID, String.valueOf(clubID));
					ctx.startActivityForResult(intent, CLUB_INFO);
				}
			});
			name.setText(selectedItem.getName());
			String value = "";
			value = String.valueOf(data.getMembers());
			members.setText(value);
			value = ctx.getString(R.string.action_point).concat(": ");
			value = value.concat(String.valueOf(data.getPoints()));
			points.setText(value);
			aver_ages.setText(String.valueOf(data.getAverAge()));
			dates.setText(StringUtil.getStrFromSelValue(data.getPlayDates(), CommonConsts.ACT_DAY));
			areas.setText(data.getPlayAreas());
			
			if (data.getShowMenu() == SHOW_MENU) {
				more_func.setVisibility(View.VISIBLE);
				int nLayerWidth = more_func.getWidth(); 
				if(nLayerWidth <= 0)
					nLayerWidth = dp2px(60);
				club_area.setX(0-nLayerWidth+10);
			} else {
				more_func.setVisibility(View.GONE);
				club_area.setX(0);
			}
			
			join_club.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					// TODO Auto-generated method stub
					if (mClubData.isOwnClub(selectedItem.getClubID())){
						Toast.makeText(ctx, ctx.getString(R.string.user_club_exist), Toast.LENGTH_LONG).show();
						return;
					}
					Object[] registerInfo = new Object[2];
					registerInfo[0] = GgApplication.getInstance().getUserId();
					registerInfo[1] = String.valueOf(selectedItem.getClubID());
					startRegisterUserToClub(true, registerInfo);
				}
			});
			
			chall_club.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					// TODO Auto-generated method stub
					MyClubData mClubData = new MyClubData();
					GgApplication.getInstance().setChallFlag(false);
					if (!mClubData.isOwner()){
						Toast.makeText(ctx, R.string.no_manager, Toast.LENGTH_LONG).show();
						return;
					}
					if (!mClubData.isManagerOfClub(selectedItem.getClubID())) {
						Intent intent = new Intent(ctx, NewChallengeActivity.class);
						intent.putExtra(GgIntentParams.CLUB_NAME, selectedItem.getName());
						intent.putExtra(GgIntentParams.CLUB_ID, String.valueOf(selectedItem.getClubID()));
						intent.putExtra("type", CommonConsts.NEW_CHALLENGE);
						intent.putExtra("challType", CommonConsts.PROCLAIM_GAME);
						ctx.startActivity(intent);
					} else {
						Toast.makeText(ctx, R.string.own_club, Toast.LENGTH_LONG).show();
					}
				}
			});
			
		}

	}
	
	public void addData(ArrayList<ClubFilterResultItem> newdatas) {
		for (ClubFilterResultItem item : newdatas) {
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
			ClubFilterResultItem item = datas.get(i);
			item.setShowMenu(HIDE_MENU);
		}
	}
	
	public void startRegisterUserToClub(boolean showdlg, Object[] registerInfo) {
		if (!NetworkUtil.isNetworkAvailable(ctx))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ctx, ctx.getString(R.string.wait));
			dlg.show();
		}
		
		RegisterUserToClubTask task = new RegisterUserToClubTask(ClubFilterResultAdapter.this, registerInfo);
		task.execute();
	}
	
	public void stopRegisterUserToClub(int data) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		switch (data) {
		case 0:
			Toast.makeText(ctx, ctx.getString(R.string.register_user_club_failed), Toast.LENGTH_LONG).show();
			break;
		case 1:
			Toast.makeText(ctx, ctx.getString(R.string.register_user_club_success), Toast.LENGTH_LONG).show();
			break;
		case 2:
			Toast.makeText(ctx, ctx.getString(R.string.request_exist), Toast.LENGTH_LONG).show();
			break;
		case 3:
			Toast.makeText(ctx, ctx.getString(R.string.request_rec_reject), Toast.LENGTH_LONG).show();
			break;
		default:
			break;
		}
	}
}
