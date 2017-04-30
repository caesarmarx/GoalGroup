/**
 * 
 */
package com.gauss.recorder;

import java.io.File;

import com.gauss.speex.encode.SpeexDecoder;

/**
 * @author Gauss
 * 
 */
public class SpeexPlayer {
	private String fileName = null;
	private SpeexDecoder speexdec = null;
	private boolean isPlay = false;
	private Thread playThread = null;
	
	public boolean Isplaying() {
		return isPlay;
	}

	public SpeexPlayer(String fileName) {

		this.fileName = fileName;
		System.out.println(this.fileName);
		try {
			speexdec = new SpeexDecoder(new File(this.fileName));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void stopPlay() {
		if (playThread != null && playThread.isAlive())
			playThread.interrupt();
		
		playThread = null;
		isPlay = false;
	}

	public void startPlay() {
		RecordPlayThread rpt = new RecordPlayThread();

		stopPlay();
		
		playThread = new Thread(rpt);
		playThread.start();
		
		isPlay = true;
	}

	class RecordPlayThread extends Thread {

		public void run() {
			try {
				if (speexdec != null)
					speexdec.decode();

			} catch (Exception t) {
				t.printStackTrace();
			} finally {
				isPlay = false;
			}
		}
	};
}
