package com.goalgroup.task;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.EditUserProfileHttp;
import com.goalgroup.ui.ProfileActivity;

import android.os.AsyncTask;

public class EditUserProfileTask extends AsyncTask<Void, Void, Void> {
	private ProfileActivity parent;
	private EditUserProfileHttp post;
	
	String mOldNick;
	String mNewNick;
	String mPhoto_URL;
	int mSex;
	String mBirthDay;
	int mHeight;
	int mWeight;
	int mTerm;
	int mCity;
	int mPosition;
	String mActivityArea;
	int mActivityTime;
	
	
	public EditUserProfileTask(ProfileActivity parent, String old_nickName, String new_nickName, String photo_url, 
			int sex, String birthday, int height, int weight, int term, int city, int position, String act_area, int act_time ) {
		this.parent = parent;
		mOldNick = old_nickName;
		mNewNick = new_nickName;
		mPhoto_URL = photo_url;
		mSex = sex;
		mBirthDay = birthday;
		mHeight = height;
		mWeight = weight;
		mTerm = term;
		mCity = city;
		mPosition = position;
		mActivityArea = act_area;
		mActivityTime = act_time;
	}
	
	protected void onPreExecute() {
		super.onPreExecute();
	}

	@Override
	protected Void doInBackground(Void... arg0) {
		post = new EditUserProfileHttp();
		post.setParams(mOldNick, mNewNick, mPhoto_URL, String.valueOf(mSex), mBirthDay, String.valueOf(mHeight), String.valueOf(mWeight), String.valueOf(mTerm), 
				String.valueOf(mCity), String.valueOf(mPosition), mActivityArea, String.valueOf(mActivityTime));
		post.run();
		return null;
	}

	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int data_result = 0;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopRegisterProfile(data_result);
	}
}
