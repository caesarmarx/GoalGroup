package com.goalgroup.ui;

import java.io.File;
import java.util.Calendar;

import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.imageupload.MOHttpRequester;
import com.goalgroup.chat.imageupload.MOHttpResponse;
import com.goalgroup.chat.util.UserFunctions;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.task.CreateClubTask;
import com.goalgroup.task.GetClubInfoTask;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;

public class CreateClubActivity extends Activity implements MOHttpRequester {
	
	private String userId;
	private int clubId;
	private String clubName;
	private String createDate;
	private int year;
	private int month;
	private int day;
	private int city = 0;
	private int money = 0;
	private int stadium_area_selected;
	private String homeStadiumAreaID = "";
	private String homeStadiumAddress;
	private String sponsor;
	private String introduction;
	private String markUrl = "";
	private boolean clubMarkChanged = false;
	
	private String[] actionCityItem;
	private int city_selected;
	
	private String[] actionDaysItem;
	private int[] action_days_ids = {
		R.string.club_action_day_01, R.string.club_action_day_02, R.string.club_action_day_03, R.string.club_action_day_04, 
		R.string.club_action_day_05, R.string.club_action_day_06, R.string.club_action_day_07
	};
	private boolean[] days_selected = {
		false, false, false, false, false, false, false
	};
	private boolean[] days_selected_02;
	private int selected_days = 0;
	
	private String[] districtNames;
	private String[] districtIds;
//	private String selectedLocation = "";
	private String club_markPath = "";
//	private int location_selected = 0;
	private boolean[] location_selected;
	private String edit_playArea ="";
	
	private int createClubType;
	
	private TextView tvTitle;
	private Button btnBack;
	private ImageView imgView;
	private Button btnEdit;
	private TextView btnText;
	
	private EditText etClubName;
	private TextView etCreateDate;
	private TextView tvActionDays;
	
	private ImageLoader imgLoader;
	private ImageView ivClubMark;
	private TextView tvActionCity;
	private TextView tvActionLocation;
	private TextView tvHomeStadiumArea;
	private EditText etHomeStadiumAddress;
	private EditText etSponsor;
	private EditText etIntroduction;
	private View history_area;
	private TextView tvHistory;
	private TextView tvMemberCount;
	
//	private Button btnRegisterClub;
//	private Button btnBreakupClub;
	
	private GgProgressDialog dlg;
	private AlertDialog dialog;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_create_club);
		
		userId = GgApplication.getInstance().getUserId();
		clubId = 0;
		tvTitle = (TextView)findViewById(R.id.top_title);
		tvTitle.setText(getString(R.string.create_club));
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				setResult(RESULT_OK, getIntent());
				getIntent().putExtra("club_name", clubName);
				finish();
			}
		});
		
		imgView = (ImageView)findViewById(R.id.top_img);
		btnEdit = (Button)findViewById(R.id.btn_view_more);
		imgView.setBackgroundResource(R.drawable.create_club_ico);
		btnEdit.setVisibility(View.VISIBLE);
		imgView.setVisibility(View.VISIBLE);
		
		btnEdit.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				onEditClub();
			}
		});
		
		btnText = (TextView)findViewById(R.id.common_action_text);
		btnText.setText(R.string.complete);
		
		imgLoader = GgApplication.getInstance().getImageLoader();
		ivClubMark = (ImageView)findViewById(R.id.img_club_mark);
		ivClubMark.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				GgApplication.getInstance().addPhoto(CreateClubActivity.this);
			}
		});
		imgLoader.displayImage("", ivClubMark, GgApplication.img_opt_club_mark);
		
		etClubName = (EditText)findViewById(R.id.editText1);
		etCreateDate = (TextView)findViewById(R.id.create_date);
		etCreateDate.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				showDialog(1);
			}
		});
		final Calendar c = Calendar.getInstance();
        year = c.get(Calendar.YEAR);
        month = c.get(Calendar.MONTH);
        day = c.get(Calendar.DAY_OF_MONTH);
        updateDate();
        
        tvHistory = (TextView)findViewById(R.id.club_history_create);
		tvHistory.setText("");
		tvMemberCount = (TextView)findViewById(R.id.member_count_create);
		tvMemberCount.setText("");
		
		tvActionDays = (TextView)findViewById(R.id.tv_play_dates);
		tvActionCity = (TextView)findViewById(R.id.tv_city);
		tvActionLocation = (TextView)findViewById(R.id.tv_play_area);
		tvHomeStadiumArea = (TextView)findViewById(R.id.tv_main_stadium_area);
		etHomeStadiumAddress = (EditText)findViewById(R.id.tv_main_stadium_address);
		
		actionCityItem = GgApplication.getInstance().getCityName();
		if (actionCityItem.length > 0) {
			city_selected = 0;
			tvActionCity.setText(actionCityItem[0]);
			city = Integer.parseInt(GgApplication.getInstance().getCityID()[city_selected]);
			String[][] sub_distInfo = GgApplication.getInstance().getDistfromCity(String.valueOf(city));
			districtNames = sub_distInfo[2]; 
			districtIds = sub_distInfo[0];
			location_selected = new boolean[districtNames.length];
			for (int i = 0; i < districtNames.length; i++){
				location_selected[i] = false;
			}
		}
		
