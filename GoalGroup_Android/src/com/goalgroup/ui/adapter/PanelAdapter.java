package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Typeface;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.ViewGroup.LayoutParams;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class PanelAdapter extends BaseAdapter {
	
	private Context ctx;
	private ArrayList<String> names;
	private ArrayList<Integer> imgs;
	private Display display;
	private int width;
	
	public PanelAdapter(Context ctx, ArrayList<String> names, ArrayList<Integer> imgs) {
		this.ctx = ctx;
		this.names = names;
		this.imgs = imgs;
		display = ((WindowManager)ctx.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
		width = display.getWidth() / 6;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return imgs.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return imgs.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		LinearLayout layout = new LinearLayout(ctx);

		layout.setOrientation(LinearLayout.VERTICAL);
		layout.setGravity(Gravity.CENTER);
		layout.setPadding(0, 20, 0, 0);
//		layout.setLayoutParams(new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
		
		LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(
			    LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		layoutParams.setMargins(0, 0, 0, 10);
		
		TextView tv_item = new TextView(ctx);
		tv_item.setPadding(0, 10, 0, 0);
		
		tv_item.setGravity(Gravity.CENTER);
		tv_item.setLayoutParams(new GridView.LayoutParams(
				LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT));
		tv_item.setText(names.get(position));
		tv_item.setTextColor(0xFF8C8C8C);
		tv_item.setTextSize(16);
		tv_item.setTypeface(Typeface.DEFAULT_BOLD, 1);
		
		ImageView img_item = new ImageView(ctx);
		
		img_item.setLayoutParams(new LayoutParams(width, width));
		img_item.setImageResource(imgs.get(position));
		layout.addView(img_item);
		layout.addView(tv_item, layoutParams);
		
		return layout;
	}
}
