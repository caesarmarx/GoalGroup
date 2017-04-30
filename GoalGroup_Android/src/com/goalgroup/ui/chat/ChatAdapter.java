package com.goalgroup.ui.chat;

import java.util.ArrayList;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.ui.ProfileActivity;
import com.goalgroup.ui.view.xTextView;
import com.nostra13.universalimageloader.core.ImageLoader;

public class ChatAdapter extends BaseAdapter {

	private Context ctx;
	private ArrayList<ChatEntity> datas;
	
	private ImageLoader imgLoader;

	public ChatAdapter(Context aCtx) {
		ctx = aCtx;
		datas = new ArrayList<ChatEntity>();
		imgLoader = GgApplication.getInstance().getImageLoader();
		// initTestData();
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
		Log.d("ChatAdapter", "getView function , dataset changed");

		ChatEntity data = datas.get(position);
		if (data == null)
			return null;

		ViewHolder holder;
		view = LayoutInflater.from(ctx).inflate(
				data.isMe() == true ? R.layout.chat_msg_right
						: R.layout.chat_msg_left, null);

		holder = new ViewHolder();
		holder.tvID = (TextView) view.findViewById(R.id.username);
		holder.ivPhoto = (ImageView) view.findViewById(R.id.iv_userhead);
		holder.noSent = (ImageView) view.findViewById(R.id.no_sent);
		holder.tvDateTime = (TextView) view.findViewById(R.id.sendtime);
		holder.tvMsgBody = (xTextView) view.findViewById(R.id.chat_msg_body);
		holder.tvMsgBody.setMaxWidth(parent.getMeasuredWidth() - holder.ivPhoto.getLayoutParams().width - holder.ivPhoto.getLayoutParams().width);
		holder.pgBar = (ProgressBar) view.findViewById(R.id.pb_icon);
		
		view.setTag(holder);

		holder = (ViewHolder) view.getTag();

		holder.initHolder(data);

		return view;
	}

	private class ViewHolder {
		private TextView tvID;
		private ImageView ivPhoto;
		private ImageView noSent;
		private TextView tvDateTime;
		private xTextView tvMsgBody;
		private ProgressBar pgBar;

		public void initHolder(final ChatEntity data) {

			Log.d("ChatAdapter", "initHolder func, body: " + data.getMsgBody()
					+ ", type: " + data.getType());

			tvID.setText(data.getID());
			imgLoader.displayImage("", ivPhoto, GgApplication.img_opt_photo);
			
			if (data.isSending()) 
				pgBar.setVisibility(View.VISIBLE);
			else 
				pgBar.setVisibility(View.GONE);
			
			if (!data.getState())
				noSent.setVisibility(View.VISIBLE);
			if (!data.isMe())
				noSent.setVisibility(View.GONE);
			if(data.isMe())
				imgLoader.displayImage(GgApplication.getInstance().getUserPhoto(), ivPhoto, GgApplication.img_opt_photo);
			else
				imgLoader.displayImage(data.getUserPhoto(), ivPhoto, GgApplication.img_opt_photo);
			ivPhoto.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					// TODO Auto-generated method stub
					Intent intent;
					intent = new Intent(ctx, ProfileActivity.class);
					intent.putExtra("user_id", data.getUserID());
					if (data.getUserID() == Integer.valueOf(GgApplication.getInstance().getUserId()))
						intent.putExtra("type", CommonConsts.EDIT_PROFILE);
					else
						intent.putExtra("type", CommonConsts.SHOW_PROFILE);
					ctx.startActivity(intent);
				}
			});
			
			tvDateTime.setText(data.getDateTime());
			if(data.getMsgBody().endsWith("jpg")) {
				tvMsgBody.setMessage(data.getMsgBody(), 1);
			}
				
			else if(data.getMsgBody().endsWith("gga"))
				tvMsgBody.setMessage(data.getMsgBody(), 2);
			else
				tvMsgBody.setMessage(data.getMsgBody(), 0);
		}
	}

	public void clearData() {
		datas.clear();
		return;
	}

	public void addData(ChatEntity data) {
		datas.add(data);
	}
	
	public void removeData(ChatEntity data) {
		datas.remove(data);
	}

//	private void initTestData() {
//		datas = new ArrayList<ChatEntity>();
//		for (int i = 0; i < testData.length; i++)
//			datas.add(testData[i]);
//	}
//
//	private ChatEntity[] testData = {
//			new ChatEntity("Apple", "2015-02-07 13:21", "喂，你好！",
//					ChatGlobal.TYPE_NORMAL_CHAT, false),
//			new ChatEntity("我", "2015-02-07 13:22", "你好，什么事啊？",
//					ChatGlobal.TYPE_IMAGE_CHAT, true)
//
//	};
}
