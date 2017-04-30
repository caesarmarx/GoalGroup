package com.goalgroup.ui;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.utils.FileUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

public class ShowImageActivity extends Activity {

	private TextView tvTitle;
	private Button btnBack;	
	private ImageView imgView;
	private ImageLoader imgLoader;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_show_image);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.show_image));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		imgView = (ImageView)findViewById(R.id.show_image);
		imgLoader = GgApplication.getInstance().getImageLoader();
		String url = getIntent().getExtras().getString("img_url");
		String type = getIntent().getExtras().getString("display_option");
		if(type.equals("bbs"))
			imgLoader.displayImage(url, imgView, GgApplication.img_opt_bbs);
		else if(type.equals("mail")) {
			Bitmap bm;
			bm = BitmapFactory.decodeFile(url);
			imgView.setImageBitmap(bm);
		}
		
	}
}
