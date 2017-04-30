package com.goalgroup.ui.adapter;

import java.util.ArrayList;

import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.goalgroup.R;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.model.BbsReplyItem;
import com.goalgroup.ui.ReadBBSActivity;
import com.goalgroup.ui.view.xTextView;

public class BbsReplyAdapter extends BaseAdapter {
	
	public static final int TYPE_ONE_ITEM = 0;
	public static final int TYPE_TOP_ITEM = 1;
	public static final int TYPE_MID_ITEM = 2;
	public static final int TYPE_BOT_ITEM = 3;
	
	private ReadBBSActivity ctx;
	private ArrayList<BbsReplyItem> datas;
	
	public BbsReplyAdapter(ReadBBSActivity aCtx) {
		ctx = aCtx;
		datas = new ArrayList<BbsReplyItem>();
		
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
		BbsReplyItem data = datas.get(position);
		if (data == null)
			return null;
		
		ViewHolder holder;
		if (view == null) {
			view = LayoutInflater.from(ctx).inflate(R.layout.bbs_reply_adapter, null);
			
			holder = new ViewHolder();
			
			holder.reply_area = (LinearLayout)view.findViewById(R.id.reply_area);
			holder.reply_content_area = (LinearLayout)view.findViewById(R.id.reply_content_area);
			holder.answer_area = view.findViewById(R.id.bbs_answer_area);
			
			holder.userName = (TextView)view.findViewById(R.id.user_name);
			holder.replyLb = (TextView)view.findViewById(R.id.reply_lb);
			holder.replyUserName = (TextView)view.findViewById(R.id.reply_user_name);
			holder.datetime = (TextView)view.findViewById(R.id.reply_date_time);
			holder.contents = (xTextView)view.findViewById(R.id.reply_contents);
			
			view.setTag(holder);
		} else {
			holder = (ViewHolder)view.getTag();
		}
		
		holder.initHolder(data, position);
		
		return view;
	}
	
	private class ViewHolder {
		private View depth;
		private TextView userName;
		private TextView replyUserName;
		private TextView replyLb;
		private TextView datetime;
		private xTextView contents;
		private View answer_area;
		private LinearLayout reply_area;
		private LinearLayout reply_content_area;
		
		public void initHolder(final BbsReplyItem data, final int position) {
			depth = new View(ctx);
			LayoutParams layout_param = 
					new LinearLayout.LayoutParams(data.getDepth()*20, LayoutParams.MATCH_PARENT);
			reply_area.removeAllViews();
			reply_area.addView(depth, layout_param);
			reply_area.addView(reply_content_area);
			
			String strReplyUserName = "";
			int depth = data.getDepth();
			if (depth == 0)
				strReplyUserName = ctx.getUserName();
			else {
				int replyID = data.getReplyId();
				strReplyUserName = getNameFromReplyID(replyID);
			}
			
			String strUserName = data.getUserName();
			String tmpStr = "";
			
			int len = strUserName.length();
			for (int index = 0; index < len; index++) {
				try {
					if (index % 8 == 0) tmpStr += "".equals(tmpStr) ? strUserName.substring(index, index + 8) : "\n" + strUserName.substring(index, index + 8);
				} catch (IndexOutOfBoundsException e) {
					tmpStr += "\n" + strUserName.substring(index);
				}
			}
			strUserName = tmpStr;
			
			tmpStr = "";
			len = strReplyUserName.length();
			for (int index = 0; index < len; index++) {
				try {
					if (index % 8 == 0) tmpStr += "".equals(tmpStr) ? strReplyUserName.substring(index, index + 8) : "\n" + strReplyUserName.substring(index, index + 8);
				} catch (IndexOutOfBoundsException e) {
					tmpStr += "\n" + strReplyUserName.substring(index);
				}
			}
			strReplyUserName = tmpStr;
			
			userName.setText(strUserName);
			userName.setGravity(Gravity.CENTER);
			replyUserName.setText(strReplyUserName+":");
			replyUserName.setGravity(Gravity.CENTER);
			replyLb.setGravity(Gravity.CENTER);
			
			/*if (strUserName.length() >= strReplyUserName.length() && strUserName.length() > 6) {
				RelativeLayout.LayoutParams relativeLayoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
				relativeLayoutParams.topMargin = userName.getHeight() / 3;
				relativeLayoutParams.addRule(RelativeLayout.RIGHT_OF, userName.getId());
				replyLb.setLayoutParams(relativeLayoutParams);
				
				RelativeLayout.LayoutParams relativeLayoutParams1 = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
				relativeLayoutParams1.topMargin = userName.getHeight() / 3;
				relativeLayoutParams1.addRule(RelativeLayout.RIGHT_OF, replyLb.getId());

				replyUserName.setLayoutParams(relativeLayoutParams1);
				notifyDataSetChanged();
			} else if (strReplyUserName.length() >= strUserName.length() && strReplyUserName.length() > 6) {
				//userName.setTop(replyUserName.getHeight() / 3);
			}*/
			datetime.setText(data.getDateTime());
			contents.setMessage(data.getContents(), ChatConsts.MSG_TEXT);

			answer_area.setOnClickListener(new View.OnClickListener() {
				
				@Override
				public void onClick(View v) {
					int i = 0;
					for (i = datas.indexOf(data)+1; i < datas.size(); i++){
						BbsReplyItem temp = datas.get(i);
						if (temp.getDepth() <= data.getDepth())
							break;
						/*if (temp.getReplyId() == data.getId()) {
							ctx.setUserName(data.getId(), data.getUserName(), 1, i+1);
							return;
						}*/
					}
					
					if (i < datas.size())
						ctx.setUserName(data.getId(), data.getUserName(), 1, i);
					else					
						ctx.setUserName(data.getId(), data.getUserName(), 1, datas.size());
				}
			});
		}
		
		private String getNameFromReplyID(int replyId){
			String userName = "";
			for (int i = 0; i < datas.size(); i++){
				BbsReplyItem data = datas.get(i);
				if (replyId == data.getId())
					userName = data.getUserName();
			}
			return userName;
		}
	}
	
	public void addData(ArrayList<BbsReplyItem> newdatas) {
		for (BbsReplyItem item : newdatas) {
			datas.add(item);
		}
	}
	
	public void addData(BbsReplyItem newdata, int index) {
		datas.add(index, newdata);
	}
	
	public void clearData() {
		datas.clear();
	}
}
