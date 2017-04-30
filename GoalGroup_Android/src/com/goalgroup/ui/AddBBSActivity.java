package com.goalgroup.ui;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;

import org.json.JSONObject;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.imageupload.MOHttpRequester;
import com.goalgroup.chat.imageupload.MOHttpResponse;
import com.goalgroup.chat.util.UserFunctions;
import com.goalgroup.task.AddBBSTask;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.TextView;
import android.widget.Toast;

public class AddBBSActivity extends Activity implements MOHttpRequester{
		
	private TextView tvTitle;
	private Button btnBack;
	
	private GgProgressDialog dlg;
	
	//변경된 사양
	private LinearLayout totalArea;
	
	private int content_count;
	private int sel_count;
	private int imgselected_count = 0;
	private int uploaded_count;
	
	String photoFileNames;
	private Uri mImageCropUri;
	private ArrayList<AddBBSItem> bbs_list;
	private Object[] param = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_add_bbs);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.create_bbs));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		totalArea = (LinearLayout)findViewById(R.id.total_content_area);
		content_count = 0;
		
		bbs_list = new ArrayList<AddBBSActivity.AddBBSItem>();
		AddBBSItem bbs_item = new AddBBSItem(content_count);
		bbs_list.add(bbs_item);
		
		Button btnSetting = (Button)findViewById(R.id.btn_view_more);
		btnSetting.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				startCreateDiscuss(true);
			}
		});
		btnSetting.setVisibility(View.VISIBLE);
		btnSetting.setText(R.string.announce);
	}
	
	public void startCreateDiscuss(boolean showdlg) {
		int count = bbs_list.size() - 1;
		if (count == 0) {
			Toast.makeText(AddBBSActivity.this, getString(R.string.error_input_bbs), Toast.LENGTH_SHORT).show();
			return;
		}
		
		if (param != null)
			param = null;
		
		if (!NetworkUtil.isNetworkAvailable(AddBBSActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(AddBBSActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		makeUploadParams();
		
		if (imgselected_count == 0) {
			param[2 + 2 * count] = 1;
			
			AddBBSTask task = new AddBBSTask(this, param);
			task.execute();
		}
		
		uploaded_count = 0;
		for (int i = 0; i < count; i ++) {
			AddBBSItem bbs_item = bbs_list.get(i);
			if (StringUtil.isEmpty(bbs_item.getImageUrl()))
				continue;
			
			UserFunctions userFunctions = new UserFunctions();
			userFunctions.uploadImage(bbs_item.getImageUrl(), this, i);
		}
	}
	
	private void makeUploadParams() {
		int count = bbs_list.size() - 1;
		imgselected_count = 0;
		
		if (param == null) {
			param = new Object[3 + 2 * count];
		
			param[0] = GgApplication.getInstance().getUserId();
			param[1] = count;
		}
		
		for (int i = 0; i < count; i ++) {
			AddBBSItem bbs_item = bbs_list.get(i);
			param[(i + 1) * 2] = bbs_item.getImageUrl();
			param[(i + 1) * 2 + 1] = bbs_item.getContent();
			
			if (StringUtil.isEmpty(bbs_item.getImageUrl()))
				continue;
			
			imgselected_count ++;
		}
	}
	
	@Override
	public void callback(MOHttpResponse res) {
		
		Log.d("upload response", res.toString());
		
		int status = res.getStatus();
		String resultStr = null;

		switch (status) {
		
		case MOHttpResponse.STATUS_SUCCESS:
			
			if(res.getResultDataString() != null) {
				resultStr = res.getResultDataString();
				JSONObject json_response;
				try {
					json_response = new JSONObject(resultStr);
				
					int success = json_response.getInt("success");
					if(success == 0) {
						Log.d("call back func", "success  =  0");
					}
					else {
						int count = bbs_list.size() - 1;
						
						String server_file_path = json_response.getString("server_file_path");
						int uploadedIdx = json_response.getInt("server_idx");
						AddBBSItem bbs_item = bbs_list.get(uploadedIdx);
						param[(uploadedIdx + 1) * 2] = server_file_path;
						param[(uploadedIdx + 1) * 2 + 1] = bbs_item.getContent();

						uploaded_count ++;
						
						if (imgselected_count == uploaded_count) {
							param[2 + 2 * count] = 1;
							
							AddBBSTask task = new AddBBSTask(this, param);
							task.execute();
						}
					}
				}catch (Exception e) {
						Log.d("Exception occured", e.toString());
				}
			}
			break;
		case MOHttpResponse.STATUS_FAILED:
		case MOHttpResponse.STATUS_CANCELLED:
		case MOHttpResponse.STATUS_UNKNOWN:
			if (dlg != null) {
				dlg.dismiss();
				dlg = null;
			}
			Toast.makeText(AddBBSActivity.this, getString(R.string.img_upload_failed), Toast.LENGTH_LONG).show();
			Log.d("upload_response", "unknown");
			break;
		default:
			break;
		}
	}

	public void stopCreateDiscuss(int result) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (result == 1) {
			Toast.makeText(AddBBSActivity.this, getString(R.string.register_bbs_success), Toast.LENGTH_SHORT).show();
			setResult(RESULT_OK, getIntent());
			finish();
		} else {
			Toast.makeText(AddBBSActivity.this, getString(R.string.register_bbs_failed), Toast.LENGTH_SHORT).show();
			return;
		}
		
	}
	
	public void onActivityResult (int requestCode, int resultCode, Intent data) {
		int newWidth = 320;
		int newHeight = 320;
		
		if (resultCode != Activity.RESULT_OK)
			return;
		
		switch(requestCode) {
		case GgApplication.CROP_FROM_CAMERA:
			/*long now = System.currentTimeMillis();
			Date curDate = new Date(now);
			
			String url = "pic";
			
			String date_string = String.format("_%04d%02d%02d_%02d%02d%02d_", curDate.getYear() + 1900, curDate.getMonth() + 1, curDate.getDate(), 
					curDate.getHours(), curDate.getMinutes(), curDate.getSeconds());
			url = url.concat(date_string);
			url = url.concat(".jpg");
			mImageCropUri = Uri.fromFile(new File(Environment.getExternalStorageDirectory(), url));
			
			File src_file = new File(GgApplication.getInstance().getImageUri().getPath());
			File dst_file = new File(mImageCropUri.getPath());
			
			if (GgApplication.getInstance().copyFile(src_file, dst_file)) {			
				photoFileNames = mImageCropUri.getPath();
				AddBBSItem bbs_item;
				bbs_item = bbs_list.get(sel_count);
				bbs_item.setImage(photoFileNames);
			}*/
			
			/////
			String src_path = GgApplication.getInstance().getImageUri().getPath();
			
			if ("".equals(src_path)) break;
			
			Bitmap orgBitMap = BitmapFactory.decodeFile(src_path);
			int orgWidth = orgBitMap.getWidth();
			int orgHeight = orgBitMap.getHeight();
			
			float scaleWidth = ((float) newWidth) / orgWidth;
			float scaleHeight = ((float) newHeight) / orgHeight;
			
			Matrix matrix = new Matrix();
			matrix.postScale(scaleWidth, scaleHeight);
			
			Bitmap resizedBitmap = Bitmap.createBitmap(orgBitMap, 0, 0, orgWidth, orgHeight, matrix, true);
			
			AddBBSItem bbs_item = bbs_list.get(sel_count);
			bbs_item.setImage(resizedBitmap);
			
			break;
		case GgApplication.PICK_FROM_ALBUM:
			Uri captureUri = data.getData();
			String realFileName = GgApplication.getInstance().getRealPathFromURI(AddBBSActivity.this, captureUri);
			File realFile = new File(realFileName);
			GgApplication.getInstance().setImageUri(Uri.fromFile(realFile));
			//mImageCaptureUri = data.getData();
		case GgApplication.PICK_FROM_CAMERA:
			Intent intent = new Intent("com.android.camera.action.CROP");
			intent.setDataAndType(GgApplication.getInstance().getImageUri(), "image/*");

//			intent.putExtra("outputX", 320);
//			intent.putExtra("outputY", 320);
//			intent.putExtra("aspectX", 1);
//			intent.putExtra("aspectY", 1);
//			intent.putExtra("scale", true);
////			intent.putExtra("return-data", true);
//			intent.putExtra("output", GgApplication.getInstance().getImageUri());
			startActivityForResult(intent, GgApplication.CROP_FROM_CAMERA);
			break;
		}
		super.onActivityResult(requestCode, resultCode, data);
		return;
	}
	
	private class AddBBSItem {
		private int index;
		private LinearLayout content_area;
		private ImageView img_pic;
		private EditText et_content;
		
		private String img_name = "";
		
		public AddBBSItem(int pos) {
			index = pos;
			img_name = "";
			content_count++;
			content_area = new LinearLayout(AddBBSActivity.this);
			LinearLayout.LayoutParams layout_param = 
					new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
			img_pic = new ImageView(AddBBSActivity.this);
			img_pic.setImageResource(R.drawable.addicon);
			img_pic.setPadding(5, 5, 5, 5);
			img_pic.setScaleType(ScaleType.CENTER);
			
			img_pic.setOnClickListener(new View.OnClickListener() {				
				@Override
				public void onClick(View v) {
					sel_count = index;
					GgApplication.getInstance().addPhoto(AddBBSActivity.this);
				}
			});
			
			et_content = new EditText(AddBBSActivity.this);
			content_area.setGravity(Gravity.CENTER_VERTICAL);
			content_area.setPadding(5, 5, 5, 5);
			content_area.setOrientation(LinearLayout.HORIZONTAL);
			content_area.setBackgroundColor(Color.WHITE);
			totalArea.addView(content_area, layout_param);
			et_content.setTextSize(16);
			et_content.setGravity(Gravity.TOP);	
			et_content.addTextChangedListener(new TextWatcher() {
				
				@Override
				public void onTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {
					// TODO Auto-generated method stub
					if (et_content.getText().length() > 0){
						if (index == bbs_list.size() - 1){
							AddBBSItem bbs_item = new AddBBSItem(content_count);
							bbs_list.add(bbs_item);
						}
					} else
						if (index == bbs_list.size() - 2){
							AddBBSItem bbs_item;
							bbs_item = bbs_list.get(index+1);
							bbs_item.remove();
							bbs_list.remove(index+1);
						}
				}
				
				@Override
				public void beforeTextChanged(CharSequence arg0, int arg1, int arg2,
						int arg3) {
					// TODO Auto-generated method stub
					
				}
				
				@Override
				public void afterTextChanged(Editable arg0) {
					// TODO Auto-generated method stub
					
				}
			}); 
				
			layout_param = new LinearLayout.LayoutParams(120, 120);
			content_area.addView(img_pic,layout_param);
			layout_param = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
			content_area.addView(et_content,layout_param);
		}
		
		public void setImage(Bitmap bitmap){
			
			img_name = GgApplication.getInstance().getImageUri().getPath();
			img_pic.setImageBitmap(bitmap);
			
			if (!StringUtil.isEmpty(img_name)){
				if (index == bbs_list.size()-1){
					AddBBSItem bbs_item = new AddBBSItem(content_count);
					bbs_list.add(bbs_item);
				}
			} else
				if (index == bbs_list.size() - 2){
					AddBBSItem bbs_item;
					bbs_item = bbs_list.get(index+1);
					bbs_item.remove();
					bbs_list.remove(index+1);
				}
		}
		
		public void remove() {
			content_count--;
			content_area.setVisibility(View.GONE);
		}
		
		public String getImageUrl() {
			return img_name;
		}
		
		public String getContent() {
			return et_content.getText().toString();
		}
	}
	
}