//		city_selected = 0;
		View areaActionCity = findViewById(R.id.area_create_club_city);
		areaActionCity.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				if (actionCityItem.length < 1) {
					Toast.makeText(CreateClubActivity.this, getString(R.string.none_city_data), Toast.LENGTH_SHORT).show();
					return;
				}
				AlertDialog dialog = new AlertDialog.Builder(CreateClubActivity.this)
				.setTitle(getString(R.string.club_create_action_city))
				.setCancelable(true)
				.setSingleChoiceItems(actionCityItem, city_selected, new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int item) {
						city_selected = item;
		            }
				})
				.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						String value = actionCityItem[city_selected];
						tvActionCity.setText(value);
						if (city == Integer.parseInt(GgApplication.getInstance().getCityID()[city_selected]))
							return;
						city = Integer.parseInt(GgApplication.getInstance().getCityID()[city_selected]);
						
						String[][] sub_distInfo = GgApplication.getInstance().getDistfromCity(String.valueOf(city));
						districtNames = sub_distInfo[2]; 
						districtIds = sub_distInfo[0];
						location_selected = new boolean[districtNames.length];
						for (int i = 0; i < districtNames.length; i++){
							location_selected[i] = false;
						}
						tvActionLocation.setText(getString(R.string.none));
						tvHomeStadiumArea.setText(getString(R.string.none));
//						selectedLocation = "";
//						location_selected = 0;
						stadium_area_selected = 0;
					}
				}).create();
				
				dialog.show();
			}
		});
		
		actionDaysItem = new String[action_days_ids.length];
		for (int i = 0; i < action_days_ids.length; i++)
			actionDaysItem[i] = getString(action_days_ids[i]);
		
		View areaActionDay = findViewById(R.id.area_create_club_weekday);
		areaActionDay.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				days_selected_02 = new boolean[days_selected.length];
				for (int i = 0; i < days_selected.length; i++)
					days_selected_02[i] = days_selected[i];
				
