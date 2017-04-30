package com.goalgroup.ui.view;

import com.goalgroup.ui.view.CustomSwipeListView.OnMenuItemClickListener;
import com.goalgroup.ui.view.CustomSwipeMenuView.OnSwipeItemClickListener;

import android.content.Context;
import android.database.DataSetObserver;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView.LayoutParams;
import android.widget.ListAdapter;
import android.widget.WrapperListAdapter;

import com.goalgroup.ui.view.CustomSwipeListView.OnMenuItemClickListener;
import com.goalgroup.ui.view.CustomSwipeMenuView.OnSwipeItemClickListener;


/**
 * 
 * @author OYC
 * @date 2015-03-18
 * 
 */

public class CustomSwipeMenuAdapter implements WrapperListAdapter,
		OnSwipeItemClickListener {

	private ListAdapter mAdapter;
	private Context mContext;
	private OnMenuItemClickListener onMenuItemClickListener;
	private float start, end;
	private boolean isHor;
	private int padding;

	public CustomSwipeMenuAdapter(Context context, ListAdapter adapter, float start, float end, boolean isHor, int padding) {
		mAdapter = adapter;
		mContext = context;
		this.start = start;
		this.end = end;
		this.isHor = isHor;
		this.padding = padding;
	}

	@Override
	public int getCount() {
		return mAdapter.getCount();
	}

	@Override
	public Object getItem(int position) {
		return mAdapter.getItem(position);
	}

	@Override
	public long getItemId(int position) {
		return mAdapter.getItemId(position);
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		CustomSwipeMenuLayout layout = null;
		if (convertView == null) {
			View contentView = mAdapter.getView(position, convertView, parent);
			CustomSwipeMenu menu = new CustomSwipeMenu(mContext);
			menu.setViewType(mAdapter.getItemViewType(position));
			createMenu(menu);
			CustomSwipeMenuView menuView = new CustomSwipeMenuView(menu,
					(CustomSwipeListView) parent, this.isHor, this.padding);
			menuView.setOnSwipeItemClickListener(this);
			CustomSwipeListView listView = (CustomSwipeListView) parent;
			layout = new CustomSwipeMenuLayout(contentView, menuView,
					listView.getCloseInterpolator(),
					listView.getOpenInterpolator(),
					start, end);
			layout.setPosition(position);
		} else {
			layout = (CustomSwipeMenuLayout) convertView;
			mAdapter.getView(position, layout.getContentView(), parent);
			layout.closeMenu();
			layout.setPosition(position);
		}
		
		return layout;
	}

	public void createMenu(CustomSwipeMenu menu) {
		// Test Code
		CustomSwipeMenuItem item = new CustomSwipeMenuItem(mContext);
		item.setTitle("Item 1");
		item.setBackground(new ColorDrawable(Color.GRAY));
		item.setWidth(300);
		menu.addMenuItem(item);

		item = new CustomSwipeMenuItem(mContext);
		item.setTitle("Item 2");
		item.setBackground(new ColorDrawable(Color.RED));
		item.setWidth(300);
		menu.addMenuItem(item);
	}

	@Override
	public void onItemClick(CustomSwipeMenuView view, CustomSwipeMenu menu, int index) {
		if (onMenuItemClickListener != null) {
			onMenuItemClickListener.onMenuItemClick(view.getPosition(), menu,
					index);
		}
	}

	public void setOnMenuItemClickListener(
			OnMenuItemClickListener onMenuItemClickListener) {
		this.onMenuItemClickListener = onMenuItemClickListener;
	}

	@Override
	public void registerDataSetObserver(DataSetObserver observer) {
		mAdapter.registerDataSetObserver(observer);
	}

	@Override
	public void unregisterDataSetObserver(DataSetObserver observer) {
		mAdapter.unregisterDataSetObserver(observer);
	}

	@Override
	public boolean areAllItemsEnabled() {
		return mAdapter.areAllItemsEnabled();
	}

	@Override
	public boolean isEnabled(int position) {
		return mAdapter.isEnabled(position);
	}

	@Override
	public boolean hasStableIds() {
		return mAdapter.hasStableIds();
	}

	@Override
	public int getItemViewType(int position) {
		return mAdapter.getItemViewType(position);
	}

	@Override
	public int getViewTypeCount() {
		return mAdapter.getViewTypeCount();
	}

	@Override
	public boolean isEmpty() {
		return mAdapter.isEmpty();
	}

	@Override
	public ListAdapter getWrappedAdapter() {
		return mAdapter;
	}

}
