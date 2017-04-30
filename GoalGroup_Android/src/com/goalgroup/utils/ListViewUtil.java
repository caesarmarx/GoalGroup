package com.goalgroup.utils;

import android.content.res.Resources;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListAdapter;
import android.widget.ListView;

public class ListViewUtil {
	
	public static void getListViewSize(ListView list_view) {
		ListAdapter list_adapter = list_view.getAdapter();
		
		if (list_adapter == null) return;
		
		// calculate total list height.
		int totalHeight = 0;
        for (int size = 0; size < list_adapter.getCount(); size++) {
            View listItem = list_adapter.getView(size, null, list_view);
            listItem.measure(0, 0);
            totalHeight += listItem.getMeasuredHeight();
        }

		ViewGroup.LayoutParams params = list_view.getLayoutParams();
	
		params.height = totalHeight + (list_view.getDividerHeight() * (list_adapter.getCount() - 1));
		list_view.setLayoutParams(params);
		list_view.requestLayout();
	}
	
	public static int dp2px(int dp, Resources resource) {
		return (int) TypedValue.applyDimension(
					TypedValue.COMPLEX_UNIT_DIP, 
					dp,
					resource.getDisplayMetrics());
	}
}