//				if (actionDaysItem.length < 1) {
//					Toast.makeText(CreateClubActivity.this, getString(R.string.none_area_data), Toast.LENGTH_SHORT).show();
//					return;
//				}
				AlertDialog dialog = new AlertDialog.Builder(CreateClubActivity.this)
				.setTitle(getString(R.string.club_action_days))
				.setCancelable(true)
				.setMultiChoiceItems(actionDaysItem, days_selected, new DialogInterface.OnMultiChoiceClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which, boolean isChecked) {
						days_selected_02[which] = isChecked;
						return;
					}
				})
				.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						String value = "";
						for (int i = 0, count = 0; i < days_selected.length; i++) {
							days_selected[i] = days_selected_02[i];
							if (!days_selected[i])
								continue;
							if (count != 0)
								value = value.concat(", ");
							value = value.concat(actionDaysItem[i]);
							count++;
						}
						selected_days = StringUtil.getBinData(days_selected);
						tvActionDays.setText(value);
					}
				}).create();
				
				dialog.show();
			}
		});
		
		View areaActionLocation = findViewById(R.id.area_create_club_location);
		areaActionLocation.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				if (city == 0){
					Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_city_error), Toast.LENGTH_LONG).show();
					return;
				}
				
				String[][] sub_distInfo = GgApplication.getInstance().getDistfromCity(String.valueOf(city));
				districtNames = sub_distInfo[2]; 
				districtIds = sub_distInfo[0];
				
				if (districtNames.length == 0) {
					Toast.makeText(CreateClubActivity.this, getString(R.string.none_area_data), Toast.LENGTH_LONG).show();
					return;
				}
								
				AlertDialog dialog = new AlertDialog.Builder(CreateClubActivity.this)
				.setTitle(getString(R.string.club_create_action_location))
				.setCancelable(true)
				.setMultiChoiceItems(districtNames, location_selected, new DialogInterface.OnMultiChoiceClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which, boolean isChecked) {
						// TODO Auto-generated method stub
						location_selected[which] = isChecked;
					}
				})
				.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
					
					public void onClick(DialogInterface dialog, int which) {
						String value = "";
						edit_playArea = "";
						for (int i = 0, count = 0; i < districtNames.length; i++ ){
							if (!location_selected[i])
								continue;
							if (count != 0){
								value = value.concat(",");
								edit_playArea = edit_playArea.concat(",");
							}
							value = value.concat(districtNames[i]);
							edit_playArea = edit_playArea.concat(districtIds[i]);
							count++;
						}
						if (value.equals("")) {
							tvActionLocation.setText(R.string.none);
						} else {
							tvActionLocation.setText(value);
						}
						
//						String value = districtNames[location_selected];
//						String selLocation = districtIds[location_selected];
//						tvActionLocation.setText(value);
//						selectedLocation = selLocation;
					}
				}).create();
				
				dialog.show();
			}
		});
		
		stadium_area_selected = 0;
		View areaStadiumArea = this.findViewById(R.id.area_create_club_stadium_area);
		areaStadiumArea.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				
				if (city == 0){
					Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_city_error), Toast.LENGTH_LONG).show();
					return;
				}
				
				String[][] sub_distInfo = GgApplication.getInstance().getDistfromCity(String.valueOf(city));
				districtNames = sub_distInfo[2]; 
				districtIds = sub_distInfo[0];
				
				if (districtNames.length == 0) {
					Toast.makeText(CreateClubActivity.this, getString(R.string.none_area_data), Toast.LENGTH_LONG).show();
					return;
				}
				
				AlertDialog dialog = new AlertDialog.Builder(CreateClubActivity.this)
				.setTitle(getString(R.string.club_create_action_stadium_area))
				.setCancelable(true)
				.setSingleChoiceItems(districtNames, stadium_area_selected, new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int item) {
						stadium_area_selected = item;
		            }
				})
				.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						String value = districtNames[stadium_area_selected];
						String selectedStadiumArea = districtIds[stadium_area_selected];
						tvHomeStadiumArea.setText(value);
						homeStadiumAreaID = selectedStadiumArea;
					}
				}).create();
				
				dialog.show();
			}
		});
		
		View areaClubScore = this.findViewById(R.id.area_club_score);
		areaClubScore.setOnClickListener(new View.OnClickListener() {
			
			/**
			 * the method when click 俱乐部资料/成绩
			 */
			public void onClick(View arg0) {
				Intent intent = new Intent(CreateClubActivity.this, ClubHistoryActivity.class);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, clubId);
				startActivity(intent);
			}
		});
		
		View areaClubMembers = this.findViewById(R.id.area_club_members);
		areaClubMembers.setOnClickListener(new View.OnClickListener() {
			
			/**
			 * the method when click 俱乐部资料/成员数
			 */
			public void onClick(View arg0) {
				Intent intent = new Intent(CreateClubActivity.this, ClubMembersActivity.class);
				intent.putExtra(ChatConsts.CLUB_ID_TAG, clubId);
				startActivity(intent);
			}
		});
		
		etSponsor = (EditText)findViewById(R.id.editText2);
		etIntroduction = (EditText)findViewById(R.id.editText3);
		introduction = etIntroduction.getText().toString();
		
