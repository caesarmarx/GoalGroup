package com.goalgroup.ui.view;

import java.util.List;

import com.goalgroup.R;

import android.annotation.SuppressLint;
import android.graphics.Color;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.LinearLayout.LayoutParams;

/**
 * 
 * @author OYC
 * @date 2015-03-18
 * 
 */
public class CustomSwipeMenuView extends LinearLayout implements OnClickListener {

	private final float HOR_WEIGHT1 = 0.13f;
	private final float HOR_WEIGHT2 = 0.112f;
	private final float HOR_WEIGHT3 = 0.19f;
	
	private CustomSwipeMenuLayout mLayout;
	private CustomSwipeMenu mMenu;
	private OnSwipeItemClickListener onItemClickListener;
	private int position;

	public int getPosition() {
		return position;
	}

	public void setPosition(int position) {
		this.position = position;
	}

	public CustomSwipeMenuView(CustomSwipeMenu menu, CustomSwipeListView listView, boolean isHor, int padding) {
		super(menu.getContext());

		mMenu = menu;
		List<CustomSwipeMenuItem> items = menu.getMenuItems();
		setBackgroundResource(com.goalgroup.R.color.white);
//		setBackgroundColor(Color.BLACK);//kyr
		
		LinearLayout sub1 = null, sub2 = null, sub3 = null;
		LinearLayout parentLayout = new LinearLayout(getContext());		
		LayoutParams params = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT);
		
		parentLayout.setLayoutParams(params);
		parentLayout.setOrientation(LinearLayout.VERTICAL);
		
		if (isHor) {
			sub1 = new LinearLayout(getContext());
			LayoutParams subparams = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT, HOR_WEIGHT1);
			sub1.setGravity(Gravity.CENTER);
			sub1.setLayoutParams(subparams);
			parentLayout.addView(sub1);
			
			sub2 = new LinearLayout(getContext());
			subparams = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT, HOR_WEIGHT2);
			sub2.setGravity(Gravity.CENTER);
			sub2.setLayoutParams(subparams);
			parentLayout.addView(sub2);
			
			sub3 = new LinearLayout(getContext());
			subparams = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT, HOR_WEIGHT3);
			sub3.setGravity(Gravity.CENTER);
			sub3.setLayoutParams(subparams);
			parentLayout.addView(sub3);
		} else {
			if (padding > 0){
				sub1 = new LinearLayout(getContext());
				LayoutParams subparams = new LayoutParams(LayoutParams.WRAP_CONTENT, padding);
				sub1.setLayoutParams(subparams);
				parentLayout.addView(sub1);
			}
		}
		
		addView(parentLayout);
		
		int id = 0;
		float avgweight = 1.0f / items.size();
		for (CustomSwipeMenuItem item : items) {
			addItem(isHor ? sub2 : parentLayout, item, id++, isHor, avgweight);
		}
	}

	private void addItem(LinearLayout parentLayout, CustomSwipeMenuItem item, int id, boolean isHor, float weight) {
		LayoutParams params;
		if (!isHor)
			params = new LayoutParams(item.getWidth(), LayoutParams.WRAP_CONTENT, weight);
		else
			params = new LayoutParams(item.getWidth(), LayoutParams.WRAP_CONTENT);
		
		LinearLayout parent = new LinearLayout(getContext());
		parent.setId(id);

//		if (isHor)
		parent.setOrientation(LinearLayout.VERTICAL);
		parent.setLayoutParams(params);
		parent.setBackgroundDrawable(item.getBackground());
		parent.setOnClickListener(this);
		parent.setGravity(Gravity.CENTER);
		
		if (parentLayout == null)
			addView(parent);
		else {
			parentLayout.addView(parent);
		}	
		if (item.getIcon() != null) {
			parent.addView(createIcon(item));
			parent.addView(createText(item));
		}
		/*if (!TextUtils.isEmpty(item.getTitle())) {
			parent.addView(createTitle(item));
		}*/

	}

	private ImageView createIcon(CustomSwipeMenuItem item) {
		ImageView iv = new ImageView(getContext());
		iv.setImageDrawable(item.getIcon());
		return iv;
	}
	
	private TextView createText(CustomSwipeMenuItem item) {
		TextView tv = new TextView(getContext());
		tv.setText(item.getTitle());
		tv.setTextColor(item.getTitleColor());
		tv.setPadding(0,0,0,0);
		tv.setGravity(Gravity.CENTER);
		return tv;
	}

	private TextView createTitle(CustomSwipeMenuItem item) {
		TextView tv = new TextView(getContext());
		tv.setText(item.getTitle());
		tv.setGravity(Gravity.CENTER);
		tv.setTextSize(item.getTitleSize());
		tv.setTextColor(item.getTitleColor());
		return tv;
	}

	@Override
	public void onClick(View v) {
		if (onItemClickListener != null && mLayout.isOpen()) {
			onItemClickListener.onItemClick(this, mMenu, v.getId());
		}
	}

	public OnSwipeItemClickListener getOnSwipeItemClickListener() {
		return onItemClickListener;
	}

	public void setOnSwipeItemClickListener(OnSwipeItemClickListener onItemClickListener) {
		this.onItemClickListener = onItemClickListener;
	}

	public void setLayout(CustomSwipeMenuLayout mLayout) {
		this.mLayout = mLayout;
	}

	public static interface OnSwipeItemClickListener {
		void onItemClick(CustomSwipeMenuView view, CustomSwipeMenu menu, int index);
	}
}
