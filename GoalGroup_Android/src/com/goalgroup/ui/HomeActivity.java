package com.goalgroup.ui;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Rect;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.Menu;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.component.ChatEngine;
import com.goalgroup.chat.info.room.ChatRoomInfo;
import com.goalgroup.common.GgBroadCast;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.constants.ExtraConst;
import com.goalgroup.http.RunTimeDetailHttp;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.offline.GetOfflineService;
import com.goalgroup.ui.fragment.BBSFragment;
import com.goalgroup.ui.fragment.BaseFragment;
import com.goalgroup.ui.fragment.ChallengeFragment;
import com.goalgroup.ui.fragment.ClubFragment;
import com.goalgroup.ui.fragment.SearchFragment;
import com.goalgroup.utils.NetworkUtil;

import cn.jpush.android.api.JPushInterface;

public class HomeActivity extends FragmentActivity {
	
	View menuView;
	SectionsPagerAdapter mSectionsPagerAdapter;
	ViewPager mViewPager;
	private int sel_tab = -1;
	
	private final int TAB_NUM = 4;
	private int[] area_normal_views = {
			R.id.area_challenge, R.id.area_bbs, R.id.area_club, R.id.area_search
		};
		
	private int[] bottom_tv_ids = {
		R.id.bottom_tv_challenge, R.id.bottom_tv_bbs, R.id.bottom_tv_club, R.id.bottom_tv_search
	};
	
	private int[] icon_ids = {
		R.id.tab_01_challenge, R.id.tab_02_bbs, R.id.tab_03_club, R.id.tab_04_search
	};
	
	private int[] icon_normal_drawables = {
		R.drawable.tab_01_challenge_normal, R.drawable.tab_02_bbs_normal, R.drawable.tab_03_club_normal, R.drawable.tab_04_search_normal
	};
	
	private int[] icon_select_drawables = {
		R.drawable.tab_01_challenge_select, R.drawable.tab_02_bbs_select, R.drawable.tab_03_club_select, R.drawable.tab_04_search_select
	};
	
	private ImageView[] imgTabIcons = new ImageView[TAB_NUM];
	private View[] areaTabBgs = new View[TAB_NUM];
	private TextView[] tvTabs = new TextView[TAB_NUM];
	
	private BaseFragment[] fragments = new BaseFragment[4];
	private int tabindex;
	
