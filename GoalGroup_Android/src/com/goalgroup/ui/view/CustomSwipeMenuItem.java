package com.goalgroup.ui.view;


import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.Gravity;

/**
 * 
 * @author OYC
 * @date 2015-03-18
 * 
 */
public class CustomSwipeMenuItem {

	private int id;
	private Context mContext;
	private String title;
	private Drawable icon;
	private Drawable background;
	private int titleColor;
	private int titleSize;
	private int width;
	private int height;
	private int x;
	private int y;
	private int graivty = Gravity.CENTER;

	public CustomSwipeMenuItem(Context context) {
		mContext = context;
	}
	
	public int getGravity() {
		return graivty;
	}
	
	public void setGravity(int value) {
		this.graivty = value;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getTitleColor() {
		return titleColor;
	}

	public int getTitleSize() {
		return titleSize;
	}

	public void setTitleSize(int titleSize) {
		this.titleSize = titleSize;
	}

	public void setTitleColor(int titleColor) {
		this.titleColor = titleColor;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public void setTitle(int resId) {
		setTitle(mContext.getString(resId));
	}

	public Drawable getIcon() {
		return icon;
	}

	public void setIcon(Drawable icon) {
		this.icon = icon;
	}

	public void setIcon(int resId) {
		this.icon = mContext.getResources().getDrawable(resId);
	}

	public Drawable getBackground() {
		return background;
	}

	public void setBackground(Drawable background) {
		this.background = background;
	}

	public void setBackground(int resId) {
		this.background = mContext.getResources().getDrawable(resId);
	}

	public int getWidth() {
		return width;
	}

	public void setWidth(int width) {
		this.width = width;
	}
	
	public int getHeight() {
		return height;
	}

	public void setHeight(int height) {
		this.height = height;
	}
	
	public int getX() {
		return x;
	}

	public void setX(int x) {
		this.x = x;
	}
	
	public int getY() {
		return y;
	}

	public void setY(int y) {
		this.y = y;
	}
}
