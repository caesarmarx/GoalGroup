package com.goalgroup.ui;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.R;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.task.SendReportTask;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;

public class ReportActivity extends Activity {
	
	private TextView tvTitle;
	private Button btnBack;
	private Button btnReport;
	private ImageView imgReport;
	private TextView btnText;
	private EditText etContent;
	
	private GgProgressDialog dlg;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_report);
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.send_opinion));
		
		int type = getIntent().getExtras().getInt("type");
		if (type == CommonConsts.REPORT_TYPE){
			tvTitle.setText(getString(R.string.report_other));
			//btnReport.setText(R.string.report_other);
		}
		
		etContent = (EditText)findViewById(R.id.report_content);
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
				inputMethodManager.hideSoftInputFromWindow(
				etContent.getWindowToken(), 0);
				finish();
			}
		});
		
		btnText = (TextView) findViewById(R.id.common_action_text);
		btnText.setText(R.string.report_other);
		
		imgReport = (ImageView)findViewById(R.id.top_img);
		imgReport.setBackgroundResource(R.drawable.save_ico);
		imgReport.setVisibility(View.VISIBLE);
		btnReport = (Button)findViewById(R.id.btn_view_more);
		btnReport.setVisibility(View.VISIBLE);
		btnReport.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				startSendReport(true);
			}
		});
		
	}
	
	private void startSendReport(boolean showdlg) {
		String content;
		content = etContent.getText().toString();
		if (!StringUtil.isEmpty(content)) {
			if (!NetworkUtil.isNetworkAvailable(ReportActivity.this))
				return;
			
			if (showdlg) {
				dlg = new GgProgressDialog(ReportActivity.this, getString(R.string.wait));
				dlg.show();
			}
			
			SendReportTask task = new SendReportTask(ReportActivity.this, content);
			task.execute();
		} else 
			Toast.makeText(ReportActivity.this, getString(R.string.error_input_report), Toast.LENGTH_SHORT).show();
	}
	
	public void stopSendReport(int data_result){
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (data_result == 1)
			Toast.makeText(ReportActivity.this, getString(R.string.report_success), Toast.LENGTH_SHORT).show();
		else
			Toast.makeText(ReportActivity.this, getString(R.string.report_failed), Toast.LENGTH_SHORT).show();
		finish();
	}
}
