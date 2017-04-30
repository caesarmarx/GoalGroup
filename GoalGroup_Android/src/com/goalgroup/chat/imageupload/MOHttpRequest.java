/**
 * This class implements the structur of request that is passed to HTTP client by UI
 * 
 * @since 2010.07.16
 * @version 1.0
 */

package com.goalgroup.chat.imageupload;

import java.io.UnsupportedEncodingException;
import java.util.Vector;

public class MOHttpRequest {

	/**
	 * Constant that indicate GET Method of HTTP
	 */
	public static final int GET_TYPE = 0;
	
	/**
	 * Constant that indicate POST Method of HTTP
	 */
	public static final int POST_TYPE = 1;
	
	/**
	 * Constant that indicate the string post of HTTP
	 */
	public static final int STRING_POST_TYPE = 0;
	
	/**
	 * Constant that indicate the binary post of HTTP
	 */
	public static final int BINARY_POST_TYPE = 1;
	
	/**
	 * Constant that indicate the memory output of HTTP response
	 */
	public static final int MEMORY_OUTPUT_MODE = 0;
	
	/**
	 * Constant that indicate the file output of HTTP response
	 */
	public static final int FILE_OUTPUT_MODE = 1;
	
	/**
	 * Field that indicate whether HTTP request is GET method or POST method.
	 */
	private int pri_type = GET_TYPE;
	
	/**
	 * URL of HTTP request
	 */
	private String pri_url = null;
	
	/**
	 * User Agent of HTTP request
	 */
	private String pri_userAgent = null;
	
	/**
	 * String post data that HTTP request contains
	 */
	private byte[] pri_postData = null;
	
	/**
	 * Set of binary post fields that HTTP request contains
	 */
	private Vector<MOHttpBinaryPostField> pri_binaryPostFields = null;
	
	/**
	 * Field that indicate whether the post data is the string post data or binary post data
	 */
	private int pri_postType = STRING_POST_TYPE;
	
	/**
	 * Requester of this HTTP request
	 */
	private MOHttpRequester pri_requester = null;
	
	/**
	 * Output mode of HTTP response
	 */
	private int pri_outputMode = MEMORY_OUTPUT_MODE;
	
	/**
	 * Filename that HTTP response is saved to
	 */
	private String pri_outputFile = null;
	
	/**
	 * Key to set by HTTP requester and to reflect in HTTP response
	 */
	private int pri_key;

	/**
	 * Total size of response that is currently receiving
	 */
	public long gTotalSize = 0;
	
	/**
	 * Current size of response that is currently receiving
	 */
	public long gCurrentSize = 0;
	
	/**
	 * Empty Constructor of this class 
	 */
	public MOHttpRequest() {}
	
	/**
	 * Constructor of this class (Create the object with URL and requester of HTTP request)
	 * 
	 * @param url	HTTP URL
	 * @param requester	Requester of HTTP request
	 */
	public MOHttpRequest(String url, MOHttpRequester requester){
		pri_url = url;
		pri_requester = requester;
	}

	/**
	 * Setter of GET or POST method of HTTP request
	 * 
	 * @param type	GET or POST
	 * @return void
	 */
	public void setType(int type){
		pri_type = type;
	}

	/**
	 * Check whether the HTTP request is POST method
	 * 
	 * @return	true if it is POST method, otherwise false
	 */
	public boolean isPostReq(){
		if (pri_type == POST_TYPE)
			return true;
		else
			return false;
	}

	/**
	 * Setter of HTTP URL
	 * 
	 * @param url	HTTP URL
	 * @return void
	 */
	public void setURL(String url){
		pri_url = url;
	}

	/**
	 * Getter of HTTP URL
	 * 
	 * @return	HTTP URL
	 */
	public String getURL(){
		return pri_url;
	}
	

	/**
	 * Setter of HTTP User-Agent
	 * 
	 * @param userAgent	HTTP User-Agent
	 * @return void
	 */
	public void setUserAgent(String userAgent){
		pri_userAgent = userAgent;
	}

	/**
	 * Getter of HTTP User-Agent
	 * 
	 * @return	HTTP User-Agent
	 */
	public String getUserAgent(){
		return pri_userAgent;
	}
	
