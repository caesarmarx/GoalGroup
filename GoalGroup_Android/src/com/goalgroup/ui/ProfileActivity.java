package com.goalgroup.ui;

import java.io.File;
import java.util.Date;

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
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.goalgroup.GgApplication;
import com.goalgroup.R;
import com.goalgroup.chat.imageupload.MOHttpRequester;
import com.goalgroup.chat.imageupload.MOHttpResponse;
import com.goalgroup.chat.util.UserFunctions;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.model.MyClubData;
//import com.goalgroup.model.PlayerFilterResultItem;
import com.goalgroup.task.EditUserProfileTask;
import com.goalgroup.task.GetProfileTask;
import com.goalgroup.task.SendInvReqTask;
//import com.goalgroup.ui.adapter.PlayFilterResultAdapter;
import com.goalgroup.ui.dialog.GgProgressDialog;
import com.goalgroup.ui.view.CircularImageView;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.NetworkUtil;
import com.goalgroup.utils.StringUtil;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.smaxe.uv.amf3.Array;

public class ProfileActivity extends Activity implements MOHttpRequester  {

	private String old_nickName;
	private String edit_nickName;
	private String edit_phoneNum;
	private int edit_sex;
	private String edit_birthday;
	private String edit_height;
	private String edit_weight;
	private String edit_photo = "";
	private String edit_term;
	private int edit_position;
	private int edit_city;
	private int edit_playDate;
	private String edit_playArea;
//	private int edit_playArea;
	
	private Uri mImageCropUri;
	
	private TextView tvTitle;
	private TextView btnText;
	private Button btnBack;
	private Button btnEdit;
	private ImageView btnEditImg;
	private EditText etNickName;
	private TextView etPhoneNum;
	private TextView tvSex;
	private TextView tvBirthday;
	private EditText etHeight;
	private EditText etWeight;
	private EditText etTerm;
	private TextView tvPosition;
	private TextView tvCity;
	private TextView tvPlayDate;
	private TextView tvPlayArea;
	private Button btnInvite;
	private View btnInviteArea;
	
	private ImageView photo;
	private ImageLoader imgLoader;
	
	private GgProgressDialog dlg;
	private AlertDialog alertDialog;
	
	private int year;
	private int month;
	private int day;
	
	private String[] sexItem;
	private int sexSelected = 0;
	
	private int user_id;
	private int[] clubIds;

	private MyClubData myClubData;
	
	private int type;
	
	private int[] playDateIDs = {
			R.string.club_action_day_01, R.string.club_action_day_02, R.string.club_action_day_03, R.string.club_action_day_04, 
			R.string.club_action_day_05, R.string.club_action_day_06, R.string.club_action_day_07
		};
	private String[] playDateItem;
	
	private String[] clubNames;
	private String multi_sel_clubs;
	
	private boolean[] dateSelected = {
		false, false, false, false, false, false, false	
	};
	private boolean[] dateSelectedShow;
	
	private int[] positionIDs = {
			R.string.position_forward1, R.string.position_forward2, R.string.position_forward3, R.string.position_midfield1
			, R.string.position_midfield2, R.string.position_midfield3, R.string.position_midfield4, R.string.position_back1
			, R.string.position_back2, R.string.position_back3, R.string.position_keeper
	};
	private String[] positionItem;
	private boolean[] positionSelected = {
			false, false, false, false, false, false, false, false, false, false, false
	};
	private boolean[] positionSelectedShow;
	
	private String[] cityID;
	private String[] cityName;
	private int citySelected = 0;
	private int city = 0;
	
	private String[] sub_distName;
	private String[] sub_distIds;
	private boolean[] distsSelected;
	
