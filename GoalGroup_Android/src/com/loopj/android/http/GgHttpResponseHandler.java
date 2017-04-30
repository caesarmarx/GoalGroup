package com.loopj.android.http;

import java.io.IOException;

import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;

public class GgHttpResponseHandler extends AsyncHttpResponseHandler {
	public GgHttpResponseHandler() {
	}
	
	public void onSuccess(byte[] binaryData) {
	}
	
	public void onSuccess(int statusCode, byte[] binaryData) {
		onSuccess(binaryData);
	}
	
	public void onSuccess(int statusCode, Header[] headers, byte[] binaryData) {
		onSuccess(statusCode, binaryData);
	}
	
	public void onFailure(int statusCode, Header[] headers, byte[] binaryData, Throwable error) {
		onFailure(statusCode, error, null);
	}
	
	public final void sendResponseMessage(HttpResponse response) throws IOException {
		StatusLine status = response.getStatusLine();
		super.sendResponseMessage(response);
	}
}
