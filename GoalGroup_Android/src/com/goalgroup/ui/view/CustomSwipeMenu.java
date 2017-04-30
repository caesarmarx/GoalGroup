package com.goalgroup.ui.view;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;

/**
 * 
 * @author OYC
 * @date 2015-03-18
 * 
 */
public class CustomSwipeMenu {

	private Context mContext;
	private List<CustomSwipeMenuItem> mItems;
	private int mViewType;

	public CustomSwipeMenu(Context context) {
		mContext = context;
		mItems = new ArrayList<CustomSwipeMenuItem>();
	}

	public Context getContext() {
		return mContext;
	}

	public void addMenuItem(CustomSwipeMenuItem item) {
		mItems.add(item);
	}

	public void removeMenuItem(CustomSwipeMenuItem item) {
		mItems.remove(item);
	}

	public List<CustomSwipeMenuItem> getMenuItems() {
		return mItems;
	}

	public CustomSwipeMenuItem getMenuItem(int index) {
		return mItems.get(index);
	}

	public int getViewType() {
		return mViewType;
	}

	public void setViewType(int viewType) {
		this.mViewType = viewType;
	}

}
