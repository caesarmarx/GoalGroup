/**
 * This class implements the structure of HTTP response
 * 
 * @created 2010.07.16
 * @version 1.0
 */

package com.goalgroup.chat.imageupload;

public class MOHttpResponse {

	/**
	 * Constant that indicate the unknown error status
	 */
	public static final int STATUS_UNKNOWN = 0;

	/**
	 * Constant that indicate the status that is cancelled by HTTP requester
	 */
	public static final int STATUS_CANCELLED = 1;

	/**
	 * Constant that indicate the status that is failed to process HTTP request due to connection fail or read timeout etc.
	 */
	public static final int STATUS_FAILED = 2;	

	/**
	 * Constant that indicate the success of HTTP request
	 */
	public static final int STATUS_SUCCESS = 3;

	/**
	 * Constant that indicate error status due to OOM, informal HTTP request etc.
	 */
	public static final int STATUS_ERROR = 4;

	/**
	 * Constant to indicate that there is no SDCard to save HTTP response
	 */
	public static final int STATUS_NO_SDCARD = 5;

	/**
	 * Constant to indicate that the space of SDCard to save HTTP response is low
	 */
	public static final int STATUS_LOW_SPACE = 6;
	
	/**
	 * Constant to indicate that HTTP response is saved to memory
	 */
	private static final int MEMORY_DATA = 0;

	/**
	 * Constant to indicate that HTTP response is saved to file
	 */
	private static final int FILE_DATA = 1;
	
	/**
	 * Status code of HTTP response
	 */
	private int pri_status = STATUS_UNKNOWN;
	
	/**
	 * Filename to save HTTP response
	 */
	private String pri_dataFile;
	
	/**
	 * HTTP response data
	 */
	private byte[] pri_data = null;
	
	private String priDataStr = null;

	/**
	 * Error message of HTTP response
	 */
	private String pri_errMsg;

	/**
	 * Field to indicate that HTTP response is saved to memory or file
	 */
	private int pri_dataFormat = MEMORY_DATA;

	/**
	 * Key of HTTP request relative to this HTTP response
	 */
	private int pri_key;

	/**
	 * Setter of HTTP response status
	 * 
	 * @param status	STATUS code
	 * @return void
	 */
	public void setStatus(int status){
		pri_status = status;
	}

	/**
	 * Getter of HTTP response status
	 * 
	 * @return	STATUS code
	 */
	public int getStatus(){
		return pri_status;
	}

	/**
	 * Setter of filename to save HTTP response
	 * @param fileName	Filename to save HTTP response
	 * @return void
	 */
	public void setResultFile(String fileName){
		pri_dataFile = fileName;
		pri_dataFormat = FILE_DATA;
	}

	/**
	 * Getter of filename to save HTTP response
	 * 
	 * @return	Filename to save HTTP response
	 */
	public String getResultFile(){
		return pri_dataFile;
	}

	/**
	 * Setter of HTTP response data
	 * 
	 * @param data	HTTP response data
	 * @return void
	 */
	public void setResultData(byte[] data){
		pri_data = data;
		pri_dataFormat = MEMORY_DATA;
	}

	/**
	 * Getter of HTTP response data
	 * 
	 * @return	HTTP response data
	 */
	public byte[] getResultData(){
		return pri_data;
	}

	public void setResultDataString(String data) {
		priDataStr = data;
	}
	
	public String getResultDataString() {
		return priDataStr;
	}
	
	/**
	 * Setter of error message of HTTP response
	 * 
	 * @param msg	Error message
	 * @return void
	 */
	public void setErrorMsg(String msg){
		pri_errMsg = msg;
	}

	/**
	 * Getter of error message of HTTP response
	 * 
	 * @return	Error message of HTTP response
	 */
	public String getErrorMsg(){
		return pri_errMsg;
	}

	/**
	 * Setter of data format of HTTP response
	 * 
	 * @param format	Data format of HTTP response
	 */
	public void setDataFormat(int format){
		pri_dataFormat = format;
	}

	/**
	 * Check whether HTTP response is saved to memory
	 * 
	 * @return	If it's so, true. Otherwise, false.
	 */
	public boolean isMemoryData(){
		if (pri_dataFormat == MEMORY_DATA)
			return true;
		else
			return false;
	}

	/**
	 * Setter of HTTP response key
	 * 
	 * @param key	HTTP response key relative to HTTP request
	 * @return void
	 */
	public void setKey(int key){
		pri_key = key;
	}

	/**
	 * Getter of HTTP response key
	 * 
	 * @return	HTTP response key
	 */
	public int getKey(){
		return pri_key;
	}

}