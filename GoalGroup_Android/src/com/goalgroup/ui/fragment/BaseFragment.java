package com.goalgroup.ui.fragment;

import android.support.v4.app.Fragment;
import android.widget.LinearLayout;

public class BaseFragment extends Fragment {
	private LinearLayout popupMenu;
	
	public LinearLayout getPoupMenu() {
		return popupMenu;
	}
	
	public void setPopupMenu(LinearLayout popupMenu) {
		this.popupMenu = popupMenu;
	}
}