	private static boolean cImgSetFlag = false;
	private static int PROFILE_ACTIVITY_FLAG = 1;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_profile);
		
		myClubData = new MyClubData();
		
		tvTitle = (TextView)findViewById(R.id.top_title);
		
		btnBack = (Button)findViewById(R.id.btn_back);
		btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				finish();
			}
		});
		
		btnEdit = (Button)findViewById(R.id.btn_view_more);
		btnEditImg = (ImageView)findViewById(R.id.top_img);
		
		btnEdit.setVisibility(View.VISIBLE);
		btnEditImg.setVisibility(View.VISIBLE);
		
		btnEditImg.setBackgroundResource(R.drawable.edit_ico);
		
		btnEdit.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				getInputValues();
				startResigterProfile(true);
				System.out.println("ok");
			}
		});
		
		user_id = getIntent().getExtras().getInt("user_id");
		type = getIntent().getExtras().getInt("type");
		
		btnText = (TextView) findViewById(R.id.common_action_text);
		
		imgLoader = GgApplication.getInstance().getImageLoader();
		photo = (CircularImageView)findViewById(R.id.photo);
		photo.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View arg0) {
				GgApplication.getInstance().addPhoto(ProfileActivity.this);
			}
		});
		
		initUI();
		
		sexItem = new String[2];
		sexItem[0] = getString(R.string.sex_male);
		sexItem[1] = getString(R.string.sex_female);

		cityID = GgApplication.getInstance().getCityID();
		cityName = GgApplication.getInstance().getCityName();
		
		positionItem = new String[positionIDs.length];
		for (int i = 0; i < positionIDs.length; i++)
			positionItem[i] = getString(positionIDs[i]);
		
		playDateItem = new String[playDateIDs.length];
		for (int i = 0; i < playDateIDs.length; i++)
			playDateItem[i] = getString(playDateIDs[i]);