	/**
	 * Setter of the string post data
	 * 
	 * @param data	String post data of HTTP request
	 * @return void
	 */
	public void setPostData(byte[] data){
		if (pri_postType == STRING_POST_TYPE) {
			pri_postData = data;
			pri_type = POST_TYPE;
		}
	}
	
	/**
	 * Setter of the string post data
	 * 
	 * @param data	String post data of HTTP request
	 * @return void
	 */
	public void setPostData(String data){
		try {
			pri_postData = data.getBytes("UTF-8");
		} catch (UnsupportedEncodingException e) {
			pri_postData = null;
		}
		pri_type = POST_TYPE;
		pri_postType = STRING_POST_TYPE;
	}
	
	/**
	 * Add one binary post field to HTTP request
	 * 
	 * @param name	Name of binary post field
	 * @param val	Value of binary post field
	 * @param mime	MIME type of binary post field
	 * @return void
	 */
	public void addBinaryPostData(String name, byte[] val, String mime) {
		if (pri_binaryPostFields == null)
			pri_binaryPostFields = new Vector<MOHttpBinaryPostField>();
		
		pri_binaryPostFields.add(new MOHttpBinaryPostField(name, val, mime));
		
		pri_type = POST_TYPE;
		pri_postType = BINARY_POST_TYPE;
	}
	
	/**
	 * Getter of binary post field set
	 * 
	 * @return	binary post field set of HTTP request
	 */
	public Vector<MOHttpBinaryPostField> getBinaryPostFields() {
		return pri_binaryPostFields;
	}
	
	/**
	 * Getter of string post data of HTTP request
	 * 
	 * @return	string post data
	 */
	public byte[] getPostData(){
		return pri_postData;
	}

	/**
	 * Register the specific requester to this HTTP request
	 * 
	 * @param requester	Requester of HTTP request
	 * @return void
	 */
	public void registerRequester(MOHttpRequester requester){
		pri_requester = requester;
	}

	/**
	 * Getter of HTTP requester
	 * 
	 * @return	Requester of this HTTP request
	 */
	public MOHttpRequester requester(){
		return pri_requester;
	}

	/**
	 * Setter of output mode of HTTP response
	 * 
	 * @param mode	Output mode
	 * @return void
	 */
	public void setOutputMode(int mode){
		pri_outputMode = mode;
	}

	/**
	 * Check whether HTTP response should be saved to file
	 * 
	 * @return	If it's so, true. Otherwise, false
	 */
	public boolean isFileOutputMode(){
		if (pri_outputMode == FILE_OUTPUT_MODE)
			return true;
		else
			return false;
	}

	/**
	 * Setter of post data type
	 * 
	 * @param type	Type of Post data
	 */
	public void setPostType(int type){
		pri_postType = type;
	}

	/**
	 * Check whether the post data is binary post data
	 * 
	 * @return	If it's so, true. Otherwise, false.
	 */
	public boolean isBinaryPost(){
		if (pri_postType == BINARY_POST_TYPE)
			return true;
		else
			return false;
	}

	/**
	 * Check whether this HTTP request is HTTPS (Check whether HTTP URL starts with "https://")
	 * 
	 * @return	If it's so, true. Otherwise, false
	 */
	public boolean isHttpsRequest(){
		if (pri_url != null && pri_url.startsWith("https://"))
			return true;
		else
			return false;
	}

	/**
	 * Setter of filename to save the HTTP response
	 * 
	 * @param fileName	Filename of save HTTP response
	 * @return void
	 */
	public void setOutputFile(String fileName){
		pri_outputFile = fileName;
		pri_outputMode = FILE_OUTPUT_MODE;
	}

	/**
	 * Getter of filename to save HTTP response
	 * 
	 * @return	Filename to save HTTP response
	 */
	public String getOutputFile(){
		return pri_outputFile;
	}

	/**
	 * Setter of key of HTTP request
	 * 
	 * @param key	Identifier to reflect to HTTP response
	 * @return void
	 */
	public void setKey(int key){
		pri_key = key;
	}

	/**
	 * Getter of key of HTTP request
	 * 
	 * @return	Key of HTTP request
	 */
	public int getKey(){
		return pri_key;
	}

}