//		btnRegisterClub = (Button)findViewById(R.id.btn_register_club);
//		btnRegisterClub.setOnClickListener(new OnClickListener() {
//			
//			@Override
//			public void onClick(View view) {
//				onEditClub();
//			}
//		});
		
		createClubType = getIntent().getExtras().getInt(CommonConsts.CLUB_TYPE_TAG);
		if (createClubType == CommonConsts.EDIT_CLUB) {
			clubId = getIntent().getExtras().getInt(CommonConsts.CLUB_ID_TAG);
			startGetClubInfo(true, clubId, CommonConsts.EDIT_CLUB);
//			btnRegisterClub.setText(getString(R.string.edit_club));
		}
		
//		btnBreakupClub = (Button)findViewById(R.id.btn_breakup_club);
//		btnBreakupClub.setOnClickListener(new OnClickListener() {
//			
//			@Override
//			public void onClick(View arg0) {
//				dialog = new AlertDialog.Builder(CreateClubActivity.this)
//				.setTitle(R.string.breakup_title)
//				.setMessage(R.string.breakup_messege)
//				.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
//					
//					@Override
//					public void onClick(DialogInterface dialog, int which) {
//						Object[] param = new Object[2];
//						param[0] = GgApplication.getInstance().getUserId();
//						param[1] = String.valueOf(clubId);
//						startBreakUpClub(true, param);
//					}
//				})
//				.setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
//					
//					@Override
//					public void onClick(DialogInterface dialog, int which) {					
//					}
//				}).create();
//				
//				dialog.show();
//			}
//		});
//		btnBreakupClub.setVisibility(View.GONE);
		
	}
	
	private void onEditClub() {
		clubName = etClubName.getText().toString();
		if (clubName.length() > 30){
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_name_length_error), Toast.LENGTH_SHORT).show();
			return;
		}
		homeStadiumAddress = etHomeStadiumAddress.getText().toString();
		sponsor = etSponsor.getText().toString();
		introduction = etIntroduction.getText().toString();
		if (StringUtil.isEmpty(markUrl)) {
//			clubMarkChanged = true;
			//Toast.makeText(CreateClubActivity.this, getString(R.string.create_club_mark_nonselected), Toast.LENGTH_LONG).show();
			//return;
		}
		
		if (!clubMarkChanged) {
			startCreateClub(true, createClubType);
			return;
		}
		
		
		clubMarkChanged = false;
		
		UserFunctions userFunctions = new UserFunctions();
		userFunctions.uploadImage(markUrl, CreateClubActivity.this, 0);
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
						club_markPath = json_response.getString("server_file_path");
						startCreateClub(true, createClubType);
					}
				}catch (Exception e) {
						Log.d("Exception occured", e.toString());
				}
			}
			break;
		case MOHttpResponse.STATUS_FAILED:
			Log.d("upload_response", "failed");
			break;
		case MOHttpResponse.STATUS_CANCELLED:
			Log.d("upload_response", "canceled");
			break;
		case MOHttpResponse.STATUS_UNKNOWN:
			Log.d("upload_response", "unknown");
			break;
		default:
			break;
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
			Uri dstUri = Uri.fromFile(new File(Environment.getExternalStorageDirectory(), url));
			
			File dst_file = new File(dstUri.getPath());*/
			
			/* 이미지 크기변환
			 * kyr
			 */
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
			
			clubMarkChanged = true;
			markUrl = src_path;
			imgLoader.displayImage("", ivClubMark, GgApplication.img_opt_club_mark);
			//ivClubMark.setImageBitmap(BitmapFactory.decodeFile(markUrl));
			ivClubMark.setImageBitmap(resizedBitmap);
			break;
		case GgApplication.PICK_FROM_ALBUM:
			Uri captureUri = data.getData();
			String realFileName = GgApplication.getInstance().getRealPathFromURI(CreateClubActivity.this, captureUri);
			File realFile = new File(realFileName);
			GgApplication.getInstance().setImageUri(Uri.fromFile(realFile));
			//mImageCaptureUri = data.getData();
	
		case GgApplication.PICK_FROM_CAMERA:
			Intent intent = new Intent("com.android.camera.action.CROP");
			intent.setDataAndType(GgApplication.getInstance().getImageUri(), "image/*");

