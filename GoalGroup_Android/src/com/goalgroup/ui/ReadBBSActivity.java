package com.goalgroup.ui;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Paint;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.model.BbsReplyItem;
import com.goalgroup.task.AnswerBbsTask;
import com.goalgroup.task.GetBbsDetailTask;
import com.goalgroup.ui.adapter.BbsReplyAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.GgListView;
import com.goalgroup.ui.view.XListView;
import com.goalgroup.ui.view.xEditText;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class ReadBBSActivity extends Activity implements XListView.IXListViewListener {
	private final int DIRECT_MODE = 0;
	private final int ANSWER_MODE = 1;
	
	private TextView tvTitle;
	private Button btnBack;
	
	private TextView userName;
	private TextView dateTime;
	private ImageLoader imgLoader;
	private ImageView userPhoto;
	
	private xEditText et_chatStr;
	private Button btnSend;
	
	private int bbs_id;
	private int req_bbs_id;
	private int index;
	private String user_name;
	private int type;
	
	private LinearLayout bbs_content_area;
	private RelativeLayout total_area;
	
	private boolean firstUpdate;
	
	private GgListView replyListView;
	private BbsReplyAdapter adapter;
	private GgProgressDialog dlg;
	
	private Integer[] emoImageIDs = {
			R.drawable.emoticon1,R.drawable.emoticon2,R.drawable.emoticon3,R.drawable.emoticon4,
			R.drawable.emoticon5,R.drawable.emoticon6,R.drawable.emoticon7,R.drawable.emoticon8,
			R.drawable.emoticon9,R.drawable.emoticon10,R.drawable.emoticon11,R.drawable.emoticon12,
			R.drawable.emoticon13,R.drawable.emoticon14,R.drawable.emoticon15,R.drawable.emoticon16,
			R.drawable.emoticon17,R.drawable.emoticon18,R.drawable.emoticon19,R.drawable.emoticon20,
			R.drawable.emoticon21,R.drawable.emoticon22,R.drawable.emoticon23,R.drawable.emoticon24,
		};
	
	private LinearLayout emotePanel = null;
	private GridView emoticon_grid1 = null;
	private GridView emoticon_grid2 = null;
	public ArrayList<EmoticonItem> emoticonList1;
	public ArrayList<EmoticonItem> emoticonList2;
	private Button btn_left_emoticon = null;
	private Button btn_right_emoticon = null;
	private ImageButton btnShowEmoticon;
	private Button btn_delEmoticon=null;
	
	public ListView emoticonListView;
	public ArrayList<EmoticonItem> emoticonList;
	public int emoticon_position = 1000; 

    int screenWidth = 0;  //화면넓이
    int count = 0;  
    float textTotalWidth = 0.0f;  
    float textWidth = 0.0f;  
    
    Paint paint = new Paint();
    
    private ArrayList<View> mHeaderViews = new ArrayList<View>();
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_read_bbs);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.read_bbs));
		
		emotePanel = (LinearLayout) findViewById(R.id.emoticon_panel);
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				setResult(RESULT_OK, getIntent());
				finish();
			}
		});
		
		bbs_id = getIntent().getExtras().getInt("bbs_id");
		
		userName = (TextView)findViewById(R.id.bbs_user);
		dateTime = (TextView)findViewById(R.id.bbs_date);
		userPhoto = (ImageView)findViewById(R.id.bbs_user_photo);
		
		req_bbs_id = getIntent().getExtras().getInt("bbs_id");
		
		type = DIRECT_MODE;
		
		imgLoader = GgApplication.getInstance().getImageLoader();
		et_chatStr = (xEditText)findViewById(R.id.edit_chat_content);
		
		et_chatStr.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				InputMethodManager inputMethodManager = (InputMethodManager)getSystemService(INPUT_METHOD_SERVICE);
				if (inputMethodManager.isActive()){
					emotePanel.setVisibility(View.GONE);
				}
			}
		});
		
		btn_left_emoticon = (Button) findViewById(R.id.back_emoticon);
