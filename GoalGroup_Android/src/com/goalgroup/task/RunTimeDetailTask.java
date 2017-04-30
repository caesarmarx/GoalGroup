package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.http.RunTimeDetailHttp;

public class RunTimeDetailTask extends AsyncTask<String, String, String> {
		
		private RunTimeDetailHttp post;
		
		public RunTimeDetailTask() {
			
		}
		@Override
		protected void onPreExecute() {
			super.onPreExecute();
		}
		
		@Override
		protected String doInBackground(String... params) {
			post = new RunTimeDetailHttp();
			post.setParams(params);
			post.run();
			return null;
		}
		
		@Override
		protected void onPostExecute(String result) {
			super.onPostExecute(result);
		}
	}