//			intent.putExtra("outputX", 320);
//			intent.putExtra("outputY", 320);
			intent.putExtra("aspectX", 0);
			intent.putExtra("aspectY", 0);
			intent.putExtra("scale", true);
			intent.putExtra("output", GgApplication.getInstance().getImageUri());
			startActivityForResult(intent, GgApplication.CROP_FROM_CAMERA);
			break;
		}
		super.onActivityResult(requestCode, resultCode, data);
		return;
	}
	
	private void updateDate() {
		etCreateDate.setText(
			new StringBuilder().append(year).append("-").
				append(pad(month+1)).append("-").
				append(pad(day)));
		createDate = etCreateDate.getText().toString();
	}

	private String pad(int c) {
        if (c >= 10)
            return String.valueOf(c);
        else
            return "0" + String.valueOf(c);
    }
	
	public void startCreateClub(boolean showdlg, int create_type) {
		if (StringUtil.isEmpty(clubName)){
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_name_error), Toast.LENGTH_SHORT).show();
			return;
		} else if (clubName.contains("'")) {
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_name_invalid), Toast.LENGTH_SHORT).show();
			return;			
		} else if (clubName.contains(" ")) {
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_name_invalid), Toast.LENGTH_SHORT).show();
			return;
		} else if(StringUtil.isEmpty(createDate)) {
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_date_error), Toast.LENGTH_SHORT).show();
			return;
		} else if(city == 0) {
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_city_error), Toast.LENGTH_SHORT).show();
			return;
		} else if(selected_days == 0) {
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_actdate_error), Toast.LENGTH_SHORT).show();
			return;
		} else if(StringUtil.isEmpty(edit_playArea)) {
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_dist_error), Toast.LENGTH_SHORT).show();
			return;
		} else if(StringUtil.isEmpty(homeStadiumAreaID)) {
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_stadium_error), Toast.LENGTH_SHORT).show();
			return;
		} else if(StringUtil.isEmpty(homeStadiumAddress)) {
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_stadium_address_error), Toast.LENGTH_SHORT).show();
			return;
		} else if (homeStadiumAddress.contains(" ")) {
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_name_invalid), Toast.LENGTH_SHORT).show();
			return;
		} else if(sponsor.length() > 100) {
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_sponsor_error), Toast.LENGTH_SHORT).show();
			etSponsor.setText("");
			etSponsor.requestFocus();
			return;
		} else if(introduction.length() > 100) {
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_introduction_error), Toast.LENGTH_SHORT).show();
			etIntroduction.setText("");
			etIntroduction.requestFocus();
			return;
		} else {
			if (!NetworkUtil.isNetworkAvailable(CreateClubActivity.this))
				return;
			
			/*if (showdlg) {
				dlg = new GgProgressDialog(CreateClubActivity.this.getBaseContext(), getString(R.string.wait));
				dlg.show();
			}*/
			
			Object[] clubInfo;
			clubInfo = new Object[14];
			clubInfo[0] = userId;
			clubInfo[1] = clubName;
			clubInfo[2] = createDate;
			clubInfo[3] = club_markPath;
			clubInfo[4] = city;
			clubInfo[5] = money;
			clubInfo[6] = introduction;
			clubInfo[7] = selected_days;
			clubInfo[8] = edit_playArea;
			clubInfo[9] = homeStadiumAreaID;
			clubInfo[10] = homeStadiumAddress;
			clubInfo[11] = sponsor;
			clubInfo[12] = create_type;
			clubInfo[13] = clubId;
			
			CreateClubTask task = new CreateClubTask(this, clubInfo);
			task.execute();
		}
	}
	
	public void stopCreateClub(int result) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		switch(result){
		case 1:
			if (createClubType == CommonConsts.EDIT_CLUB) {
				Toast.makeText(CreateClubActivity.this, getString(R.string.club_edit_success), Toast.LENGTH_SHORT).show();
				return;
			}
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_success), Toast.LENGTH_SHORT).show();
			finish();
			return;
		case 0:
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_create_failed), Toast.LENGTH_SHORT).show();
			return;
		case 2:
			Toast.makeText(CreateClubActivity.this, getString(R.string.club_name_exist), Toast.LENGTH_SHORT).show();
			return;
		}
	}
	
	private void startGetClubInfo(boolean showdlg, int club_id, int club_type) {
		if (!NetworkUtil.isNetworkAvailable(CreateClubActivity.this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(CreateClubActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetClubInfoTask task = new GetClubInfoTask(this, String.valueOf(club_id), club_type);
		task.execute();
	}
	
	public void stopGetClubInfo(String infos) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (StringUtil.isEmpty(infos)) {
			Toast.makeText(CreateClubActivity.this, getString(R.string.none_club_data), Toast.LENGTH_SHORT).show();
			finish();
			return;
		}
		
		setUI(infos);
	}
	
	@SuppressWarnings("deprecation")
	private void setUI(String infos) {
		tvTitle.setText(getString(R.string.club_infos));
		btnText.setText(R.string.save_status);
		imgView.setBackgroundResource(R.drawable.edit_ico);
		markUrl = JSONUtil.getValue(infos, "mark_pic_url");
		imgLoader.displayImage(JSONUtil.getValue(infos, "mark_pic_url"), ivClubMark, GgApplication.img_opt_club_mark);
		etClubName.setText(JSONUtil.getValue(infos, "club_name"));
		clubName = etClubName.getText().toString();
//		etClubName.setEnabled(false);
		etCreateDate.setText(JSONUtil.getValue(infos, "found_date"));
		etCreateDate.setEnabled(false);
//		ImageView img_create_date = (ImageView)findViewById(R.id.create_date_arrow);
//		img_create_date.setVisibility(View.INVISIBLE);
		String cityName = JSONUtil.getValue(infos, "city");
		if (actionCityItem.length > 0) {
			if (!StringUtil.isEmpty(cityName))
				tvActionCity.setText(cityName);
			city = Integer.valueOf(GgApplication.getInstance().getIDFromName(cityName,CommonConsts.CITY));
			if (city == 0) {
				city_selected = 0;
				tvActionCity.setText(actionCityItem[0]);
				city = Integer.valueOf(GgApplication.getInstance().getIDFromName(actionCityItem[0],CommonConsts.CITY));
			} else 
				city_selected = StringUtil.getSelectedItem(actionCityItem, cityName);
		} else
			tvActionCity.setText(getString(R.string.none));
			
		selected_days = JSONUtil.getValueInt(infos, "act_time");
		tvActionDays.setText(StringUtil.getStrFromSelValue(selected_days, CommonConsts.ACT_DAY));
		days_selected = StringUtil.getSelectedFromValue(days_selected, selected_days);
		
//		int count = GgApplication.getInstance().getDistLengthfromCityID(String.valueOf(city));
		
		String[][] sub_distInfo = GgApplication.getInstance().getDistfromCity(String.valueOf(city));
		districtNames = sub_distInfo[2]; 
		districtIds = sub_distInfo[0];
		
		if (districtIds.length > 0) {
			String value = "";
			location_selected = new boolean[districtIds.length];
			
			if (!StringUtil.isEmpty(JSONUtil.getValue(infos, "act_area")))
			{
				edit_playArea = JSONUtil.getValue(infos, "act_area");
				String[] selArea = edit_playArea.split(",");
				
				for (int i = 0, cnt = 0; i < districtNames.length; i++) {
					location_selected[i] = false;
					for (int j = 0; j < selArea.length; j++) {
						if (districtIds[i].equals(selArea[j])){
							location_selected[i] = true;
							continue;
						}
					}
					if (!location_selected[i])
						continue;
					if (cnt != 0)
						value = value.concat(",");
					value = value.concat(districtNames[i]);
					cnt++;
				}
			}
			
			if (!StringUtil.isEmpty(value))
				tvActionLocation.setText(value);
			else {
				tvActionLocation.setText(districtNames[0]);
				location_selected[0] = true;
			}
		} else 
			tvActionLocation.setText(getString(R.string.none));
//		String areaName = JSONUtil.getValue(infos, "act_area");
//		if (!StringUtil.isEmpty(areaName))
//			tvActionLocation.setText(areaName);
//		selectedLocation = GgApplication.getInstance().getIDFromName(areaName, CommonConsts.DISTRICT);
//		location_selected = StringUtil.getSelectedItem(districtNames, areaName);
		
		String stadiumArea = JSONUtil.getValue(infos, "home_stadium_area");
		if (districtNames.length > 0) {
			stadium_area_selected = StringUtil.getSelectedItem(this.districtNames, stadiumArea);
			
			if (stadium_area_selected != 0) {
				tvHomeStadiumArea.setText(stadiumArea);
				homeStadiumAreaID = GgApplication.getInstance().getIDFromName(stadiumArea, CommonConsts.DISTRICT);
			} else {
				tvHomeStadiumArea.setText(districtNames[0]);
				homeStadiumAreaID = GgApplication.getInstance().getIDFromName(districtNames[0], CommonConsts.DISTRICT);
			}
		} else
			tvHomeStadiumArea.setText(getString(R.string.none));
		
		String stadiumAddress = JSONUtil.getValue(infos, "home_stadium_address");
		if (!StringUtil.isEmpty(stadiumAddress))
			etHomeStadiumAddress.setText(stadiumAddress);
		
		etSponsor.setText(JSONUtil.getValue(infos, "sponsor"));
		etIntroduction.setText(JSONUtil.getValue(infos, "introduction"));
		history_area = findViewById(R.id.area_history);
		history_area.setVisibility(View.VISIBLE);
		String history = String.format("%s胜 %s平 %s负", 
				JSONUtil.getValueInt(infos, "victor_game"), 
				JSONUtil.getValueInt(infos, "draw_game"), 
				JSONUtil.getValueInt(infos, "lose_game"));
		tvHistory.setText(history);
		String member_count = String.format("%d人", JSONUtil.getValueInt(infos, "member_count"));
		tvMemberCount.setText(member_count);
//		btnBreakupClub.setVisibility(View.VISIBLE);
		
		InputMethodManager inputMethodManager = (InputMethodManager)getSystemService(INPUT_METHOD_SERVICE);
		inputMethodManager.hideSoftInputFromWindow(etClubName.getWindowToken(), 0);
	}
	
//	public void startBreakUpClub(boolean showdlg, Object[] param) {
//		if (!NetworkUtil.isNetworkAvailable(CreateClubActivity.this))
//			return;
//		
//		if (showdlg) {
//			dlg = new GgProgressDialog(CreateClubActivity.this, getString(R.string.wait));
//			dlg.show();
//		}
//		
//		BreakUpClubTask task = new BreakUpClubTask(CreateClubActivity.this, param);
//		task.execute();
//	}
//	
//	public void stopBreakUpClub(int data) {
//		if (dlg != null) {
//			dlg.dismiss();
//			dlg = null;
//		}
//		
//		if (data == 1) {
//			GgApplication.getInstance().getChatInfo().removeChatRooms(clubId);
//			GgApplication.getInstance().popClubID(String.valueOf(clubId));
//			
//			Toast.makeText(CreateClubActivity.this, getString(R.string.breakup_success), Toast.LENGTH_LONG).show();
//			getIntent().putExtra(CommonConsts.BREAKUP_CLUB, CommonConsts.BREAKED_CLUB);
//			setResult(RESULT_OK, getIntent());
//			finish();
//		} else
//			Toast.makeText(CreateClubActivity.this, getString(R.string.breakup_failed), Toast.LENGTH_LONG).show();
//	}
	
	@Override
    protected Dialog onCreateDialog(int id) {
        switch (id) {
        case 1:
            return new DatePickerDialog(this, mDateSetListener, year, month, day);
        }
        return null;
    }
	
	private DatePickerDialog.OnDateSetListener mDateSetListener =
            new DatePickerDialog.OnDateSetListener() {

                public void onDateSet(DatePicker view, int yearValue, int monthOfYear,
                        int dayOfMonth) {
                    year = yearValue;
                    month = monthOfYear;
                    day = dayOfMonth;
                    updateDate();
                }
            };
}
