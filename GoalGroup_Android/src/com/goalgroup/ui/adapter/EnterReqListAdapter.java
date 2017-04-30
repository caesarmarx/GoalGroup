package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
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
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.EnterReqItem;
import com.goalgroup.task.ProcessReqTask;
import com.goalgroup.ui.EnterReqListActivity;
import com.goalgroup.ui.ProfileActivity;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.NetworkUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class EnterReqListAdapter extends BaseAdapter {

	private Context ctx;
	
	private EnterReqListActivity parent;
	private ArrayList<EnterReqItem> datas;
	private GgProgressDialog dlg;
	private ImageLoader imgLoader;
	
	private int index;
	private int user_id;
	private int club_id;
	
	private final int HIDE_MENU = 0;
	private final int SHOW_MENU = 1;
	
	public EnterReqListAdapter(Context aCtx, int club_id) {
		this.club_id = club_id;
		parent = (EnterReqListActivity)aCtx;
		ctx = aCtx;
		datas = new ArrayList<EnterReqItem>();
		imgLoader = GgApplication.getInstance().getImageLoader();
//		initTestDatas();
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
		EnterReqItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.enterreq_list_adapter, null);
			
			holder = new ViewHolder();
			holder.total_area = (FrameLayout) view.findViewById(R.id.request_total_area);
			holder.req_list_area = (LinearLayout) view.findViewById(R.id.area_request_list); 
			holder.photo = (ImageView) view.findViewById(R.id.req_photo);
			holder.user = (TextView) view.findViewById(R.id.user_info);
			holder.info = (TextView) view.findViewById(R.id.request_info);
			holder.info.setSelected(true);
			holder.date = (TextView) view.findViewById(R.id.request_date);
			holder.btn_accept = (ImageView) view.findViewById(R.id.req_accept);			
			holder.more_func = (RelativeLayout) view.findViewById(R.id.area_func_delete);
			holder.btn_delete = (ImageView) view.findViewById(R.id.req_delete);		
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data);
		
		return view;
	}
	
	public void addData(ArrayList<EnterReqItem> newsdata) {
		for (EnterReqItem item: newsdata) {
			datas.add(item);
		}
	}
	
	private class ViewHolder {
		public FrameLayout total_area;
		public TextView user;
		public TextView info;
		public TextView date;
		public ImageView photo;
		public ImageView btn_accept;
		public LinearLayout req_list_area;
		public RelativeLayout more_func;
		public ImageView btn_delete;
		
		public void initHolder(final EnterReqItem data) {
					
			imgLoader.displayImage(data.getPhotoUrl(), photo, GgApplication.img_opt_photo);
			user.setText(data.getNickName());
			info.setText(data.getInfo());
			date.setText(data.getDate().substring(0, 10));
			
			total_area.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View view) {
					setHideMenu();
					more_func.setVisibility(more_func.getVisibility() == View.GONE ? View.VISIBLE : View.GONE);
					
					if (more_func.getVisibility() == View.GONE){
						req_list_area.setX(0);
						data.setShowMenu(HIDE_MENU);
					} else {
						int nLayerWidth = more_func.getWidth(); 
						if(nLayerWidth <= 0)
							nLayerWidth = dp2px(60);
						req_list_area.setX(-nLayerWidth);
						data.setShowMenu(SHOW_MENU);
					}
					notifyItems();
				}
			});
			photo.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					Intent intent = new Intent(ctx, ProfileActivity.class);
					intent.putExtra("user_id", data.getUserId());
					intent.putExtra("type", CommonConsts.SHOW_PROFILE);
					ctx.startActivity(intent);
				}
			});
			
			btn_accept.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					user_id = data.getUserId();
					index = datas.indexOf(data);
					startProcessReq(true, CommonConsts.ACCEPT_REQ);			
				}
			});
			
			more_func.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					user_id = data.getUserId();
					index = datas.indexOf(data);
					startProcessReq(true, CommonConsts.REJECT_REQ);			
				}
			});
			
			btn_delete.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					user_id = data.getUserId();
					index = datas.indexOf(data);
					startProcessReq(true, CommonConsts.REJECT_REQ);			
				}
			});

			if (data.getShowMenu() == HIDE_MENU) {
				more_func.setVisibility(View.GONE);
				req_list_area.setX(0);
			}
		}
	}
	
	public void procEject(int position) {
		EnterReqItem item = datas.get(position);
		user_id = item.getUserId();
		this.index = position;
		
		startProcessReq(true, CommonConsts.REJECT_REQ);
	}
	
	public void startProcessReq(boolean showdlg, int req_type) {
		if(!NetworkUtil.isNetworkAvailable(ctx))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ctx, ctx.getString(R.string.wait));
			dlg.show();
		}
		
		Object[] param;
		param = new Object[3];
		param[0] = user_id;
		param[1] = club_id;
		param[2] = req_type;
		
		ProcessReqTask task = new ProcessReqTask(EnterReqListAdapter.this, param);
		task.execute();
	}
	
	public void stopProcessReq(int result, int req_type) {
		if (dlg != null){
			dlg.dismiss();
			dlg = null;
		}
		if (result == 1 ) {
			if (req_type == CommonConsts.ACCEPT_REQ)
				Toast.makeText(ctx, R.string.accept_req_succeed, Toast.LENGTH_SHORT).show();
			else
				Toast.makeText(ctx, R.string.reject_req_succeed, Toast.LENGTH_SHORT).show();

			parent.RemoveItem(index);
		} else {
			if (req_type == CommonConsts.ACCEPT_REQ)
				Toast.makeText(ctx, R.string.accept_req_failed, Toast.LENGTH_SHORT).show();
			else
				Toast.makeText(ctx, R.string.reject_req_failed, Toast.LENGTH_SHORT).show();
		}
	}
	/////////////////
	public void setHideMenu() {
		for (int i = 0; i < datas.size(); i++) {
			EnterReqItem item = datas.get(i);
			item.setShowMenu(HIDE_MENU);
		}
	}
	
	public void deleteData(int index) {
		datas.remove(index);
	}
	
	private int dp2px(int dp) {
		return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp,
				GgApplication.getInstance().getBaseContext().getResources().getDisplayMetrics());	
	}
	
	public void notifyItems(){
		notifyDataSetChanged();
	}
}