/*		
		View areaPwd = findViewById(R.id.area_password);
		areaPwd.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				
			}
		});
		*/
		View areaBirthday = findViewById(R.id.area_birthday);
		areaBirthday.setOnClickListener(new View.OnClickListener() {
			
			@SuppressWarnings("deprecation")
			@Override
			public void onClick(View arg0) {
				showDialog(1);
			}
		});
		
		if (cityName.length > 0) {
			citySelected = 0;
			String value = cityName[citySelected];
			tvCity.setText(value);
			
			city = Integer.parseInt(GgApplication.getInstance().getCityID()[citySelected]);
		}
		
		View actCity = findViewById(R.id.area_city);
		actCity.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				if (cityName.length < 1) {
					Toast.makeText(ProfileActivity.this, getString(R.string.none_city_data), Toast.LENGTH_SHORT).show();
					return;
				}
				AlertDialog dialog = new AlertDialog.Builder(ProfileActivity.this)
				.setTitle(getString(R.string.city_colon))
				.setCancelable(true)
				.setSingleChoiceItems(cityName, citySelected, new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int item) {
						// TODO Auto-generated method stub
						citySelected = item;
					}
				})
				.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						String value = cityName[citySelected];
						tvCity.setText(value);
						if (city == Integer.parseInt(GgApplication.getInstance().getCityID()[citySelected]))
							return;
						city = Integer.parseInt(GgApplication.getInstance().getCityID()[citySelected]);
						
						String sub_distInfo[][];
						int count = GgApplication.getInstance().getDistLengthfromCityID(String.valueOf(city));
						sub_distInfo = new String[3][count];
						sub_distInfo = GgApplication.getInstance().getDistfromCity(String.valueOf(city));
						sub_distName = new String[count];
						sub_distName = sub_distInfo[2];
						sub_distIds = sub_distInfo[0];
						distsSelected = new boolean[count];
						for (int i = 0; i < count; i++){
							distsSelected[i] = false;
						}
						tvPlayArea.setText(getString(R.string.none));
						edit_playArea = "";						
					}
				}).create();
				
				dialog.show();
			}
		});
		
		View actDist = findViewById(R.id.area_play_area);
		actDist.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				if (city == 0){
					Toast.makeText(ProfileActivity.this, getString(R.string.club_create_city_error), Toast.LENGTH_LONG).show();
					return;
				}
				
				if (sub_distName.length == 0) {
					Toast.makeText(ProfileActivity.this, getString(R.string.none_area_data), Toast.LENGTH_LONG).show();
					return;
				}
				
				AlertDialog dialog = new AlertDialog.Builder(ProfileActivity.this)
				.setTitle(getString(R.string.club_create_action_location))
				.setCancelable(true)
				.setMultiChoiceItems(sub_distName, distsSelected, new DialogInterface.OnMultiChoiceClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which, boolean isChecked) {
						// TODO Auto-generated method stub
						distsSelected[which] = isChecked;
					}
				})
				.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						// TODO Auto-generated method stub
						String value = "";
						edit_playArea = "";
						for (int i = 0, count = 0; i < sub_distName.length; i++ ){
							if (!distsSelected[i])
								continue;
							if (count != 0){
								value = value.concat(",");
								edit_playArea = edit_playArea.concat(",");
							}
							value = value.concat(sub_distName[i]);
							edit_playArea = edit_playArea.concat(sub_distIds[i]);
							count++;
						}
						if (value.equals("")) {
							tvPlayArea.setText(R.string.none);
						} else {
							tvPlayArea.setText(value);
						}
					}
				}).create();
				
				dialog.show();
			}
		});
		
		View playDate = findViewById(R.id.area_play_date);
		playDate.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				dateSelectedShow = new boolean[playDateIDs.length];
				for (int i = 0; i < playDateIDs.length; i++) {
					dateSelectedShow[i] = dateSelected[i];
				}
				
				AlertDialog dialog = new AlertDialog.Builder(ProfileActivity.this)
				.setTitle(getString(R.string.play_dates))
				.setCancelable(true)
				
				.setMultiChoiceItems(playDateItem, dateSelected, new DialogInterface.OnMultiChoiceClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which, boolean isChecked) {
						// TODO Auto-generated method stub
						dateSelectedShow[which] = isChecked;
						return;
					}
				})
				.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						// TODO Auto-generated method stub
						String value = "";
						for (int i = 0, count = 0; i < playDateIDs.length; i++ ){
							if (!dateSelected[i])
								continue;
							if (count != 0)
								value = value.concat(", ");
							value = value.concat(playDateItem[i]);
							count++;
						}
						if (value.equals("")) {
							tvPlayDate.setText(R.string.none);
						} else {
							tvPlayDate.setText(value);
						}
					}
				}).create();
				
				dialog.show();
			}
		});
		
		View position = findViewById(R.id.area_position);
		position.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				positionSelectedShow = new boolean[positionIDs.length];
				for (int i = 0; i < positionIDs.length; i++){
					positionSelectedShow[i] = positionSelected[i];
				}
				
				AlertDialog dialog = new AlertDialog.Builder(ProfileActivity.this)
				.setTitle(R.string.player_position)
				.setCancelable(true)
				.setMultiChoiceItems(positionItem, positionSelected, new DialogInterface.OnMultiChoiceClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which, boolean isChecked) {
						// TODO Auto-generated method stub
						positionSelectedShow[which] = isChecked;
						return;
					}
				})
				.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int which) {
						// TODO Auto-generated method stub
						String value = "";
						for (int i = 0, count = 0; i < positionIDs.length; i++ ){
							if (!positionSelected[i])
								continue;
							if (count != 0)
								value = value + "\n";
							value = value.concat(positionItem[i]);
							count++;
						}
						if (value.equals("")) {
							tvPosition.setText(R.string.none);
						} else {
							tvPosition.setText(value);
						}
					}
				}).create();
				dialog.show();
			}
		});
		
		View areaSex = findViewById(R.id.area_sex);
		areaSex.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				
				AlertDialog dialog = new AlertDialog.Builder(ProfileActivity.this)
				.setTitle(getString(R.string.sex_colon))
				.setCancelable(true)
				.setSingleChoiceItems(sexItem, sexSelected, new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface dialog, int item) {
						// TODO Auto-generated method stub
						sexSelected = item;
					}
				})
				.setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
					
					@Override
					public void onClick(DialogInterface arg0, int arg1) {
						// TODO Auto-generated method stub
						String value = sexItem[sexSelected];
						tvSex.setText(value);
					}
				}).create();
				
				dialog.show();
			}
		});
		
		btnInvite.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				showTeamMultiSelDialog();
			}
		});

		if (type == CommonConsts.SHOW_PROFILE) {
			areaSex.setEnabled(false);
			areaBirthday.setEnabled(false);
			position.setEnabled(false);
			playDate.setEnabled(false);
			actCity.setEnabled(false);
			actDist.setEnabled(false);
			btnEdit.setVisibility(View.GONE);
			btnEditImg.setVisibility(View.GONE);
//			ImageView arrow = (ImageView)findViewById(R.id.sex_arrow);
//			arrow.setVisibility(View.GONE);
//			arrow = (ImageView)findViewById(R.id.date_arrow);
//			arrow.setVisibility(View.GONE);
//			arrow = (ImageView)findViewById(R.id.pos_arrow);
//			arrow.setVisibility(View.GONE);
//			arrow = (ImageView)findViewById(R.id.city_arrow);
//			arrow.setVisibility(View.GONE);
//			arrow = (ImageView)findViewById(R.id.area_arrow);
//			arrow.setVisibility(View.GONE);
//			arrow = (ImageView)findViewById(R.id.birthday_arrow);
//			arrow.setVisibility(View.GONE);
			if (getIntent().getExtras().getInt("from") == CommonConsts.FROM_MARKET || 
					getIntent().getExtras().getInt("from") == CommonConsts.FROM_INVITE) {
				btnInviteArea.setVisibility(View.VISIBLE);
				btnInvite.setVisibility(View.VISIBLE);
				btnInvite.setEnabled(true);
			}
			tvTitle.setText(getString(R.string.show_profile));
		} else {
			tvTitle.setText(getString(R.string.edit_settings));
			btnText.setText(R.string.save_status);
		}
