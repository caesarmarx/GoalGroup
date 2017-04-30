package com.goalgroup.ui;

import java.util.ArrayList;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ClipData;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.os.Bundle;
import android.util.AttributeSet;
import android.util.Log;
import android.view.DragEvent;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
import com.goalgroup.task.GetClubMembersTask;
import com.goalgroup.task.SetClubMembersTask;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class ClubMembersActivity extends Activity implements XListView.IXListViewListener {
	int member_width;
	View member_view, drop_view;
	private MyClubData myData = new MyClubData();
	
	MemberView moving_memberView;
	ViewGroup orign_parent;
	ViewGroup init_parent;
	ViewGroup parentView;
	ViewParent parent;
	
	private boolean delflag = false;
	private static View dropPointView;
	
	boolean isReplaced = false;
	
	int orign_index;
	int temp_location = 2; //0:left, 1:right, 2:initial

	private static int ROUND_RADIUS = 10;
	
	public enum PlayerPos{
		none,
		forward,
		middle,
		back,
		keeper
	}
	public enum PlayerType{
		player,
		captain,
		manager
	}
	public enum Health{
		normal,
		injured
	}
	
	@SuppressLint("DrawAllocation")
	class MemberView extends RelativeLayout implements View.OnDragListener, View.OnLongClickListener, View.OnClickListener{
		
		private String playerId = "";
		
		
		public String getPlayerId() {
			return playerId;
		}
		
		public void setPlayerId(String id) {
			this.playerId = id;
		}
		

		public MemberView(Context context) {
			super(context);
		}
		
		public MemberView(Context context, AttributeSet attrs) {
			super(context, attrs);
		}
		
		@SuppressLint("DrawAllocation")
		@Override
		protected void onDraw(Canvas canvas) {			
			
			Paint workPaint = new Paint();
			workPaint.setColor(Color.WHITE);
			
			canvas.drawRoundRect(new RectF(0, 0, getWidth(), getHeight()), ROUND_RADIUS, ROUND_RADIUS, workPaint);									
		}

		@Override
		public boolean onDrag(View v, DragEvent event) {
			if (!myData.isOwner(clubId))
				return true;
			
			int action = event.getAction();
			
			switch(action) {
			case DragEvent.ACTION_DRAG_STARTED:

				Log.d("DRAG", "DRAG_STARTED");
				delflag = false;
				
				break;
			case DragEvent.ACTION_DRAG_ENTERED:
				
				Log.d("DRAG", "DRAG_ENTERED");
				
				parentView = (ViewGroup)v.getParent();
				
				break;
			
			case DragEvent.ACTION_DRAG_LOCATION:
				
				Log.d("DRAG", "DRAG_LOCATION");
				
				if (v == moving_memberView || temp_location != 2) break;
				
				float _pos_x = event.getX();
								
				/*try {
					((ViewGroup) moving_memberView.getParent()).removeView(moving_memberView);
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				*/
				dropPointView = v;
				dropPointView.setOnDragListener(null);
				
				if (_pos_x <= moving_memberView.getWidth() / 2 ) {
					temp_location = 0;
					try {
						((ViewGroup) moving_memberView.getParent()).removeView(moving_memberView);
					} catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					parentView.addView(moving_memberView, parentView.indexOfChild(v));
				} else {
					temp_location = 1;
					try {
						((ViewGroup) moving_memberView.getParent()).removeView(moving_memberView);
					} catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					parentView.addView(moving_memberView, parentView.indexOfChild(v) + 1);
				} 
				
				//isReplaced = true;
				//GgApplication.occupyFlag = true;
				/*try {
					Thread.sleep(200);
				} catch (InterruptedException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}*/
				
				break;
			
			case DragEvent.ACTION_DRAG_EXITED:
				Log.d("DRAG", "DRAG_EXITED");
				
				if (temp_location == 2) break;
				
				initialVariables();
				try {
					((ViewGroup) moving_memberView.getParent()).removeView(moving_memberView);
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
				orign_parent.addView(moving_memberView, orign_index);
				
				if (dropPointView != null) 
					dropPointView.setOnDragListener(new MemberView(ClubMembersActivity.this));
				
				break;
			
			case DragEvent.ACTION_DROP:
				
				Log.d("DRAG", "DRAG_DROP");
				
//				parent = v.getParent();
//				
//				if (parentView.getId() == delView.getId()) {
//
//					// owner can not delete
//					if (photo_captain.getTag().equals(moving_memberView.getTag()) || photo_manager.getTag().equals(moving_memberView.getTag())) {
//						initialVariables();
//						delView.setVisibility(View.INVISIBLE);
//						break;
//					}
//					
//					dialog = new AlertDialog.Builder(ClubMembersActivity.this)
//					.setTitle(R.string.player_delete_conf)
//					.setCancelable(false)
//					.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
//						
//						@Override
//						public void onClick(DialogInterface dialog, int item) {
//							
//							// empty manager if deleted
//							if (photo_manager.getTag().equals(moving_memberView.getTag())) {
//								manager_name.setText("");
//								imageLoader.displayImage("", photo_manager, GgApplication.img_opt_captain);
//								photo_manager.setTag("");
//							}
//							
//							delPlayerIds += moving_memberView.getPlayerId() + ",";
//							
//							getPlayers();
//							String delName = (String)moving_memberView.getTag();
//							for (int i = 0; i < players.length; i ++){
//								if (delName.equals(players[i])) {
//									member_arr.remove(i);
//									break;
//								}
//							}
//							delflag = true;
//							orign_parent.removeView(moving_memberView);
//						}
//					}).setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
//						
//						@Override
//						public void onClick(DialogInterface dialog, int item) {
//							delView.setVisibility(View.INVISIBLE);
//							initialVariables();
//						}
//					}).create();
//					
//					dialog.show();
//				} else {
//					delView.setVisibility(View.INVISIBLE);
//				}
//				
//				moving_memberView.setAlpha(1.0f);
////				initialVariables();
//				
//				if (dropPointView != null) 
//					dropPointView.setOnDragListener(new MemberView(ClubMembersActivity.this));
				
				break;
			case DragEvent.ACTION_DRAG_ENDED:
								
//				initialVariables();
				
//				if (dropPointView != null) 
//					dropPointView.setOnDragListener(new MemberView(ClubMembersActivity.this));
				
				if (parentView != null) {
					// DRAG_DROP
					ProcessDragDrop();				
					//
					
					if (parentView.getId() == delView.getId() && delflag == false){
						try {
							((ViewGroup) moving_memberView.getParent()).removeView(moving_memberView);
						} catch (Exception e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						orign_parent.addView(moving_memberView, orign_index);
						if (photo_captain.getTag().equals(moving_memberView.getTag())) {
							Toast.makeText(ClubMembersActivity.this, getString(R.string.str_owner_delete_warning), Toast.LENGTH_LONG).show();
						} else if(photo_manager.getTag().equals(moving_memberView.getTag())) {
							Toast.makeText(ClubMembersActivity.this, getString(R.string.str_manager_delete_warning), Toast.LENGTH_LONG).show();
						}
						parentView = null;
					}
				}
				
				Log.d("DRAG", "DRAG_ENDED");
				delView.setVisibility(View.INVISIBLE);
				moving_memberView.setAlpha(1.0f);
//				initialVariables();					
				placeVirtualPlayer();
				if (dropPointView != null) 
					dropPointView.setOnDragListener(new MemberView(ClubMembersActivity.this));
				break;
			default:
				
			}
			return true;			
		}

		public void ProcessDragDrop()
		{
			if (parentView.getId() == delView.getId()) {

				// owner can not delete
				if (photo_captain.getTag().equals(moving_memberView.getTag()) || photo_manager.getTag().equals(moving_memberView.getTag())) {
					initialVariables();
					delView.setVisibility(View.INVISIBLE);
					return;
				}
				
				dialog = new AlertDialog.Builder(ClubMembersActivity.this)
				.setTitle(R.string.player_delete_conf)
				.setCancelable(false)
				.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int item) {
						
						// empty manager if deleted
						if (photo_manager.getTag().equals(moving_memberView.getTag())) {
							manager_name.setText("");
							imageLoader.displayImage("", photo_manager, GgApplication.img_opt_captain);
							photo_manager.setTag("");
						}
						
						delPlayerIds += moving_memberView.getPlayerId() + ",";
						
						getPlayers();
						String delName = (String)moving_memberView.getTag();
						for (int i = 0; i < players.length; i ++){
							if (delName.equals(players[i])) {
								member_arr.remove(i);
								break;
							}
						}
						delflag = true;
						orign_parent.removeView(moving_memberView);
					}
				}).setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int item) {
						delView.setVisibility(View.INVISIBLE);
						initialVariables();
					}
				}).create();
				
				dialog.show();
			} else {
				delView.setVisibility(View.INVISIBLE);
			}
		}
		
		@Override
		public void onClick(View arg0) {
			
			if (!StringUtil.isEmpty(playerId)) {// 일반선수를 클릭한 경우
				Intent intent;
				intent = new Intent(ClubMembersActivity.this, ProfileActivity.class);
				intent.putExtra("user_id", Integer.parseInt(playerId));
				if (playerId.equals(GgApplication.getInstance().getUserId()))
					intent.putExtra("type", CommonConsts.EDIT_PROFILE);
				else 
					intent.putExtra("type", CommonConsts.SHOW_PROFILE);
				ClubMembersActivity.this.startActivity(intent);
			} 
		};
		
		@Override
		public boolean onLongClick(View v) {
			
			if (!myData.isOwner(clubId))
				return true;
			
			moving_memberView = this;
			orign_parent = (ViewGroup)this.getParent();
			orign_index = orign_parent.indexOfChild(this);
			
//			member_width = v.getWidth();
			ClipData dragData =	ClipData.newPlainText("DragData", (String)v.getTag());
//			layer_index = pos-1;
			drop_view = v;
			drop_view.setAlpha(0.3f);
			v.startDrag(dragData, new View.DragShadowBuilder(v),
					(Object)drop_view, 0);
			
			delView.setVisibility(View.VISIBLE);
			
			return true;			
		}	
	}
	
	class Member{		
		String photo_url;
		String name ="";
		String id ="";
		int health;
		int temp;
		int pos = 0;/*0->none, 1->f, 2->m, 3->b, 4->ke*/
		int type = 0;/*0->pl, 1-> cap, 2->mana*/
		ImageView photoView;
		ImageView healthView;
		TextView  nameTextView;
		Context mContext;
		View selfView;
		
		/**
		 * 선수가 가지고 있는 위치정보에서 제일 첫 위치를 얻는 함수
		 * 
		 * @return int형으로서  제일 첫 위치를 되돌될
		 * 
		 */
		int getLastPos() {
			int lastPos = 1;
			int[] playerPos = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024};
			for (int i = 0; i < playerPos.length; i ++) {
				if ((pos & playerPos[i]) != playerPos[i]) 
					continue;
				
				lastPos = playerPos[i];
				break;
			}
			
			return lastPos;
		}
		
		/**
		 * 선수들을 자기 위치에 배치하는 함수
		 * 
		 * @param index 선수번호. -1은 선수이동을 위해 림시적으로 만든 가상 선수임을 가리킴
		 * @param field 가상선수가 놓여야 할 위치 1:공격 2:중간 3:방어 4:문지기
		 */
		void setMemberViewOnProperField(int index, int field){
			
			LayoutInflater inflater = getLayoutInflater();
			View t = inflater.inflate(R.layout.club_member, null);
			MemberView memberView = new MemberView(ClubMembersActivity.this);
			
			memberView.addView(t);
			
			photoView = (ImageView)(memberView.getChildAt(0)).findViewById(temp == 1 ? R.id.member_photo_temp : R.id.member_photo);			
			healthView = (ImageView)(memberView.getChildAt(0)).findViewById(R.id.member_health);
			nameTextView = (TextView)(memberView.getChildAt(0)).findViewById(R.id.member_name);
			if (index != -1) {	// 선수(감독, 주장포함)인 경우
				if (type == 0x02 || type == 0x03) {
					// member is manager
					photoView = (ImageView)(memberView.getChildAt(0)).findViewById(R.id.member_photo_manager);
					photoView.setVisibility(View.VISIBLE);
					imageLoader.displayImage(photo_url, photo_manager, GgApplication.img_opt_photo);
					photo_manager.setTag(name);
					manager_name.setVisibility(View.VISIBLE);
					if (StringUtil.isEmpty(name))
						manager_name.setVisibility(View.GONE);
					manager_name.setText(name);
				}
				
				if (type == 0x04 || type == 0x01 || type == 0x03) {
					// member is caption or owner
					photoView = (ImageView)(memberView.getChildAt(0)).findViewById(R.id.member_photo_captain);
					photoView.setVisibility(View.VISIBLE);
					imageLoader.displayImage(photo_url, photo_captain, GgApplication.img_opt_photo);
					photo_captain.setTag(name);
					captain_name.setVisibility(View.VISIBLE);
					if (StringUtil.isEmpty(name))
						captain_name.setVisibility(View.GONE);
					captain_name.setText(name);
					
					prevCaptainId = id;
				}

				// place member
				imageLoader.displayImage(photo_url, photoView, GgApplication.img_opt_photo);
				if (health == 1)
					healthView.setVisibility(View.VISIBLE);
				
				if (temp == 1)
					photoView.setVisibility(View.VISIBLE);
				
				nameTextView.setText(name);	
				nameTextView.bringToFront();
			
				switch (getLastPos()) {
				case 1:
				case 2:
				case 4:
					forward_area.addView(memberView);				
					break;
				case 8:
				case 16:
				case 32:
				case 64:
					middle_area.addView(memberView);
					break;
				case 128:
				case 256:
				case 512:
					back_area.addView(memberView);
					break;
				case 1024:
					keeper_area.addView(memberView);
					break;
				default:
					break;			
				}
			} else {	// 가상선수인 경우
				nameTextView.setVisibility(View.INVISIBLE);
				index = 0;
				switch (field) {
				case 1:
					forward_area.addView(memberView);
					break;
				case 2:
					middle_area.addView(memberView);
					break;
				case 3:
					back_area.addView(memberView);
					break;
				case 4:
					keeper_area.addView(memberView);
					break;
				default:
					break;
				}
			}
			
			memberView.setPlayerId(id);
			memberView.setTag(name);
			memberView.invalidate();
			
			memberView.setOnLongClickListener(memberView);
			memberView.setOnDragListener(memberView);
			memberView.setOnClickListener(memberView);
			
			selfView = memberView;
		}
		
	}
	
	private RelativeLayout delView;
	private TextView tvTitle;
	private Button btnBack;
	private Button btnSave;
	private ImageView btnSaveImg;
	private TextView btnText;
	
	private LinearLayout middle_area;
	private LinearLayout forward_area;
	private LinearLayout back_area;
	private LinearLayout keeper_area;
	
	private ImageView photo_captain;
	private ImageView photo_manager;
	private TextView  captain_name;
	private TextView manager_name;
	private GgProgressDialog dlg;
	private AlertDialog dialog;
	private ArrayList<Member> member_arr;
	private ImageLoader imageLoader;

	int start_index, end_index, layer_index, first_index, second_index;
	boolean start_flag = false;

	private int clubId;
	private int selectedIdx, prevSelectedIdx;
	private String[] players = null;
	private String prevCaptainId = "";
	private String newCaptainId = "";
	
	private String playerIds = "";
	private String playerPos = "";
	private String delPlayerIds = "";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_club_members);

		delView = (RelativeLayout)findViewById(R.id.mem_delete_player);
		clubId = getIntent().getExtras().getInt(ChatConsts.CLUB_ID_TAG);

		forward_area = (LinearLayout)findViewById(R.id.ly_pos_forwards);
		middle_area = (LinearLayout)findViewById(R.id.ly_pos_midfield);
		back_area = (LinearLayout)findViewById(R.id.ly_pos_back);
		keeper_area = (LinearLayout)findViewById(R.id.ly_pos_keeper);
		
		photo_captain = (ImageView)findViewById(R.id.photo_captain);
		captain_name = (TextView)findViewById(R.id.name_captain);
		photo_manager = (ImageView)findViewById(R.id.photo_manager);
		manager_name = (TextView)findViewById(R.id.name_manager);
		
		photo_captain.setTag("");
		photo_captain.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				if (myData.isOwner(clubId))
					selectCaptionOrManager(true, (String)photo_captain.getTag());
			}
		});
		
		photo_manager.setTag("");
		photo_manager.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				if (myData.isOwner(clubId))
					selectCaptionOrManager(false, (String)photo_manager.getTag());
			}
		});
		
		imageLoader = GgApplication.getInstance().getImageLoader();
		
		member_arr = new ArrayList<ClubMembersActivity.Member>();
		
		startDownloadMemberInfo(true);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(myData.getNameFromID(clubId)+getString(R.string.club_members_title));
		
		btnSave = (Button)findViewById(R.id.btn_view_more);
		btnSaveImg = (ImageView)findViewById(R.id.top_img);
		
