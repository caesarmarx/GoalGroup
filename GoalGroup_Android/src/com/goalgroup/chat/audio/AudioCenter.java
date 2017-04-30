package com.goalgroup.chat.audio;

import android.os.AsyncTask;

import com.gauss.recorder.SpeexPlayer;
import com.gauss.recorder.SpeexRecorder;
import com.goalgroup.chat.component.ChatEngine;
import com.goalgroup.ui.ChatActivity;
import com.goalgroup.utils.FileUtil;
import com.smaxe.uv.client.microphone.AbstractMicrophone;

public class AudioCenter extends AbstractMicrophone {
	
	private boolean isPublish, isPlaying;
	
	private SpeexRecorder recorderInstance = null;
	private SpeexPlayer recorderPlayer = null;
	private Thread recordThread = null;
	
	private AynscPlayAudixFile playFileTask = null;
	
	/**
	 * 록음파일을 작성하는 함수
	 * @param filename
	 */
	public void publishSpeexAudioFile(final String filename) {
		if (recorderInstance != null && recorderInstance.isRecording()) {
			try {
				recorderInstance.setRecording(false);
			} catch (IllegalStateException e) {
				e.getMessage();
			} finally {
				recorderInstance = null;
				recordThread = null;	
			}
		}
		
		recorderInstance = new SpeexRecorder(FileUtil.getFullPath(filename));
		recordThread = new Thread(recorderInstance);
		recordThread.start();
		
		recorderInstance.setRecording(true);
	}
	
	public void stopPublish() {
		isPublish = false;
		
		if (recorderInstance != null) {
			try {
				recorderInstance.setRecording(false);
			}
			catch (IllegalStateException e) {
				e.getMessage();
			}
			finally {
				recorderInstance = null;
				recordThread = null;
			}
		}		
	}
	
	/**
	 * 음성메일을 재생하는 함수
	 * @param filename			음성메일의 이름
	 */
	public void playSpeexAudioFile(final String filename) {
		if (playFileTask == null) {
			playFileTask = new AynscPlayAudixFile();
		} else {
			playFileTask.cancel(true);
			playFileTask = null;
			
			playFileTask = new AynscPlayAudixFile();
		}
		
		playFileTask.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, filename);
	}
	
	public class AynscPlayAudixFile extends AsyncTask<String, String, String> {
		
		@Override
	    protected void onPreExecute() {
	        super.onPreExecute();
	    }
		
		@Override
        protected String doInBackground(String... params) {
			
			recorderPlayer = new SpeexPlayer(FileUtil.getFullPath(params[0]));
			recorderPlayer.startPlay();
			
			while (recorderPlayer.Isplaying() && !this.isCancelled()) {
				ChatActivity.m_vMailPlaying = recorderPlayer.Isplaying();
				try {
					Thread.sleep(100);	
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
			
			if (recorderPlayer.Isplaying())
				recorderPlayer.stopPlay();
			
			ChatActivity.m_vMailPlaying = recorderPlayer.Isplaying();
			
			return "";
    	}
		
		@Override
        protected void onPostExecute(String result) {
            super.onPostExecute(result);
        }
         
        @Override
        protected void onCancelled() {
            super.onCancelled();
        }
	}
}
