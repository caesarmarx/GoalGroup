/**
 * Interface that HTTP requester should implement
 * 
 * @created 2010.07.16
 * @version 1.0
 */

package com.goalgroup.chat.imageupload;

public interface MOHttpRequester {

	/**
	 * Callback function to be called by HTTP Client
	 * 
	 * @param req	HTTP response to be passed by HTTP Client
	 * @return void
	 */
	public void callback(MOHttpResponse res);
}