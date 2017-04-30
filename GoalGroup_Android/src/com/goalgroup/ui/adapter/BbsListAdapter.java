package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.model.BbsItem;
import com.goalgroup.ui.ReadBBSActivity;
import com.goalgroup.ui.fragment.BBSFragment;
import com.nostra13.universalimageloader.core.ImageLoader;

public class BbsListAdapter extends BaseAdapter {
	
	public static final int TYPE_ONE_ITEM = 0;
	public static final int TYPE_TOP_ITEM = 1;
	public static final int TYPE_MID_ITEM = 2;
	public static final int TYPE_BOT_ITEM = 3;
	public final int BBSITEM = 1;
	
	private Context ctx;
	private BBSFragment parent;
	private ArrayList<BbsItem> datas;
	
	private ImageLoader imgLoader;
	
	public BbsListAdapter(Context aCtx, BBSFragment frg) {
		ctx = aCtx;
		parent = frg;
		datas = new ArrayList<BbsItem>();
		
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
		BbsItem data = datas.get(position);
		BbsItem dataBefore = null;
		BbsItem dataAfter = null;
			
		if (data == null)
			return null;
		
		if (datas.size() > 1) {
			if (position == 0){
				dataAfter = datas.get(position + 1);
				if (dataAfter.getDateTime().equals(data.getDateTime()))
					data.setType(1);
				else
					data.setType(0);
			}else if (position > 0 && position < datas.size() - 1) {
				dataBefore = datas.get(position - 1);
				dataAfter = datas.get(position + 1);
				if (!data.getDateTime().equals(dataBefore.getDateTime()) &&
						!data.getDateTime().equals(dataAfter.getDateTime())) {
						data.setType(0);
				} else if (!data.getDateTime().equals(dataBefore.getDateTime()) &&
							data.getDateTime().equals(dataAfter.getDateTime())) {
					data.setType(1);
				} else if (data.getDateTime().equals(dataBefore.getDateTime()) &&
							data.getDateTime().equals(dataAfter.getDateTime())) {
					data.setType(2);
				} else {
					data.setType(3);
				}
			} else {
				dataBefore = datas.get(position - 1);
				if (!data.getDateTime().equals(dataBefore.getDateTime())) {
					data.setType(0);
				} else if (data.getDateTime().equals(dataBefore.getDateTime())) {
					data.setType(3);
				}
			}
		} else {
			data.setType(0);
		}
			
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.bbs_list_adapter, null);
			
			holder = new ViewHolder();
//			holder.title = (TextView)view.findViewById(R.id.bbs_title);
			holder.areaBbsItem = (View)view.findViewById(R.id.area_bbs_contents);
			holder.datetime_ly = (View)view.findViewById(R.id.date_time_ly);
			holder.datetime = (TextView)view.findViewById(R.id.date_time);
			holder.cont_bg = (View)view.findViewById(R.id.area_bbs_contents);
			holder.photo = (ImageView)view.findViewById(R.id.user_photo);
			holder.username = (TextView)view.findViewById(R.id.user_name);
			holder.bbs_contents = (TextView)view.findViewById(R.id.bbs_contents);
//			holder.ivReplyNumber = (ImageView)view.findViewById(R.id.iv_reply_number);
			holder.reply_number = (TextView)view.findViewById(R.id.reply_number);
			holder.content_pic = (ImageView)view.findViewById(R.id.contents_pic);
			holder.pic_area = (View)view.findViewById(R.id.contents_pic_area);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data);
		
		return view;
	}
	
	private class ViewHolder {
		public View areaBbsItem;
		public View datetime_ly;
		public TextView datetime;
		public View cont_bg;
		public ImageView photo;
		public TextView username;
//		public ImageView ivReplyNumber;
		public TextView reply_number;
		public ImageView content_pic;
		public View pic_area;
		private TextView bbs_contents;
		
		private int[] bg_ids = {
			R.drawable.item_normal_selector, R.drawable.item_normal_selector, R.drawable.item_normal_selector, R.drawable.item_normal_selector
		};
		
		public void initHolder(final BbsItem data) {
			areaBbsItem.setOnClickListener(new View.OnClickListener() {				
				@Override
				public void onClick(View view) {
					Intent intent = new Intent(ctx, ReadBBSActivity.class);
					intent.putExtra("bbs_id", data.getBBSId());
					parent.startActivityForResult(intent, BBSITEM);
				}
			});
			
			if (data.getType() == TYPE_ONE_ITEM || data.getType() == TYPE_TOP_ITEM)
				datetime_ly.setVisibility(View.VISIBLE);
			else
				datetime_ly.setVisibility(View.GONE);
			
			cont_bg.setBackgroundResource(bg_ids[data.getType()]);			
			datetime.setText(data.getDateTime());
			bbs_contents.setText("   "+data.getContents());
			imgLoader.displayImage(data.getUserPhoto(), photo, GgApplication.img_opt_photo);
			photo.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					
				}
			});
			username.setText(data.getUserName());
			reply_number.setText(String.valueOf(data.getReplyNumber()));
			
			String image_url = data.getContentPic();
			if (image_url.indexOf(".png") != -1 || image_url.indexOf(".jpg") != -1){
//				content_pic.setVisibility(View.VISIBLE);
				pic_area.setVisibility(View.VISIBLE);
				imgLoader.displayImage(data.getContentPic(), content_pic, GgApplication.img_opt_bbs);
			} else {
//				content_pic.setVisibility(View.GONE);
				pic_area.setVisibility(View.GONE);
			}
			
			if (data.getReplyNumber() == 0) {
				reply_number.setVisibility(View.GONE);
//				ivReplyNumber.setVisibility(View.GONE);
			} else {
				reply_number.setVisibility(View.VISIBLE);
//				ivReplyNumber.setVisibility(View.VISIBLE);
			}
		}
	}
	
	public void addData(ArrayList<BbsItem> newdatas) {
		for (BbsItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void clearData() {
		datas.clear();
	}
}
