
package com.goalgroup.chat.io.socket.util;


import java.net.MalformedURLException;

import org.json.JSONException;
import org.json.JSONObject;

import android.R.bool;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import com.goalgroup.chat.io.socket.IOAcknowledge;
import com.goalgroup.chat.io.socket.IOCallback;
import com.goalgroup.chat.io.socket.SocketIO;
import com.goalgroup.chat.io.socket.SocketIOException;


public class SocketIOManager implements IOCallback {
	
    static final String TAG = SocketIOManager.class.getSimpleName();

    private static Handler sHandler = null;
    private static SocketIO mSocket = null;

    public SocketIOManager(final Handler handler) {
        sHandler = handler;
    }

    public SocketIO connect(String url) {
        if (mSocket != null) {
            return mSocket;
        }
        try {
            mSocket = new SocketIO(url);
            mSocket.connect(this);
        } catch (MalformedURLException e) {
            // TODO Auto-generated catch block
        	 e.printStackTrace();
        }
        return mSocket;
    }

    public void disconnect() {
        if (mSocket != null) {
            mSocket.disconnect();
            mSocket = null;
        }
    }

    private boolean isHandler() {
        return sHandler != null ? true : false;
    }

    @Override
    public void onDisconnect() {
        Log.i(TAG, "Connection terminated.");
        if (isHandler()) {
            Message msg = sHandler.obtainMessage(SOCKETIO_DISCONNECT);
            sHandler.sendMessage(msg);
        }
    }

    @Override
    public void onConnect() {
        Log.i(TAG, "Connection established");
        if (isHandler()) {
            Message msg = sHandler.obtainMessage(SOCKETIO_CONNECT);
            sHandler.sendMessage(msg);
        }
    }
    
    public boolean onConnectState() {
    	if (mSocket == null)
    		return false;
    	try {
        	return mSocket.isConnected();
		} catch (Exception e) {
			// TODO: handle exception
			return false;
		}
    }

    @Override
    public void onMessage(String data, IOAcknowledge ack) {
        Log.i(TAG, "Server said: " + data);
        if (isHandler()) {
            Message msg = sHandler.obtainMessage(SOCKETIO_MESSAGE, data);
            sHandler.sendMessage(msg);
        }
    }

    @Override
    public void onMessage(JSONObject json, IOAcknowledge ack) {
        Log.i(TAG, "Server said:" + json.toString());
        if (isHandler()) {
            Message msg = sHandler.obtainMessage(SOCKETIO_JSON_MESSAGE, json.toString());
            sHandler.sendMessage(msg);
        }
    }

    @Override
    public void on(String event, IOAcknowledge ack, Object... args) {
        Log.i(TAG, "Server triggered event '" + event + "'");
        JSONObject json = null;
        if (event.equals("updatechat")) {
        	json = (JSONObject)args[0];
        	try {
				json.put("event", "updatechat");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            onMessage(json, null);
        }
        
        if (event.equals("update_img_chat")) {
			json = (JSONObject) args[0];
			try {
				json.put("event", "update_img_chat");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			onMessage(json, null);
		}
        
        if(event.equals("update_audio_chat")) {
        	json = (JSONObject) args[0];
        	try {
        		json.put("event", "update_audio_chat");
        	} catch(JSONException e) {
        		e.printStackTrace();
        	}
        	onMessage(json, null);
        }
        
        if (event.equals("register_response")) {
        	json = (JSONObject)args[0];
        	try {
				json.put("event", "register_response");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            onMessage(json, null);
        }
        
        if (event.equals("login_response")) {
        	json = (JSONObject)args[0];
        	try {
				json.put("event", "login_response");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            onMessage(json, null);
        }
        
        if (event.equals("get_chathistory_response")) {
        	json = (JSONObject)args[0];
        	try {
        		json.put("event", "get_chathistory_response");
        	} catch (JSONException e) {
        		// TODO Auto-generated catch block
        		e.printStackTrace();
        	}
        	onMessage(json, null);
        }
        
        if (event.equals("room_in_response")) {
        	json = (JSONObject) args[0];
        	try {
				json.put("event", "room_in_response");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            onMessage(json, null);
        }
        
        if (event.equals("room_out_response")) {
        	json = (JSONObject) args[0];
        	try {
				json.put("event", "room_out_response");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            onMessage(json, null);
        }
    }

    @Override
    public void onError(SocketIOException socketIOException) {
        Log.i(TAG, "an Error occured");
        if (isHandler()) {
            Message msg = sHandler.obtainMessage(SOCKETIO_ERROR);
            sHandler.sendMessage(msg);
        }
        socketIOException.printStackTrace();
    }

    public static final int SOCKETIO_DISCONNECT = 0;
    public static final int SOCKETIO_CONNECT = 1;
    public static final int SOCKETIO_HERTBEAT = 2;
    public static final int SOCKETIO_MESSAGE = 3;
    public static final int SOCKETIO_JSON_MESSAGE = 4;
    public static final int SOCKETIO_EVENT = 5;
    public static final int SOCKETIO_ACK = 6;
    public static final int SOCKETIO_ERROR = 7;
    public static final int SOCKETIO_NOOP = 8;
}
