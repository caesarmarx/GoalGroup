package com.goalgroup.http.base;

import java.net.URLEncoder;
import java.util.ArrayList;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;

import com.goalgroup.constants.AddrConst;
import com.goalgroup.utils.StringUtil;

public abstract class GoalGroupHttpPost {
	
	private final String BASE_URL = "http://" + AddrConst.WEB_SERVER_ADDR + ":9600/goalsrv/api";
	protected int TIME_OUT = 15000;
	
	protected HttpPost request;
	protected HttpResponse response;
	protected ArrayList<BasicNameValuePair> post_params;
	protected String result;
	protected byte[] byRequest;
	
	public GoalGroupHttpPost() {
		request = new HttpPost(BASE_URL);
		post_params = new ArrayList<BasicNameValuePair>();
	}
	
	public abstract boolean run();
	public abstract void setParams(Object... params);
	
	protected void postExecute() throws Exception {
		for (int i=0;i<post_params.size();i++) {
			URLEncoder.encode(post_params.get(i).getValue(), HTTP.UTF_8);
		}
		
		request.setEntity(new UrlEncodedFormEntity(post_params, HTTP.UTF_8));
				
		HttpClient httpclient = new DefaultHttpClient();
		HttpParams basicparams = httpclient.getParams();
		HttpConnectionParams.setConnectionTimeout(basicparams, TIME_OUT);
		HttpConnectionParams.setSoTimeout(basicparams, TIME_OUT);
		response = httpclient.execute(request);
	}
	
	protected void getResult() throws Exception {
		if (response.getStatusLine().getStatusCode() != 200) {
			throw new Exception();
		}
		
		result = EntityUtils.toString(response.getEntity(), "UTF-8");
		if (StringUtil.isEmpty(result)) {
			throw new Exception();
		}
		
		return;
	}
}
