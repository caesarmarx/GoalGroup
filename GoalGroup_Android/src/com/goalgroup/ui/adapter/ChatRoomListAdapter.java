package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import com.goalgroup.R;
import com.goalgroup.model.ChatRoomItem;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class ChatRoomListAdapter extends BaseAdapter {

	private Context ctx;
	private ArrayList<ChatRoomItem> datas;
	
	public ChatRoomListAdapter(Context aCtx) {
		ctx = aCtx;
		initTestDatas();
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
		ChatRoomItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.chatroom_list_adapter, null);
			
			holder = new ViewHolder();
			holder.name = (TextView)view.findViewById(R.id.chatroom_list_name);
			holder.last_chat = (TextView)view.findViewById(R.id.chatroom_list_lastchat);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data);
		
		return view;
	}
	
	private class ViewHolder {
		public TextView name;
		public TextView last_chat;
		
		public void initHolder(ChatRoomItem data) {
			name.setText(data.getRoomName());
			last_chat.setText(data.getLastChat());
		}
	}
	
	private void initTestDatas() {
		datas = new ArrayList<ChatRoomItem>();
		datas.add(testDatas[0]);
		datas.add(testDatas[1]);
		datas.add(testDatas[2]);
		datas.add(testDatas[3]);
		datas.add(testDatas[4]);
		datas.add(testDatas[5]);
		datas.add(testDatas[6]);
		datas.add(testDatas[7]);
		datas.add(testDatas[8]);
		datas.add(testDatas[9]);
		datas.add(testDatas[10]);
		datas.add(testDatas[11]);
		datas.add(testDatas[12]);
	}
	
	private ChatRoomItem[] testDatas = {
		new ChatRoomItem("", "�û���1", "�Ự����1", "3"), 
		new ChatRoomItem("", "�û���2", "�Ự����2", "3"),
		new ChatRoomItem("", "�û���3", "�Ự����3", "3"),
		new ChatRoomItem("", "�û���4", "�Ự����4", "3"),
		new ChatRoomItem("", "�û���5", "�Ự����5", "3"),
		new ChatRoomItem("", "�û���6", "�Ự����6", "3"),
		new ChatRoomItem("", "�û���7", "�Ự����7", "3"),
		new ChatRoomItem("", "�û���8", "�Ự����8", "3"),
		new ChatRoomItem("", "�û���9", "�Ự����9", "3"),
		new ChatRoomItem("", "�û���10", "�Ự����10", "3"),
		new ChatRoomItem("", "�û���11", "�Ự����11", "3"),
		new ChatRoomItem("", "�û���12", "�Ự����12", "3"),
		new ChatRoomItem("", "�û���13", "�Ự����13", "3"),
	};
}