//		btn_left_emoticon.setVisibility(View.INVISIBLE);
		btn_right_emoticon = (Button) findViewById(R.id.fore_emoticon);
//		btn_right_emoticon.setVisibility(View.VISIBLE);
		emoticon_grid1 = (GridView) findViewById(R.id.emoticon_grid1);
		emoticon_grid2 = (GridView) findViewById(R.id.emoticon_grid2);
		emoticonList1 = new ArrayList<EmoticonItem>();
		emoticonList2 = new ArrayList<EmoticonItem>();
		
		loadEmoticon();
		
		EmoticonAdapter emoticonAdapter1 = new EmoticonAdapter(this, 1);
		EmoticonAdapter emoticonAdapter2 = new EmoticonAdapter(this, 2);
		emoticon_grid1.setAdapter(emoticonAdapter1);
		emoticon_grid1.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// dialog.dismiss();
				et_chatStr.insertDrawable(emoImageIDs[position], 30, 30);
			}
		});
		
		emoticon_grid2.setAdapter(emoticonAdapter2);
		emoticon_grid2.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// dialog.dismiss();
				et_chatStr.insertDrawable(emoImageIDs[28+position], 30, 30);
			}
		});
		
		btnSend = (Button)findViewById(R.id.btn_send_answer);
		
		btnSend.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				if (StringUtil.isEmpty(et_chatStr.getText().toString()))
					return;
				
				Object[] param = new Object[4];
				param[0] = GgApplication.getInstance().getUserId();
				param[1] = et_chatStr.getText().toString();
				param[2] = req_bbs_id;
				param[3] = type;
				
				startAnswerBbs(true, param);
			}
		});
		btn_left_emoticon.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				emoticon_grid1.setVisibility(View.VISIBLE);
				emoticon_grid2.setVisibility(View.GONE);
//				btn_right_emoticon.setVisibility(View.VISIBLE);
//				btn_left_emoticon.setVisibility(View.INVISIBLE);
			}
		});
		btn_right_emoticon.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				emoticon_grid1.setVisibility(View.GONE);
				emoticon_grid2.setVisibility(View.VISIBLE);