	public Handler loaderHandler = new Handler();
	public Runnable runtimeDetailLoader = new Runnable() {
		
		@Override
		public void run() {
			// TODO Auto-generated method stub
			if (!NetworkUtil.isNetworkAvailable(HomeActivity.this))
				return;
			
			// reconnect ChatServer
			ChatEngine chatEngine = GgApplication.getInstance().getChatEngine();
			if (!chatEngine.onConnectState()){
				chatEngine.disconnect();
				chatEngine.createSocketIOManager();
				chatEngine.netConnect();
			}
						
			RunTimeDetailTask runDetailTask = new RunTimeDetailTask();
			
			String[] clubs= GgApplication.getInstance().getClubId();
			String clubIds = "";
			
			if (clubs != null) {
				for (int i = 0;i < clubs.length; i++) {
					if (clubIds.equals("")) {
						clubIds = clubs[i];
					}
					else {
						clubIds = clubIds + "," + clubs[i];
					}
				}
			}
			runDetailTask.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, GgApplication.getInstance().getUserId(), clubIds);
		}
	};
	
	private class RunTimeDetailTask extends AsyncTask<String, String, String> {
		
		private RunTimeDetailHttp post;
		
		@Override
		protected void onPreExecute() {
			super.onPreExecute();
		}
		
		@Override
		protected String doInBackground(String... params) {
			post = new RunTimeDetailHttp();
			post.setParams(params);
			post.run();
			return null;
		}
		
		@Override
		protected void onPostExecute(String result) {
			super.onPostExecute(result);
			reloadRunTimeDetail();
			updateDetail();
		}
	}
	
	public void reloadRunTimeDetail() {
//		Log.v("HomeActivity", "reload");
		loaderHandler.postDelayed(runtimeDetailLoader, 5000);
	}
	
	public void stopRunTimeDetail(){
		loaderHandler.removeCallbacks(runtimeDetailLoader);
	}
	
	public void updateDetail() {
		int nCurSel = mViewPager.getCurrentItem();
		
		switch (nCurSel) {
		case 0:
			ChallengeFragment challengeFragment = (ChallengeFragment) (fragments[nCurSel]);
			challengeFragment.onRunTimeRefresh();
			break;
		case 1:
			BBSFragment bbsFragment = (BBSFragment) (fragments[nCurSel]);
			bbsFragment.onRunTimeRefresh();
			break;
		case 2:
			ClubFragment clubFragment = (ClubFragment) (fragments[nCurSel]);
			clubFragment.onRunTimeRefresh();
			break;
		case 3:
			SearchFragment searchFragment = (SearchFragment) (fragments[nCurSel]);
			searchFragment.onRunTimeRefresh();
			break;
		default:
			break;
		}
	}
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_home);
		startService(new Intent(getBaseContext(), GetOfflineService.class));
		
		mSectionsPagerAdapter = new SectionsPagerAdapter(getSupportFragmentManager());

        // Set up the ViewPager with the sections adapter.
        mViewPager = (ViewPager) findViewById(R.id.pager);
        mViewPager.setAdapter(mSectionsPagerAdapter);
        mViewPager.setOnPageChangeListener(new ViewPager.SimpleOnPageChangeListener() {
            @Override
            public void onPageSelected(int position) {
                tabSelected(position);
            }
        });
        
        initMenu();
        
        if (getIntent() != null && getIntent().getExtras() != null) {
        	int roomTypeFromNotification = getIntent().getExtras().getInt(CommonConsts.NOTIFY_TYPE);
        	boolean userRegist = getIntent().getExtras().getBoolean("userRegist");
        	if (userRegist){
        		tabSelected(0);
        		Intent intent = new Intent(HomeActivity.this, ProfileActivity.class);
        		intent.putExtra("user_id", Integer.valueOf(GgApplication.getInstance().getUserId()));
    			intent.putExtra("type", CommonConsts.EDIT_PROFILE);
    			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    			startActivity(intent);
    			return;
        	}
        	if (roomTypeFromNotification == -1) {
        		tabSelected(0);
        	} else if (roomTypeFromNotification == ChatConsts.CHAT_ROOM_MEETING) {
        		GgApplication.getInstance().getChatEngine().hideNotification();
        		tabSelected(2);
        	} else if (roomTypeFromNotification == 2) {
        		tabSelected(0);
        	}
        	else {
        		String msg = getIntent().getExtras().getString(CommonConsts.NOTIFY_CONTENT);
        		GgApplication.getInstance().getChatEngine().hideNotification();
        		tabSelected(0);
        		Intent intent = new Intent(HomeActivity.this, NewsAlarmActivity.class);
    			startActivity(intent);
        	}
        } else {
        	tabSelected(0);
        }
        
        GgApplication GgApp = (GgApplication)getApplication();
        GgApp.homeActivity = this;
        
        loaderHandler.post(runtimeDetailLoader);
        
        int flag = (savedInstanceState == null) ? -1 : savedInstanceState.getInt("FLAG");
        
        if (ExtraConst.DISMISS_CLUB_REQUEST == flag || ExtraConst.ACCEPT_INVITE_REQUEST == flag) {
        	tabSelected(2);
        } else if (ExtraConst.DELETE_CHALLEANGE_REQUEST == flag) {	
        	tabSelected(0);
        }
	}
	
	private void tabSelected(int position) {
		if (sel_tab == position )
			return;
		sel_tab = position;
	
		for (int i = 0; i < TAB_NUM; i++) {
			tvTabs[i].setTextColor(i == position ? getResources().getColor(R.color.pattern_green) : 0xff787878);			
			imgTabIcons[i].setImageResource(i != position ? icon_normal_drawables[i] : icon_select_drawables[i]);
		}
		
		mViewPager.setCurrentItem(position);
	}
	
	private void initMenu() {
		for (tabindex = 0; tabindex < TAB_NUM; tabindex++) {
			imgTabIcons[tabindex] = (ImageView)findViewById(icon_ids[tabindex]);
			tvTabs[tabindex] = (TextView)findViewById(bottom_tv_ids[tabindex]);
			
			areaTabBgs[tabindex] = (View)findViewById(area_normal_views[tabindex]);
			
			areaTabBgs[tabindex].setOnClickListener(new View.OnClickListener() {				
				@Override
				public void onClick(View v) {
					for (int i = 0; i < TAB_NUM; i++) {
						if (area_normal_views[i] == v.getId()) {
							mViewPager.setCurrentItem(i);
							break;
						}
					}
				}
			});
		}
	}
	
	@Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
	
	public class SectionsPagerAdapter extends FragmentPagerAdapter {

        public SectionsPagerAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public Fragment getItem(int position) {

//        	Log.v("HomeActivity", "fragment");
        	Fragment fragment = null;
            
            switch (position) {
            case 0:
            	fragments[0] = new ChallengeFragment();
            	fragment = fragments[0];
            	break;
            case 1:
            	fragments[1] = new BBSFragment();
            	fragment = fragments[1];
            	break;
            case 2:
            	fragments[2] = new ClubFragment();
            	fragment = fragments[2];
            	break;
            case 3:
            	fragments[3] = new SearchFragment();
            	fragment = fragments[3];
            	break;
            default:
            	break;
            }
            return fragment;
        }

        @Override
        public int getCount() {
            // Show 4 total pages.
//        	Log.v("HomeActivity", "fragment" + 4);
            return 4;
        }
    }
	
	@Override
	public void onStart() {
		super.onStart();
		IntentFilter filter = new IntentFilter();
		filter.addAction(GgBroadCast.GOAL_GROUP_BROADCAST);
		registerReceiver(broadCastReceiver, filter);
		JPushInterface.resumePush(getApplicationContext());
	}
	
	@Override
	public void onDestroy() {
		super.onDestroy();
		GgApplication.getInstance().getChatEngine().hideNotification();
		unregisterReceiver(broadCastReceiver);
		Log.d("onDestroy", "homeactivity");
		//JPushInterface.stopPush(getApplicationContext());
	}

	@Override
	public  void onStop() {
		super.onStop();
		if (isFinishing()) {
			Log.d("onStop", "Finishing...");
			JPushInterface.clearAllNotifications(getApplicationContext());
			JPushInterface.stopPush(getApplicationContext());
		}
	}

	@Override
	public void onLowMemory() {
		super.onLowMemory();
		//JPushInterface.stopPush(getApplicationContext());
		Log.d("onLowMemory", "unknown");
	}

	@Override
	public void onTrimMemory(int level) {
		super.onTrimMemory(level);
		//if (level < 20)
		//	JPushInterface.stopPush(getApplicationContext());
		Log.d("onTrimMemory", Integer.toString(level));
	}

	@Override
	public void onPause() {
		super.onPause();
		Log.d("onPause", "homeactivity");
		//JPushInterface.onPause(getApplicationContext());
	}
	@Override
	public void onResume() {
		super.onResume();
		//JPushInterface.onResume(getApplicationContext());
		try {
			LinearLayout popupMenu = (LinearLayout) fragments[mViewPager.getCurrentItem()].getPoupMenu();
			popupMenu.setVisibility(View.GONE);
		} catch (Exception e) {
			// TODO: handle exception
			return;
		}
			
		
	}
	@Override
	public boolean dispatchTouchEvent(MotionEvent ev) {
		
		//Log.v("??", "??");
		//Log.v("?????", Integer.toString(mViewPager.getCurrentItem()));
		
		LinearLayout popupMenu = (LinearLayout) fragments[mViewPager.getCurrentItem()].getPoupMenu();
		
		Rect rect = new Rect();
		popupMenu.getGlobalVisibleRect(rect);
		
		if (popupMenu != null && popupMenu.getVisibility() == View.VISIBLE && (ev.getX() < rect.left || (rect.top + rect.height()) < ev.getY())) {
			popupMenu.setVisibility(View.GONE);	
			if (ev.getY() < 800)		
				return true;
		}	
		
		return super.dispatchTouchEvent(ev);
	}
	private BroadcastReceiver broadCastReceiver = new BroadcastReceiver() {

		@Override
		public void onReceive(Context context, Intent intent) {
			int msg = intent.getExtras().getInt("Message");
			if (msg != GgBroadCast.MSG_UNREAD_MESSAGE)
				return;
			
			updateDetail();
		}
	};	
}
