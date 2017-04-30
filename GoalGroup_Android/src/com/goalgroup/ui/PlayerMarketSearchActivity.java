package com.goalgroup.ui;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.LinearLayout.LayoutParams;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.utils.StringUtil;

public class PlayerMarketSearchActivity extends Activity implements OnClickListener {

	private final static int SINGLE_SELECT = 0;
	private final static int MULTI_SELECT = 1;
	
	private final static int AGE_COND_COUNTS = 6;
	private final static int POS_COND_COUNTS = 4;
	private final static int DAY_COND_COUNTS = 7;
	private int AREA_COND_COUNTS = 0;
	
	private TextView tvTitle;
	
	private Button btnSearchOK;
	private Button btnSearchCancel;
	private boolean selAgeConds[] = new boolean[0];
	private boolean selPosConds[] = new boolean[0];
	private boolean selDayConds[] = new boolean[0];
	private boolean selAreaConds[] = new boolean[0];
	
	private LinearLayout  ll_areaName;
	private TextView[] areaName;
	private String[][] areaConds;
	private String[] areaIDs;
	
	private int min_age = 0;
	private int max_age = 100;
	private int position;
	private int activity_time;
	private String activity_area = "";
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);		
		setContentView(R.layout.activity_player_market_search);

		areaConds = GgApplication.getInstance().getDistfromCity(String.valueOf(GgApplication.getInstance().getPlayingCity()));
		areaIDs = areaConds[0];
		
		AREA_COND_COUNTS = areaIDs.length;
		areaName = new TextView[AREA_COND_COUNTS];
		
		ll_areaName = (LinearLayout)findViewById(R.id.area_player_location_name);
		
		initConditions();
		
		btnSearchOK = (Button)findViewById(R.id.btn_search_ok);
		btnSearchOK.setOnClickListener(this);
		btnSearchCancel = (Button)findViewById(R.id.btn_search_cancel);
		btnSearchCancel.setOnClickListener(this);
	}
	
	private int[] age_ids = {
		R.id.tv_action_age_1, R.id.tv_action_age_2, R.id.tv_action_age_3, R.id.tv_action_age_4, R.id.tv_action_age_5, R.id.tv_action_age_6
	};
	
	private int[] pos_ids = {
		R.id.tv_action_position_1, R.id.tv_action_position_2, R.id.tv_action_position_3, R.id.tv_action_position_4
	};
	
	private int[] day_ids = {
		R.id.tv_action_weekday_1, R.id.tv_action_weekday_2, R.id.tv_action_weekday_3, R.id.tv_action_weekday_4, 
		R.id.tv_action_weekday_5, R.id.tv_action_weekday_6, R.id.tv_action_weekday_7
	};
	
	private int[] area_ids;

	@Override
	public void onClick(View view) {
		int id = view.getId();
		
		if (onCondProc(age_ids, id, selAgeConds, SINGLE_SELECT))
			return;
		
		if (onCondProc(pos_ids, id, selPosConds, MULTI_SELECT))
			return;
		
		if (onCondProc(day_ids, id, selDayConds, MULTI_SELECT))
			return;
		
		if (onCondProc(area_ids, id, selAreaConds, MULTI_SELECT))
			return;
		
		onSearchProc(id);
	}
	
	private void initConditions() {
		TextView tvConds;
		
		if (getIntent().getExtras().getBooleanArray("sel_age").length != 0)
			selAgeConds = getIntent().getExtras().getBooleanArray("sel_age");
		
		if (getIntent().getExtras().getBooleanArray("sel_pos").length != 0)
			selPosConds = getIntent().getExtras().getBooleanArray("sel_pos");
		
		if (getIntent().getExtras().getBooleanArray("sel_day").length != 0)
			selDayConds = getIntent().getExtras().getBooleanArray("sel_day");
		
		if (getIntent().getExtras().getBooleanArray("sel_area").length != 0)
			selAreaConds = getIntent().getExtras().getBooleanArray("sel_area");
		
		int i;
		
		if (selAgeConds.length == 0) {
			selAgeConds = new boolean[AGE_COND_COUNTS];
			initSelected(selAgeConds);
		}
		
		if (selPosConds.length == 0) {
			selPosConds = new boolean[POS_COND_COUNTS];
			initSelected(selAgeConds);
		}
		
		if (selDayConds.length == 0) {
			selDayConds = new boolean[DAY_COND_COUNTS];
			initSelected(selDayConds);
		}
		
		if (selAreaConds.length == 0){
			selAreaConds = new boolean[AREA_COND_COUNTS];
			initSelected(selAreaConds);
		}
			
		for (i = 0; i < selAgeConds.length; i++) {
			tvConds = (TextView)findViewById(age_ids[i]);
			tvConds.setOnClickListener(this);
		}
		onSelIDs(age_ids, selAgeConds);
		
		for (i = 0; i < selPosConds.length; i++) {
			tvConds = (TextView)findViewById(pos_ids[i]);
			tvConds.setOnClickListener(this);
		}
		onSelIDs(pos_ids, selPosConds);
		
		for (i = 0; i < selDayConds.length; i++) {
			tvConds = (TextView)findViewById(day_ids[i]);
			tvConds.setOnClickListener(this);
		}
		onSelIDs(day_ids, selDayConds);
		
		setViewArea();
		
	}
	
	/**
	 * 검색조건을 초기화하는 메쏘드
	 * @param selected : 검색조건분류에 따르는 선택값
	 */
	private void initSelected(boolean[] selected){
		if (selected.length == 0)
			return;
		
		for (int i = 0; i < selected.length; i++)
			selected[i] = false;
	}
	
	private void setViewArea() {
		area_ids = new int[AREA_COND_COUNTS];
		int ll_count = AREA_COND_COUNTS/4;
		if (AREA_COND_COUNTS%4 != 0)
			ll_count++;
		
		LinearLayout[] textViewLL = new LinearLayout[ll_count];
		LinearLayout.LayoutParams textViewLp = new LinearLayout.LayoutParams(0,
				LayoutParams.WRAP_CONTENT, 0.25f);
		textViewLp.setMargins(0, 5, 0, 0);
		
		ll_count = -1;
		
		for (int i = 0; i < selAreaConds.length; i++) {
			areaName[i] = new TextView(this);
			areaName[i].setId(i);
			areaName[i].setPadding(5, 0, 5, 0);
			areaName[i].setText(areaConds[2][i]);
			areaName[i].setTextSize(16);
			area_ids[i] = areaName[i].getId();
			if (i%4 == 0) {
				ll_count ++;
				textViewLL[ll_count] = new LinearLayout(this);
				textViewLL[ll_count].setOrientation(LinearLayout.HORIZONTAL);
				ll_areaName.addView(textViewLL[ll_count]);
			}
			textViewLL[ll_count].addView(areaName[i], textViewLp);
			areaName[i].setOnClickListener(this);
		}
		onSelIDs(area_ids, selAreaConds);
	}
	
	private int isMatchID(int[] ids, int id) {
		int ret = -1;
		for (int i = 0; i < ids.length; i++) {
			if (ids[i] == id) {
				ret = i;
				break;
			}
		}
		
		return ret;
	}
	
	private boolean onCondProc(int[] ids, int id, boolean[] selecteds, int sel_type) {
		int matchIdx = isMatchID(ids, id);
		if (matchIdx == -1)
			return false;
		
		selecteds[matchIdx] = !selecteds[matchIdx];
		if (sel_type == SINGLE_SELECT)
			for (int i = 0; i < ids.length; i++) {
				if (matchIdx != i)
					selecteds[i] =  false;
				TextView tvSelected = (TextView)findViewById(ids[i]);
				tvSelected.setTextColor(selecteds[i] ? 0xff5dbe00 : 0xffcfcfcf);
			}
		
		TextView tvSelected = (TextView)findViewById(id);
		tvSelected.setTextColor(selecteds[matchIdx] ? 0xff5dbe00 : 0xffcfcfcf);
		
		return true;
	}
	
	/**
	 * 조건에 맞는 항목들을 선택하는 메쏘드
	 * @param ids : 검색화면에 현시되는 검색조건의 ids
	 * @param selecteds : 선택되였는가를 확정하는 변수
	 */
	private void onSelIDs(int[] ids, boolean[] selecteds){
		for (int i = 0; i < ids.length; i++) {
			if (selecteds[i]){
				TextView tvSelected = (TextView)findViewById(ids[i]);
				tvSelected.setTextColor(selecteds[i] ? 0xff5dbe00 : 0xffcfcfcf);
			}
		}
	}
	
	private boolean onSearchProc(int id) {
		if (id != R.id.btn_search_ok && id != R.id.btn_search_cancel)
			return false;
		
		if (id == R.id.btn_search_ok){
			min_age = StringUtil.getAge(selAgeConds, CommonConsts.MIN_AGE);
			max_age = StringUtil.getAge(selAgeConds, CommonConsts.MAX_AGE);
			position = StringUtil.getPosData(selPosConds);
			activity_time = StringUtil.getBinData(selDayConds);
			if (selAreaConds.length > 0)
				activity_area = StringUtil.getIDsFromSelected(areaIDs, selAreaConds);
			getIntent().putExtra("min_age", min_age);
			getIntent().putExtra("max_age", max_age);
			getIntent().putExtra("position", position);
			getIntent().putExtra("activity_time", activity_time);
			getIntent().putExtra("activity_area", activity_area);
			getIntent().putExtra("sel_age", selAgeConds);
			getIntent().putExtra("sel_pos", selPosConds);
			getIntent().putExtra("sel_day", selDayConds);
			getIntent().putExtra("sel_area", selAreaConds);
			setResult(RESULT_OK, getIntent());
		}
		
		finish();
		return true;
	}
}
