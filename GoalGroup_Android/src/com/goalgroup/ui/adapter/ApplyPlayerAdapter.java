package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.PlayerFilterResultItem;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class ApplyPlayerAdapter extends BaseAdapter {

	private Context ctx;
	private ArrayList<PlayerFilterResultItem> datas;
	
	private ImageLoader imgLoader;
	
	public ApplyPlayerAdapter(Context aCtx) {
		ctx = aCtx;
		datas = new ArrayList<PlayerFilterResultItem>();
		
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
		PlayerFilterResultItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.apply_player_result_adapter, null);
			
			holder = new ViewHolder();
			holder.photo = (ImageView)view.findViewById(R.id.apply_player_photo);
			holder.name = (TextView)view.findViewById(R.id.apply_player_name);
			holder.position = (TextView)view.findViewById(R.id.apply_player_base_infos);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data);
		
		return view;
	}
	
	private class ViewHolder {
		public ImageView photo;
		public TextView name;
		public TextView position;
		
		public void initHolder(final PlayerFilterResultItem data) {
			imgLoader.displayImage(data.getPhoto(), photo, GgApplication.img_opt_photo);
			name.setText(data.getName());
			position.setText(StringUtil.getStrFromSelValue(data.getPosition(), CommonConsts.POSITION));
		}
	}
	
	public void addData(ArrayList<PlayerFilterResultItem> newdatas) {
		for (PlayerFilterResultItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void clearData() {
		datas.clear();
	}
	
}