//		btnSave.setText(getString(R.string.save_status));
		btnSaveImg.setBackgroundResource(R.drawable.save_ico);
		btnSave.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				getMemebersPos();
				startSetMemberPosition(true);
			}
		});
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		btnText = (TextView) findViewById(R.id.common_action_text);
		
		if (myData.isOwner(clubId)){
			btnSave.setVisibility(View.VISIBLE);
			btnSaveImg.setVisibility(View.VISIBLE);
			btnText.setText(R.string.save_status);
		}
		performDelViewLayout();
	}
	
	/**
	 * 삭제단추의 레이아웃
	 */
	private void performDelViewLayout() {

		LayoutInflater inflater = getLayoutInflater();
		View t = inflater.inflate(R.layout.club_member, null);
		MemberView memberView = new MemberView(ClubMembersActivity.this);
		memberView.addView(t);
		
		ImageView photoView = (ImageView)(memberView.getChildAt(0)).findViewById(R.id.member_photo);
		photoView.setBackgroundResource(R.drawable.delete);
		
		TextView txtView = (TextView)(memberView.getChildAt(0)).findViewById(R.id.member_name);
		txtView.setVisibility(View.INVISIBLE);
		
		delView.addView(memberView);
		memberView.setGravity(Gravity.CENTER);
		memberView.setOnDragListener(memberView);
	}
	
	/**
	 * 보존단추를 눌렀을때 봉사기에 올려보낼 선수ID렬과 위치렬을 얻는 함수
	 */
	private void getMemebersPos() {
		MemberView member;
		
		playerPos = "";
		playerIds = "";
		
		for (int i = 0; i < forward_area.getChildCount(); i ++) {
			member = (MemberView)forward_area.getChildAt(i);
			if (StringUtil.isEmpty(member.getPlayerId()))
				continue;
			
			playerIds += member.getPlayerId() + ",";
			playerPos += "1,";
		}
				
		for (int i = 0; i < middle_area.getChildCount(); i ++) {
			member = (MemberView)middle_area.getChildAt(i);
			if (StringUtil.isEmpty(member.getPlayerId()))
				continue;
			
			playerIds += member.getPlayerId() + ",";
			playerPos += "8,";
		}
		
		for (int i = 0; i < back_area.getChildCount(); i ++) {
			member = (MemberView)back_area.getChildAt(i);
			if (StringUtil.isEmpty(member.getPlayerId()))
				continue;
			
			playerIds += member.getPlayerId() + ",";
			playerPos += "128,";
		}
		
		for (int i = 0; i < keeper_area.getChildCount(); i ++) {
			member = (MemberView)keeper_area.getChildAt(i);
			if (StringUtil.isEmpty(member.getPlayerId()))
				continue;
			
			playerIds += member.getPlayerId() + ",";
			playerPos += "1024,";
		}
		
		if (playerIds.length() > 1)
			playerIds = playerIds.substring(0,  playerIds.length() - 1);
		
		if (playerPos.length() > 1)
			playerPos = playerPos.substring(0,  playerPos.length() - 1);
		
		if (delPlayerIds.length() > 1)
			delPlayerIds = delPlayerIds.substring(0, delPlayerIds.length() - 1);
	}
	
	/**
	 * 가상선수들을 삭제하는 함수
	 * @param parentLView
	 * @return
	 */
	private void removeVirtualPlayer(LinearLayout parentLView) {
		
		if (parentLView.getChildCount() == 1)
			return;

		for (int i = 0; i < parentLView.getChildCount(); i ++) {
			MemberView tmpView = (MemberView)parentLView.getChildAt(i);
			if (!tmpView.getPlayerId().equals(""))
				continue;
			
			parentLView.removeView(tmpView);
			break;
		}
	}
	
	
	/**
	 * 한명의 선수도 배치되지 않은 지역에 가상선수를 배치하는 함수
	 */
	private void placeVirtualPlayer() {
		if (forward_area.getChildCount() == 0) {
			Member member = new Member();
			member.setMemberViewOnProperField(-1, 1);
		} else {
			removeVirtualPlayer(forward_area);
		}
		
		if (middle_area.getChildCount() == 0) {
			Member member = new Member();
			member.setMemberViewOnProperField(-1, 2);
		} else {
			removeVirtualPlayer(middle_area);
		}
		
		if (back_area.getChildCount() == 0) {
			Member member = new Member();
			member.setMemberViewOnProperField(-1, 3);
		} else {
			removeVirtualPlayer(back_area);
		}
		
		if (keeper_area.getChildCount() == 0) {
			Member member = new Member();
			member.setMemberViewOnProperField(-1, 4);
		} else {
			removeVirtualPlayer(keeper_area);
		}
		
	}
	
	public void stopDownloadMemberInfo(String datas, boolean more) {
		forward_area.removeAllViewsInLayout();
		middle_area.removeAllViewsInLayout();
		keeper_area.removeAllViewsInLayout();
		back_area.removeAllViewsInLayout();
		member_arr.clear();
		try{
			
            String[] json_message = JSONUtil.getArrays(datas, "result");
			for (int i = 0; i < json_message.length; i++) {
				Member mem = new Member();
				
				mem.id = JSONUtil.getValue(json_message[i], "user_id");
				mem.name = JSONUtil.getValue(json_message[i], "user_name");
				mem.photo_url = JSONUtil.getValue(json_message[i], "user_icon");
				mem.health = JSONUtil.getValueInt(json_message[i], "health");
				mem.pos = JSONUtil.getValueInt(json_message[i], "position");
				mem.type = JSONUtil.getValueInt(json_message[i], "user_type");
				mem.temp = JSONUtil.getValueInt(json_message[i], "user_temp");
				
				member_arr.add(mem);
			}
			
			for(int i = 0;i<member_arr.size();i++) {
				Member member = member_arr.get(i);
				member.setMemberViewOnProperField(i, -1);
			}
			
			placeVirtualPlayer();
        }
        catch(Exception e1){
        	e1.printStackTrace();
        }
		
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
	}
	
	public void startDownloadMemberInfo(boolean showdlg){
		
		if (!NetworkUtil.isNetworkAvailable(ClubMembersActivity.this))
			return;
		
		if(showdlg) {
			dlg = new GgProgressDialog(ClubMembersActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetClubMembersTask task = new GetClubMembersTask(ClubMembersActivity.this, clubId);
		task.execute();
	}
	
	public void startSetMemberPosition(boolean showdlg){
		
		if (!NetworkUtil.isNetworkAvailable(ClubMembersActivity.this))
			return;
		
		if(showdlg) {
			dlg = new GgProgressDialog(ClubMembersActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		String managerId = "0";
		newCaptainId = "";
		for (int i = 0; i < member_arr.size(); i ++) {
			if (member_arr.get(i).name.equals(photo_manager.getTag()))
				managerId = member_arr.get(i).id;
			if (member_arr.get(i).name.equals(photo_captain.getTag()))
				newCaptainId = member_arr.get(i).id;
		}
		
		SetClubMembersTask task = new SetClubMembersTask(ClubMembersActivity.this, 
									clubId, 
									managerId, 
									newCaptainId,
									playerIds, 
									playerPos,
									delPlayerIds);
		delPlayerIds = "";
		task.execute();
	}
	
	public void stopSetMemberPosition(boolean succed) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (succed) {
			Toast.makeText(this, getString(R.string.register_success), Toast.LENGTH_LONG).show();
			
			if (!StringUtil.isEmpty(prevCaptainId) && !prevCaptainId.equals(newCaptainId)) {
				GgApplication.getInstance().changeClubPost(Integer.toString(clubId));
				prevCaptainId = newCaptainId;
			}
			startDownloadMemberInfo(true);
			if (!myData.isOwner(clubId))
				GgApplication.getInstance().getChatInfo().removeChatRooms(clubId);
		}
		else
			Toast.makeText(this, getString(R.string.register_failed), Toast.LENGTH_LONG).show();
	}

	@Override
	public void onRefresh(int id) {
	}

	@Override
	public void onLoadMore(int id) {		
	}
	
	public void initialVariables(){
		temp_location = 2;
		((ViewGroup) moving_memberView.getParent()).removeView(moving_memberView);
		orign_parent.addView(moving_memberView, orign_index);
	}

	/**
	 * 선수들의 ID를 얻는 함수
	 */
	private void getPlayers() {
		
		players = new String[member_arr.size()];
		for (int i = 0; i < member_arr.size(); i ++) {
			players[i] = member_arr.get(i).name;
		}
	}
	
	/**
	 * 해당 위치에서 ID에 대응하는 성원을 삭제하는 함수
	 * @param parentLView 전방, 중간, 후방, 문지기위치중 어느 하나를 가리킴
	 * @param id 삭제하려는 성원의 ID
	 * @return true:삭제성공, false:성원이 해당 위치에 존재 안함
	 */
	private boolean retrieveMemberView(LinearLayout parentLView, String id) {
		
		boolean retVal = false;
		
		for (int i = 0; i < parentLView.getChildCount(); i ++) {
			MemberView tmpView = (MemberView)parentLView.getChildAt(i);
			if (!tmpView.getPlayerId().equals(id))
				continue;
			
			retVal = true;
			break;
		}
		
		return retVal;
	}
	
	/**
	 * 주장 혹은 감독이 선택된 경우 전 주장 혹은 감독을 선수로, 선택된 선수를 주장 혹은 감독위치에 배비하는 함수
	 * @param isCaptain
	 */
	private void replacePlayer(boolean isCaptain) {
		boolean ret = false;
		Member member = member_arr.get(selectedIdx);
		
		if (isCaptain) {
//			if (photo_manager.getTag().equals(member.name)) {
//				manager_name.setText("");
//				imageLoader.displayImage("", photo_manager, GgApplication.img_opt_captain);
//				photo_manager.setTag("");
//			}
			member.type = 1;
		} else {
//			if (photo_captain.getTag().equals(member.name)) {
//				captain_name.setText("");
//				imageLoader.displayImage("", photo_captain, GgApplication.img_opt_captain);
//				photo_captain.setTag("");
//			}
			member.type = 2;
		}
		
		if (prevSelectedIdx != -1) {
			
			member = member_arr.get(prevSelectedIdx);
			member.type = 8;
			
			ret = retrieveMemberView(forward_area, member.id);
			if (!ret)
				ret = retrieveMemberView(middle_area, member.id);
			if (!ret)
				ret = retrieveMemberView(back_area, member.id);
			if (!ret)
				ret = retrieveMemberView(keeper_area, member.id);
			if (!ret)
				member.setMemberViewOnProperField(prevSelectedIdx, -1);
		}
		
		placeVirtualPlayer();
	}
	
	private boolean isCaptainSelectd = false;
	private String prevCaptainName = "";
	
	private void confirmCaptainOrManager() {
		getPlayers();
		
		prevSelectedIdx = -1;
		selectedIdx = 0;
		
		for (int i = 0; i < players.length; i ++) {
			if (!players[i].equals(prevCaptainName))
				continue;
			
			prevSelectedIdx = selectedIdx = i;
			break;
		}
		
		dialog = new AlertDialog.Builder(this)
		.setTitle(isCaptainSelectd ? R.string.select_caption : R.string.select_manager)
		.setCancelable(true)
		.setSingleChoiceItems(players, selectedIdx, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int item) {
				selectedIdx = item;								
			}
		}).setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int item) {
				
				if (selectedIdx == prevSelectedIdx)
					return;
				
				String logId = GgApplication.getInstance().getUserId();
				
				/*if (!isCaptainSelectd) {
					if (myData.isOwner(clubId) && member_arr.get(selectedIdx).id.equals(logId)) {
						Toast.makeText(ClubMembersActivity.this, getString(R.string.str_owner_selected), Toast.LENGTH_LONG).show();
						return;
					}
				}*/
				
				replacePlayer(isCaptainSelectd);
				
				imageLoader.displayImage(member_arr.get(selectedIdx).photo_url, isCaptainSelectd ? photo_captain : photo_manager, GgApplication.img_opt_photo);
			
				if (isCaptainSelectd) {
					if (StringUtil.isEmpty(member_arr.get(selectedIdx).name))
						captain_name.setVisibility(View.INVISIBLE);
					else 
						captain_name.setVisibility(View.VISIBLE);
					captain_name.setText(member_arr.get(selectedIdx).name);
					photo_captain.setTag(member_arr.get(selectedIdx).name);
				} else {
					if (StringUtil.isEmpty(member_arr.get(selectedIdx).name))
						manager_name.setVisibility(View.INVISIBLE);
					else
						manager_name.setVisibility(View.VISIBLE);
					manager_name.setText(member_arr.get(selectedIdx).name);
					photo_manager.setTag(member_arr.get(selectedIdx).name);
				}
			}
		}).create();
		
		dialog.show();
	}
	
	/**
	 * 감독이나 주장을 선택하였을때의 처리를 진행하는 함수
	 * 
	 * @param isCaption true:주장, false:감독
	 * @param name 이름
	 */
	public void selectCaptionOrManager(final boolean isCaption, String name) {
		isCaptainSelectd = isCaption;
		prevCaptainName = name;
		
		if (!isCaption) {
			confirmCaptainOrManager();
			return;
		}
		
		dialog = new AlertDialog.Builder(ClubMembersActivity.this)
		.setTitle(R.string.owner_change_conf)
		.setCancelable(true)
		.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int item) {
				confirmCaptainOrManager();
			}
		}).setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int item) {
			}
		}).create();
		
		dialog.show();
	}
}