//				btn_right_emoticon.setVisibility(View.INVISIBLE);
//				btn_left_emoticon.setVisibility(View.VISIBLE);
			}
		});
		btn_delEmoticon=(Button)findViewById(R.id.delete_btn);
		btn_delEmoticon.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				et_chatStr.removeLastCharacter();
			}
		});
		btnShowEmoticon = (ImageButton) findViewById(R.id.btn_emoticon);
		btnShowEmoticon.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				toggleEconAndFunc();
			}
		});
		
		adapter = new BbsReplyAdapter(ReadBBSActivity.this);
		
		replyListView = (GgListView)findViewById(R.id.reply_listview);
		replyListView.setAdapter(adapter);
		replyListView.setPullLoadEnable(true);
		replyListView.setPullRefreshEnable(false);
		replyListView.setXListViewListener(this, 0);
		//replyListView.bannerView = bbs_content_area;
		
		firstUpdate = true;
	}
	
	private void toggleEconAndFunc() {
		if (!emotePanel.isShown()) {
			InputMethodManager inputMethodManager = (InputMethodManager)getSystemService(INPUT_METHOD_SERVICE);
			inputMethodManager.hideSoftInputFromWindow(et_chatStr.getWindowToken(), 0);
			emotePanel.setVisibility(View.VISIBLE);
		} else {
			emotePanel.setVisibility(View.GONE);
		}
	}
	
	public class EmoticonItem {

		public int resourceId;

		public EmoticonItem(int resourceId) {
			this.resourceId = resourceId;
		}

		public int getResources() {
			return this.resourceId;
		}

		public void setResources(int resourceId) {
			this.resourceId = resourceId;
		}

	}
	
	public class EmoticonAdapter extends BaseAdapter {

		private LayoutInflater mInflater;
		private int emoticon_type;

		class ViewHolder {
			ImageView icon;
		}

		public EmoticonAdapter(Context context, int type) {
			mInflater = LayoutInflater.from(context);
			emoticon_type=type;
		}

		@Override
		public int getCount() {
			// TODO Auto-generated method stub
			if (this.emoticon_type == 1) {
				return emoticonList1.size();
			} else {
				return emoticonList2.size();
			}
		}

		@Override
		public Object getItem(int position) {
			// TODO Auto-generated method stub
			if (this.emoticon_type == 1) {
				return emoticonList1.get(position);
			} else {
				return emoticonList2.get(position);
			}
		}

		@Override
		public long getItemId(int position) {
			// TODO Auto-generated method stub
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			// TODO Auto-generated method stub
			ViewHolder v;
			if (convertView == null) {
				convertView = mInflater.inflate(R.layout.emoticon_item, null);
				v = new ViewHolder();
				v.icon = (ImageView) convertView.findViewById(R.id.emot_icon);
				convertView.setTag(v);
			} else {
				v = (ViewHolder) convertView.getTag();
			}
			EmoticonItem item;
			if (this.emoticon_type == 1) {
				item = emoticonList1.get(position);
			} else {
				item = emoticonList2.get(position);
			}

			v.icon.setImageResource(item.getResources());
			return convertView;
		}

	}
	
	public void loadEmoticon() {
		emoticonList1.add(new EmoticonItem(emoImageIDs[0]));
		for (int i = 1; i < 24; i++) {
			emoticonList1.add(new EmoticonItem(emoImageIDs[i]));
		}
//		emoticonList2.add(new EmoticonItem(emoImageIDs[26]));
//		for (int i = 27; i < 52; i++) {
//			emoticonList2.add(new EmoticonItem(emoImageIDs[i]));
//		}
	}
	
	public void onResume(){
		super.onResume();
		
		if (firstUpdate) {
			startAttachBbsDetail(true);
			firstUpdate = false;
		}
	}

	@Override
	public void onRefresh(int id) {
		adapter.clearData();
		adapter.notifyDataSetChanged();
		
		startAttachBbsDetail(true);
		return;
	}

	@Override
	public void onLoadMore(int id) {
		startAttachBbsDetail(false);
		return;
	}
	
	private void startAttachBbsDetail(boolean showdlg) {
		if (!NetworkUtil.isNetworkAvailable(ReadBBSActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(ReadBBSActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetBbsDetailTask task = new GetBbsDetailTask(ReadBBSActivity.this, adapter, bbs_id);
		task.execute();
	}
	
	public void stopAttachBbsBetail(String bbs_info, String[] arr_content, boolean hasMore) {
		
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		int content_count;
		String[] content;
		String[] img_url;
		
		if (!StringUtil.isEmpty(bbs_info)) {
			user_name = JSONUtil.getValue(bbs_info, "user_name");
			userName.setText(user_name);
			et_chatStr.setHint("@"+user_name+":");
			dateTime.setText(JSONUtil.getValue(bbs_info, "date"));
			imgLoader.displayImage(JSONUtil.getValue(bbs_info, "photo_url"), userPhoto, GgApplication.img_opt_photo);
			
			content_count = arr_content.length;
			content = new String [content_count];
			img_url = new String [content_count];
			
			if (mHeaderViews.size() > 0) {
				for (int i = 0; i < mHeaderViews.size(); ++i) {
					replyListView.removeHeaderView(mHeaderViews.get(i));					
				}
				
				mHeaderViews.clear();
			}
			
			for (int i = 0; i < content_count; i++) {				
				LinearLayout bbs_linear_layout = new LinearLayout(ReadBBSActivity.this);
				//bbs_linear_layout.setBackgroundColor(getResources().getColor(R.color.black));
				bbs_linear_layout.setPadding(0, 0, 0, 10);
				bbs_linear_layout.setOrientation(LinearLayout.VERTICAL);
				
				bbs_content_area = (LinearLayout)LayoutInflater.from(this).inflate(R.layout.bbs_content, bbs_linear_layout, true);
				
				total_area = (RelativeLayout) bbs_content_area.findViewById(R.id.total_area_bbs);
				total_area.setOnClickListener(new View.OnClickListener() {
					
					@Override
					public void onClick(View arg0) {
						req_bbs_id = getIntent().getExtras().getInt("bbs_id");
						setUserName(req_bbs_id, user_name, DIRECT_MODE, 0);
					}
				});
				
				content[i] = JSONUtil.getValue(arr_content[i], "content");
				img_url[i] = JSONUtil.getValue(arr_content[i], "img");
				
			    final String text = content[i];
				final TextView tv_right = (TextView) bbs_content_area.findViewById(R.id.bbs_tv_right);  
				final TextView tv_bottom = (TextView) bbs_content_area.findViewById(R.id.bbs_tv_bottom);  
		        
		        screenWidth = getWindowManager().getDefaultDisplay().getWidth() - 50;  
		        
		        RelativeLayout.LayoutParams param = new RelativeLayout.LayoutParams(screenWidth / 2, screenWidth * 5 / 8);
		        
		        final ImageView iv = (ImageView) bbs_content_area.findViewById(R.id.bbs_image);
		        iv.setAdjustViewBounds(true);
		        iv.setLayoutParams(param);
		        iv.setScaleType(ImageView.ScaleType.FIT_XY); // 레이아웃 크기에 이미지를 맞춘다

		       /* param = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
				param.addRule(RelativeLayout.RIGHT_OF, iv.getId());
				tv_right.setLayoutParams(param);
				
				param = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
				param.addRule(RelativeLayout.BELOW, iv.getId());
				tv_bottom.setLayoutParams(param);*/
	        
				if (img_url[i].indexOf(".png") != -1 || img_url[i].indexOf(".jpg") != -1) {
					
					imgLoader.displayImage(img_url[i], iv, GgApplication.img_opt_bbs);
					
					final String image_url = img_url[i];
					
					if (!StringUtil.isEmpty(img_url[i]))
						iv.setOnClickListener(new View.OnClickListener() {
							@Override
							public void onClick(View arg0) {
								Intent intent = new Intent(ReadBBSActivity.this, ShowImageActivity.class);
								intent.putExtra("img_url", image_url);
								intent.putExtra("display_option", "bbs");
								startActivity(intent);
							}
						});
					 
					/** 
			         * 获取一个字的宽度 
			         */  
			        textWidth = tv_right.getTextSize();  
			        paint.setTextSize(textWidth); 
					/** 
			         * 因为图片一开始的时候，高度是测量不出来的，通过增加一个监听器，即可获取其图片的高度和长度 
			         */  
			        ViewTreeObserver vto = iv.getViewTreeObserver();  
			        vto.addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {  			        	
			        	boolean imageMeasured = false;
			            public boolean onPreDraw() {  
			                if (!imageMeasured) {  
			                    imageMeasured = true;  
			                    int height = iv.getMeasuredHeight();  
			                    int width = iv.getMeasuredWidth();
			                    drawImageViewDone(width, height, text, tv_right, tv_bottom);  
			                }  
			                return imageMeasured;
			            }  
			        });
			        
				} else {
					iv.setVisibility(View.GONE);
					tv_bottom.setVisibility(View.GONE);
					tv_right.setText(text);
				}
				replyListView.addHeaderView(bbs_linear_layout);
				mHeaderViews.add(bbs_linear_layout);
			}

		}
		InputMethodManager inputMethodManager = (InputMethodManager)getSystemService(INPUT_METHOD_SERVICE);
		inputMethodManager.hideSoftInputFromWindow(et_chatStr.getWindowToken(), 0);
		adapter.notifyDataSetChanged();
		index = adapter.getCount();
		replyListView.setPullLoadEnable(hasMore);
	}
	
	public void setUserName(int bbs_id, String userName, int type, int position) {
		this.req_bbs_id = bbs_id;
		et_chatStr.setHint("@"+userName+":");
		this.type = type;
		if (this.type == DIRECT_MODE)
			index = adapter.getCount();
		else {
			index = position;
		}
		et_chatStr.requestFocus();
	}
	
	public String getUserName() {
		return user_name;
	}
	
	private void startAnswerBbs(boolean showdlg, Object[] param) {
		if (!NetworkUtil.isNetworkAvailable(ReadBBSActivity.this))
			return;
		
		AnswerBbsTask task = new AnswerBbsTask(ReadBBSActivity.this, param);
		task.execute();
	}
	
	public void stopAnswerBbs(String data_result) {
		
		if (StringUtil.isEmpty(data_result)){
			Toast.makeText(ReadBBSActivity.this, getString(R.string.register_failed), Toast.LENGTH_SHORT).show();
			return;
		} else {
			Toast.makeText(ReadBBSActivity.this, getString(R.string.answer_success), Toast.LENGTH_SHORT).show();
			BbsReplyItem newitem;
			newitem = new BbsReplyItem(
					JSONUtil.getValueInt(data_result, "list_id"), 
					JSONUtil.getValueInt(data_result, "user_id"), 
					JSONUtil.getValue(data_result, "user_name"), 
					JSONUtil.getValue(data_result, "reply_time"), 
					et_chatStr.getText().toString(), 
					JSONUtil.getValueInt(data_result, "reply_id"),
					JSONUtil.getValueInt(data_result, "depth"));
			adapter.addData(newitem, index);
			index = index + 1;
			adapter.notifyDataSetChanged();
			et_chatStr.setText("");
			emotePanel.setVisibility(View.GONE);
		}
	}
	
    private void drawImageViewDone(int width, int height, String text, TextView tv_right, TextView tv_bottom) {
    	
        // 一行字体的高度  
        int lineHeight = tv_right.getLineHeight();  
        // 可以放多少行  
        int lineCount = (int) Math.ceil((double) height / (double) lineHeight);  
        // 一行的宽度  
        float rowWidth = screenWidth - width - tv_right.getPaddingLeft() - tv_right.getPaddingRight();  
        // 一行可以放多少个字  
        int columnCount = (int) (rowWidth / textWidth);  
  
        // 总共字体数等于 行数*每行个数  
        count = lineCount * columnCount;
        // 一个TextView中所有字符串的宽度和（字体数*每个字的宽度）  
        textTotalWidth = (float) ((float) count * textWidth);  
  
        measureText(text);
        
        if (count > text.length()) { 
        	tv_right.setText(text);
        	tv_bottom.setVisibility(View.GONE);
        } else { 
        	tv_right.setText(text.substring(0, count));  
  
	        // 检查行数是否大于设定的行数，如果大于的话，就每次减少一个字符，重新计算行数与设定的一致  
	        while (tv_right.getLineCount() > lineCount) {  
	            count -= 1;  
	            tv_right.setText(text.substring(0, count));  
	        }  
	        tv_bottom.setPadding(0, lineCount * lineHeight - height, 0, 0);  
	        tv_bottom.setText(text.substring(count));
        }
    }  
  
    /** 
     * 测量已经填充的长度，计算其剩下的长度 
     */  
    private void measureText(String text) {
    	
    	if (count > text.length()) return;
    	
        String string = text.substring(0, count);  
        float size = paint.measureText(string);  
        int remainCount = (int) ((textTotalWidth - size) / textWidth);  
        if (remainCount > 0) {  
            count += remainCount;  
            measureText(text);  
        }  
    }  
}