//		btnRegister.setOnClickListener(new OnClickListener() {
//			
//			@Override
//			public void onClick(View view) {
//				getInputValues();
//				startResigterProfile(true);
//				System.out.println("ok");
//			}
//		});
	}
	public void onPause() {
		super.onPause();
		cImgSetFlag = false;
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
				imgLoader.displayImage("", photo, GgApplication.img_opt_photo);				
				photo.setImageBitmap(BitmapFactory.decodeFile(mImageCropUri.getPath()));
			}
			cImgSetFlag = true;*/
			
			String src_path = GgApplication.getInstance().getImageUri().getPath();
			mImageCropUri = Uri.fromFile(new File(src_path));
			
			if ("".equals(src_path)) break;
			
			Bitmap orgBitMap = BitmapFactory.decodeFile(src_path);
			int orgWidth = orgBitMap.getWidth();
			int orgHeight = orgBitMap.getHeight();
			
			float scaleWidth = ((float) newWidth) / orgWidth;
			float scaleHeight = ((float) newHeight) / orgHeight;
			
			Matrix matrix = new Matrix();
			matrix.postScale(scaleWidth, scaleHeight);
			
			Bitmap resizedBitmap = Bitmap.createBitmap(orgBitMap, 0, 0, orgWidth, orgHeight, matrix, true);
			
			imgLoader.displayImage("", photo, GgApplication.img_opt_photo);
			photo.setImageBitmap(resizedBitmap);
			cImgSetFlag = true;
			
			break;
		case GgApplication.PICK_FROM_ALBUM:
			Uri captureUri = data.getData();
			String realFileName = GgApplication.getInstance().getRealPathFromURI(ProfileActivity.this, captureUri);
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
						edit_photo = json_response.getString("server_file_path");
						GgApplication.getInstance().setUserPhoto(edit_photo);
			    		EditUserProfileTask task= new EditUserProfileTask(this, old_nickName, edit_nickName, edit_photo, edit_sex, edit_birthday, Integer.valueOf(edit_height), 
			    				Integer.valueOf(edit_weight), Integer.valueOf(edit_term), edit_city, edit_position, edit_playArea, edit_playDate);
			    		task.execute();
					}
				}catch (Exception e) {
						Log.d("Exception occured", e.toString());
				}
			}
			break;
		case MOHttpResponse.STATUS_FAILED:
		case MOHttpResponse.STATUS_CANCELLED:
		case MOHttpResponse.STATUS_UNKNOWN:
			Log.d("upload_response", "failed");
			if (dlg != null) {
				dlg.dismiss();
				dlg = null;
			}
			
			Toast.makeText(ProfileActivity.this, getString(R.string.img_upload_failed), Toast.LENGTH_LONG).show();
			break;
		default:
			break;
		}
	}
	
	public void onResume() {
		super.onResume();
		startAttachProfile(true);
	}
	
	public void startAttachProfile(boolean showdlg) {
		if(!NetworkUtil.isNetworkAvailable(ProfileActivity.this))
			return;
		
		if(showdlg) {
			dlg = new GgProgressDialog(ProfileActivity.this, getString(R.string.wait));
			dlg.show();
		}
		
		GetProfileTask task = new GetProfileTask(this, user_id);
		task.execute();
	}
	
	public void stopAttachProfile(String infos) {
		if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		if (StringUtil.isEmpty(infos)) {
			Toast.makeText(ProfileActivity.this, getString(R.string.none_profile_data), Toast.LENGTH_LONG).show();
			finish();
			return;
		}
		setUI(infos);
	}
	
	protected Dialog onCreateDialog(int id) {
        switch (id) {
        case 1:
            DatePickerDialog datePickerDialog = new DatePickerDialog(this, 10, mDateSetListener, 1980, 1, 1);
            DatePicker datePicker = datePickerDialog.getDatePicker();
            datePicker.setMinDate(0000000L);
            
            return datePickerDialog;
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
    private void updateDate() {
    	tvBirthday.setText(
    			new StringBuilder().append(year).append("-")
    			.append(pad(month+1)).append("-").append(pad(day)));
    	
    }
    
    private String pad(int c) {
        if (c >= 10)
            return String.valueOf(c);
        else
            return "0" + String.valueOf(c);
    }
    
    private void getInputValues(){
    	edit_nickName = etNickName.getText().toString();
    	edit_phoneNum = etPhoneNum.getText().toString();
//    	edit_pwd = tvPassword.getText().toString();
    	edit_sex = StringUtil.getSexID(tvSex.getText().toString());
    	edit_birthday = tvBirthday.getText().toString();
    	edit_height = etHeight.getText().toString();
    	edit_weight = etWeight.getText().toString();
    	edit_term = etTerm.getText().toString();
    	edit_position = StringUtil.getBinData(positionSelected);
    	edit_city = StringUtil.getCityID(tvCity.getText().toString());
    	edit_playDate = StringUtil.getBinData(dateSelected);
    }
    
    public void startResigterProfile(boolean showdlg) {
    	
    	if (StringUtil.isEmpty(edit_nickName)){
    		Toast.makeText(ProfileActivity.this, R.string.error_edit_username, Toast.LENGTH_SHORT).show();
    		etNickName.requestFocus();
    		return;
    	} else if (StringUtil.isEmpty(edit_phoneNum)) {
    		Toast.makeText(ProfileActivity.this, R.string.error_edit_phonenum, Toast.LENGTH_SHORT).show();
    		etNickName.requestFocus();
    		return;
//    	} else if (StringUtil.isEmpty(edit_pwd)) {
//    		Toast.makeText(ProfileActivity.this, R.string.error_edit_password, Toast.LENGTH_SHORT).show();
//    		return;
    	} else if (edit_sex == 0) {
    		Toast.makeText(ProfileActivity.this, R.string.error_edit_sex, Toast.LENGTH_SHORT).show();
    		return;
    	} else if (StringUtil.isEmpty(edit_birthday)) {
    		Toast.makeText(ProfileActivity.this, R.string.error_edit_birthday, Toast.LENGTH_SHORT).show();
    		return;
    	} else if (StringUtil.isEmpty(edit_height)) {
    		Toast.makeText(ProfileActivity.this, R.string.error_edit_height, Toast.LENGTH_SHORT).show();
    		return;
    	} else if(edit_height.substring(0, 1).equals("0") || (Integer.valueOf(edit_height) < 100 || Integer.valueOf(edit_height) > 250)) {
    		Toast.makeText(ProfileActivity.this, R.string.error_value_height, Toast.LENGTH_SHORT).show();
    		return;
    	} else if (StringUtil.isEmpty(edit_weight)) {
    		Toast.makeText(ProfileActivity.this, R.string.error_edit_weight, Toast.LENGTH_SHORT).show();
    		return;
    	} else if(edit_weight.substring(0, 1).equals("0") || Integer.valueOf(edit_weight) > 999) {
    		Toast.makeText(ProfileActivity.this, R.string.error_value_weight, Toast.LENGTH_SHORT).show();
    		return;
    	} else if (StringUtil.isEmpty(edit_term)) {
    		Toast.makeText(ProfileActivity.this, R.string.error_edit_term, Toast.LENGTH_SHORT).show();
    		return;
    	} else if(edit_term.substring(0, 1).equals("0") || Integer.valueOf(edit_term) > 99) {
    		Toast.makeText(ProfileActivity.this, R.string.error_value_term, Toast.LENGTH_SHORT).show();
    		return;
    	} else if (edit_position == 0) {
    		Toast.makeText(ProfileActivity.this, R.string.error_edit_position, Toast.LENGTH_SHORT).show();
    		return;
    	} else if (edit_city == 0) {
    		Toast.makeText(ProfileActivity.this, R.string.error_edit_city, Toast.LENGTH_SHORT).show();
    		return;
    	} else if (edit_playDate == 0) {
    		Toast.makeText(ProfileActivity.this, R.string.error_edit_play_date, Toast.LENGTH_SHORT).show();
    		return;
    	} else if (StringUtil.isEmpty(edit_playArea)) {
    		Toast.makeText(ProfileActivity.this, R.string.error_edit_play_area, Toast.LENGTH_SHORT).show();
    		return;
    	} else {
    		if(!NetworkUtil.isNetworkAvailable(ProfileActivity.this))
    			return;
    		
    		if(showdlg) {
    			dlg = new GgProgressDialog(ProfileActivity.this, getString(R.string.wait));
    			dlg.show();
    		}
    		
    		GgApplication.getInstance().setUserName(edit_nickName);
    		
    		if (old_nickName.equals(edit_nickName))
    			edit_nickName = "";
    		
    		if (mImageCropUri == null || StringUtil.isEmpty(mImageCropUri.getPath())) {
    			edit_photo = "";
				
	    		EditUserProfileTask task= new EditUserProfileTask(this, old_nickName, edit_nickName, edit_photo, edit_sex, edit_birthday, Integer.valueOf(edit_height), 
	    				Integer.valueOf(edit_weight), Integer.valueOf(edit_term), edit_city, edit_position, edit_playArea, edit_playDate);
	    		task.execute();
	    		return;
			}
    		
    		UserFunctions userFunctions = new UserFunctions();
			userFunctions.uploadImage(mImageCropUri.getPath(), this, 0);
    	}
    }
    
    public void stopRegisterProfile(int infos)
    {
    	if (dlg != null) {
			dlg.dismiss();
			dlg = null;
		}
		
		switch (Integer.valueOf(infos)) {
		case 0:
			Toast.makeText(ProfileActivity.this, getString(R.string.profile_update_failed), Toast.LENGTH_LONG).show();
			break;
		case 1:
			Toast.makeText(ProfileActivity.this, getString(R.string.profile_update_success), Toast.LENGTH_LONG).show();
			break;
		case 2:
			Toast.makeText(ProfileActivity.this, getString(R.string.user_name_exist), Toast.LENGTH_LONG).show();
			break;
		default:
			break;
		}
    }
	
	private void initUI() {
		etNickName = (EditText)findViewById(R.id.username);
		etPhoneNum = (TextView)findViewById(R.id.phone_num);
//		tvPassword = (TextView)findViewById(R.id.password);
//		tvPassword.setText("********");
		tvSex = (TextView)findViewById(R.id.sex);
		tvBirthday = (TextView)findViewById(R.id.birthday);
		tvBirthday.setText("1900-01-01");
		etHeight = (EditText)findViewById(R.id.height);
		etWeight = (EditText)findViewById(R.id.weight);
		etTerm = (EditText)findViewById(R.id.term);
		tvPosition = (TextView)findViewById(R.id.position);
		tvCity = (TextView)findViewById(R.id.city);
		tvPlayDate = (TextView)findViewById(R.id.play_date);
		tvPlayArea = (TextView)findViewById(R.id.play_area_profile);
		btnInvite = (Button)findViewById(R.id.btn_invite);
		btnInviteArea = findViewById(R.id.btn_invite_area);
		
		if (type == CommonConsts.SHOW_PROFILE) {
			photo.setEnabled(false);
			etNickName.setEnabled(false);
			etHeight.setEnabled(false);
			etWeight.setEnabled(false);
			etTerm.setEnabled(false);
		}
		
		InputMethodManager inputMethodManager = (InputMethodManager)getSystemService(INPUT_METHOD_SERVICE);
		inputMethodManager.hideSoftInputFromWindow(etNickName.getWindowToken(), 0);
	}
	
	private void setUI(String infos) {
		String photoURL = JSONUtil.getValue(infos, "photo_url");
		
		if (cImgSetFlag) photoURL = GgApplication.getInstance().getImageUri().toString();
		
		imgLoader.displayImage(photoURL, photo, GgApplication.img_opt_photo);
		old_nickName = JSONUtil.getValue(infos, "nick_name");
		etNickName.setText(old_nickName);
		etPhoneNum.setText(JSONUtil.getValue(infos, "phone_num"));
		if (!StringUtil.isEmpty(StringUtil.getSex(JSONUtil.getValueInt(infos, "sex")))) {
			tvSex.setText(StringUtil.getSex(JSONUtil.getValueInt(infos, "sex")));
			for (int i = 0; i < sexItem.length; i++) {
				if (sexItem[i].equals(StringUtil.getSex(JSONUtil.getValueInt(infos, "sex"))))
					sexSelected = i;
			}
		} else 
			tvSex.setText(sexItem[sexSelected]);
		if (!StringUtil.isEmpty(JSONUtil.getValue(infos, "birthday").toString()))
		{
			tvBirthday.setText(JSONUtil.getValue(infos, "birthday"));
			String[] dateArr = JSONUtil.getValue(infos, "birthday").toString().split("-");
			year = Integer.valueOf(dateArr[0]);
			month = Integer.valueOf(dateArr[1])-1;
			day = Integer.valueOf(dateArr[2]);
		}
		etHeight.setText(JSONUtil.getValue(infos, "height"));
		etWeight.setText(JSONUtil.getValue(infos, "weight"));
		etTerm.setText(JSONUtil.getValue(infos, "term"));
		if (!StringUtil.isEmpty(StringUtil.getStrFromSelValue(JSONUtil.getValueInt(infos, "position"), CommonConsts.POSITION))) {
			String pos = StringUtil.getStrFromSelValue(JSONUtil.getValueInt(infos, "position"), CommonConsts.POSITION);
			tvPosition.setText(pos);
			String[] dataArr = pos.split("\n");
			for (int i = 0; i < positionItem.length; i++) {
				for (int j = 0; j < dataArr.length; j++) {
					if (positionItem[i].equals(dataArr[j])) {
						positionSelected[i] = true;
					}
				}
			}
		}
		if (cityName.length > 0) {
			String city_name = JSONUtil.getValue(infos, "city");
			if (!StringUtil.isEmpty(city_name))
				tvCity.setText(city_name);
			city = Integer.valueOf(GgApplication.getInstance().getIDFromName(city_name,CommonConsts.CITY));
			if (city == 0) {
				citySelected = 0;
				tvCity.setText(cityName[0]);
				city = Integer.valueOf(GgApplication.getInstance().getIDFromName(cityName[0],CommonConsts.CITY));
			} else
				citySelected = StringUtil.getSelectedItem(cityName, city_name);
		} else 
			tvCity.setText(getString(R.string.none));
		
		if (!StringUtil.isEmpty(StringUtil.getStrFromSelValue(JSONUtil.getValueInt(infos, "activity_time"), CommonConsts.ACT_DAY))) {
			String pos = StringUtil.getStrFromSelValue(JSONUtil.getValueInt(infos, "activity_time"), CommonConsts.ACT_DAY);
			tvPlayDate.setText(pos);
			String[] dataArr = pos.split(", ");
			for (int i = 0; i < playDateItem.length; i++) {
				for (int j = 0; j < dataArr.length; j++) {
					if (playDateItem[i].equals(dataArr[j])) {
						dateSelected[i] = true;
					}
				}
			}
		}
		
		String[][] sub_distInfo = GgApplication.getInstance().getDistfromCity(String.valueOf(city));
		
		sub_distName = sub_distInfo[2];
		sub_distIds = sub_distInfo[0];
		if (sub_distIds.length > 0) {
			String value = "";
			distsSelected = new boolean[sub_distIds.length];
			
			if (!StringUtil.isEmpty(JSONUtil.getValue(infos, "activity_area")))
			{
				edit_playArea = JSONUtil.getValue(infos, "activity_area");
				String[] selArea = edit_playArea.split(",");
				
				for (int i = 0, cnt = 0; i < sub_distName.length; i++) {
					distsSelected[i] = false;
					for (int j = 0; j < selArea.length; j++) {
						if (sub_distIds[i].equals(selArea[j])){
							distsSelected[i] = true;
							continue;
						}
					}
					if (!distsSelected[i])
						continue;
					if (cnt != 0)
						value = value.concat(",");
					value = value.concat(sub_distName[i]);
					cnt++;
				}
			}
			
			if (!StringUtil.isEmpty(value))
				tvPlayArea.setText(value);
			else {
				tvPlayArea.setText(sub_distName[0]);
				distsSelected[0] = true;
			}
		} else 
			tvPlayArea.setText(getString(R.string.none));

	}
	
	public void showTeamMultiSelDialog() {
		final boolean[] sel_multi_club;
				
		clubNames = myClubData.getOwnerClubNames();
		clubIds = myClubData.getOwnerClubIDs();
		
		if (clubIds.length == 0)
			return;
		
		if (clubIds.length > 1) {
			sel_multi_club = new boolean[clubNames.length];
			for (int i = 0; i < clubNames.length; i++)
				sel_multi_club[i] = false;
			alertDialog = new AlertDialog.Builder(this)
			.setTitle(R.string.select_club)
			.setCancelable(true)
			.setMultiChoiceItems(clubNames, sel_multi_club, new DialogInterface.OnMultiChoiceClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which, boolean isChecked) {
					sel_multi_club[which] = isChecked;								
				}
			}).setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int item) {
					multi_sel_clubs = "";
					for (int i = 0, count = 0; i < clubIds.length; i++ ){
						if (!sel_multi_club[i])
							continue;
						if (count != 0)
							multi_sel_clubs = multi_sel_clubs.concat(",");
						multi_sel_clubs = multi_sel_clubs.concat(String.valueOf(clubIds[i]));
						count++;
					}
					startSendInvReq(true);
				}
			}).create();

			alertDialog.show();
			
		} else {
			multi_sel_clubs = String.valueOf(clubIds[0]);
			startSendInvReq(true);
		}
		
	}
	
	public void stopSendInvReq(int result) {
		if (dlg != null){
			dlg.dismiss();
			dlg = null;
		}
		if (result == 1 ) 
			Toast.makeText(this, R.string.invitatoin_succeed, Toast.LENGTH_SHORT).show();
		 else if (result == 2)
			Toast.makeText(this, R.string.invitatoin_exist, Toast.LENGTH_SHORT).show();
		 else if (result == 3)
			Toast.makeText(this, R.string.invite_game_already_member, Toast.LENGTH_SHORT).show();
		 else 
			Toast.makeText(this, R.string.invitatoin_reject, Toast.LENGTH_SHORT).show();
	}
	
	public void startSendInvReq(boolean showdlg) {
		if(!NetworkUtil.isNetworkAvailable(this))
			return;
		
		if (showdlg) {
			dlg = new GgProgressDialog(this, this.getString(R.string.wait));
			dlg.show();
		}
		
		Object[] param = new Object[2];
		param[0] = multi_sel_clubs;
		param[1] = user_id;
		
		SendInvReqTask task = new SendInvReqTask(ProfileActivity.this, param, PROFILE_ACTIVITY_FLAG);
		task.execute();
	}
}
