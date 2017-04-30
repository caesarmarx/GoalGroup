package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.info.GgChatInfo;
import com.goalgroup.common.GgIntentParams;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.ChallengeItem;
import com.goalgroup.model.InvitationItem;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.ProcessInvitationTask;
import com.goalgroup.ui.ClubInfoActivity;
import com.goalgroup.ui.CreateClubActivity;
import com.goalgroup.ui.InvitationActivity;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.NetworkUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

import android.content.Context;
import android.content.Intent;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

public class InvitationListAdapter extends BaseAdapter {
	private final int CLUB_INFO = 0;
	
	private final int HIDE_MENU = 0;
	private final int SHOW_MENU = 1;

	private Context ctx;
	private InvitationActivity parent;
	private ArrayList<InvitationItem> datas;
	
	private ImageLoader imgLoader;
	private GgProgressDialog dlg;
	private MyClubData mClubData;
	
	private int club_id;
	private int user_id;
	private String club_name;
	
	public InvitationListAdapter(Context aCtx) {
		ctx = aCtx;
		parent = (InvitationActivity)aCtx;
		datas = new ArrayList<InvitationItem>();
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

	@Override
	public View getView(int position, View view, ViewGroup parent) {
		InvitationItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.invitation_adapter, null);
			
			holder = new ViewHolder();
			holder.total_area = (FrameLayout)view.findViewById(R.id.area_total_invitation);
			holder.inv_item = (LinearLayout)view.findViewById(R.id.area_inv_item);
			holder.func_delete = (RelativeLayout)view.findViewById(R.id.area_func_delete);
			holder.mark = (ImageView)view.findViewById(R.id.club_photo);
			holder.club = (TextView)view.findViewById(R.id.club_name);
			holder.club.setSelected(true);
			holder.date = (TextView)view.findViewById(R.id.inv_date);
			holder.btn_accept = (ImageButton)view.findViewById(R.id.inv_accept);
			holder.btn_delete = (ImageButton)view.findViewById(R.id.inv_delete);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data, position);
		
		return view;
	}
	
	private int sel_indexs;
	
	private class ViewHolder {
		public FrameLayout total_area;
		public LinearLayout inv_item;
		public RelativeLayout func_delete;
		public ImageView mark;
		public TextView club;
		public TextView date;
		public ImageButton btn_accept;
		public ImageButton btn_delete;
		private int index;
		
		public void initHolder(final InvitationItem data, int position) {
			index = position;
			total_area.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					setHideMenu();
					func_delete.setVisibility(func_delete.getVisibility() == View.GONE ? View.VISIBLE : View.GONE);
					
					if (func_delete.getVisibility() == View.GONE) {
						inv_item.setX(0);
						data.setShowMenu(HIDE_MENU);
					} else {
						int nLayerWidth = func_delete.getWidth();
						if(nLayerWidth <= 0)
							nLayerWidth = dp2px(60);
						inv_item.setX(0 - nLayerWidth);
						data.setShowMenu(SHOW_MENU);
					}
					
					notifyItems();
				}
			});
			
			if (data.getShowMenu() == SHOW_MENU) {
				func_delete.setVisibility(View.VISIBLE);
				int nLayerWidth = func_delete.getWidth(); 
				if(nLayerWidth <= 0)
					nLayerWidth = dp2px(60);
				inv_item.setX(0-nLayerWidth);
			} else {
				func_delete.setVisibility(View.GONE);
				inv_item.setX(0);
			}
			
			imgLoader.displayImage(data.getClubMark(), mark, GgApplication.img_opt_club_mark);
			mark.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					club_id = data.getClubID();
					club_name = data.getClubName();
					if (mClubData.isManagerOfClub(Integer.valueOf(club_id))){
						Intent intent = new Intent(ctx, CreateClubActivity.class);
						intent.putExtra(CommonConsts.CLUB_ID_TAG, Integer.valueOf(club_id));
						intent.putExtra(CommonConsts.CLUB_TYPE_TAG, CommonConsts.EDIT_CLUB);
						parent.startActivityForResult(intent, CLUB_INFO);
						return;
					}
					Intent intent = new Intent(ctx, ClubInfoActivity.class);
					intent.putExtra(GgIntentParams.CLUB_ID, String.valueOf(club_id));
					parent.startActivityForResult(intent, CLUB_INFO);
				}
			});
			
			String info = data.getClubName().concat(ctx.getString(R.string.invitaion_notice));
			club.setText(info);
			date.setText(data.getInvDate());
			
			user_id = Integer.valueOf(GgApplication.getInstance().getUserId());
			
			btn_accept.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					sel_indexs = index;
					club_id = data.getClubID();
					club_name = data.getClubName();
					
					startProcessInvitation(true, CommonConsts.ACCEPT_REQ);
				}
			});
			
			btn_delete.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					sel_indexs = index;
					club_id = data.getClubID();
					club_name = data.getClubName();
					
					startProcessInvitation(true, CommonConsts.REJECT_REQ);
				}
			});
		}
		
	}
	
	public void startProcessInvitation (boolean showdlg, int req_type){
		if(!NetworkUtil.isNetworkAvailable(ctx))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ctx, ctx.getString(R.string.wait));
			dlg.show();
		}
		
		Object[] param = new Object[3];
		param[0] = user_id;
		param[1] = club_id;
		param[2] = req_type;
		
		ProcessInvitationTask task = new ProcessInvitationTask(InvitationListAdapter.this, param);
		task.execute();
	}
	
	public void stopProcessInvitation(int error, String result, int req_type) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (error == 1 ) {
			if (req_type == CommonConsts.ACCEPT_REQ){
				Toast.makeText(ctx, R.string.accept_req_succeed, Toast.LENGTH_SHORT).show();
				GgApplication.getInstance().addClubInfo(String.valueOf(club_id), club_name, 8);
				GgApplication.getInstance().getChatInfo().addClubChatRoom(
						club_id,
						club_name,
						JSONUtil.getValueInt(result, "room_id"), 
						ChatConsts.CHAT_ROOM_MEETING);
			} else 
				Toast.makeText(ctx, R.string.reject_req_succeed, Toast.LENGTH_SHORT).show();
			int count = GgApplication.getInstance().getInvCount();
//			GgApplication.getInstance().setInvCount(count - 1);
			
			datas.remove(sel_indexs);
			notifyDataSetChanged();
		} else {
			if (req_type == CommonConsts.ACCEPT_REQ)
				Toast.makeText(ctx, R.string.accept_req_failed, Toast.LENGTH_SHORT).show();
			else
				Toast.makeText(ctx, R.string.reject_req_failed, Toast.LENGTH_SHORT).show();
		}
	}
	
	public void addData(ArrayList<InvitationItem> newdatas) {
		for (InvitationItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void clearData() {
		datas.clear();
	}
	
	public void deleteData(int index){
		datas.remove(index);
	}
	
	private void setHideMenu() {
		for (int i = 0; i < datas.size(); i++) {
			InvitationItem item = datas.get(i);
			item.setShowMenu(HIDE_MENU);
		}
	}
	
	private int dp2px(int dp) {
		return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp,
				GgApplication.getInstance().getBaseContext().getResources().getDisplayMetrics());	
	}
	
	private void notifyItems() {
		notifyDataSetChanged();
	}
}
