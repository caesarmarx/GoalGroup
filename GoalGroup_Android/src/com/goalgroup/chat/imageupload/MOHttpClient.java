/**
 * This class implements HTTP client that process the HTTP requests from UI
 * 
 * @created 2010.07.16
 * @version 1.0
 */

package com.goalgroup.chat.imageupload;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.Random;
import java.util.Vector;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.SingleClientConnManager;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.util.ByteArrayBuffer;

import android.os.Environment;
import android.os.StatFs;
import android.util.Log;

public class MOHttpClient {
	
	/**
	 * User-Agent that used by HTTP Client 
	 */
	private static final String USER_AGENT = "iFMW_Android";
	
	/**
	 * If-Range Header
	 */
	private static final String IF_RANGE_HEADER = "If-Range";
	
	/**
	 * Range Header
	 */
	private static final String RANGE_HEADER = "Range";
	
	/**
	 * ETag Header
	 */
	private static final String ETAG_HEADER = "ETag";
	
	/**
	 * Field to represent whether HTTP Client is idle.
	 */
	private boolean pri_isIdle = true;
	
	/**
	 * Thread to process HTTP request
	 */
	private MOHttpProcessThread pri_procThread = null;
	
	/**
	 * Flag to represent that the processing of HTTP request should be cancelled 
	 */
	private boolean pri_isCancel = false;
	
//	/**
//	 * Key that identify the requests processing by GHTTP
//	 */
//	private int pri_reqKey = 0;
//
//	/**
//	 * Lock for GHTTP using
//	 */
//	private static Object gLock = new Object();

	private static final String LOG_TAG = "ifmwHttpClient";
	
	private int uploadedIdx = 0;
	
	private int uploadType = -1;
	
	/**
	 * Constructor of this class (Create the process thread and start it.)
	 */
	public MOHttpClient(int idx) {
		pri_procThread = new MOHttpProcessThread();
		pri_procThread.start();
		this.uploadedIdx = idx;
	}
	
	/**
	 * Receive the HTTP request from UI (If HTTP Client is idle, receive the HTTP request and pass it to process thread. Otherwise, reject to receive)
	 * 
	 * @param req	HTTP request
	 * @return If the HTTP request is received by HTTP Client, true. Otherwise, false.
	 */
	public synchronized boolean receiveRequest(MOHttpRequest req, int type){
		boolean ret = false;

		Log.d("MoHttpClient Class", "in the receive request func");
		uploadType = type;
		if (pri_isIdle) {
			
			Log.d("MoHttpClient Class", "if idle , register the request");
			
			pri_isCancel = false;
			pri_isIdle = false;
			pri_procThread.newRequest(req);
			ret = true;
			
			req.gCurrentSize = 0;
		}

		Log.v(LOG_TAG, "url->" + req.getURL());
		if (req.getPostData() != null)
		{
			try {
				Log.v(LOG_TAG, "post data->" + new String(req.getPostData(), "UTF-8"));
			} catch (UnsupportedEncodingException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		return ret;
	}

	/**
	 * Cancel the current process of HTTP Client
	 * 
	 * @return void
	 */
	public void cancelRequest(){
		pri_isCancel = true;
		pri_procThread.cancelProcess();
//		fhcStopProcess(pri_reqKey);
	}
	
	/**
	 * Destroy this HTTP Client (Stop process thread)
	 */
	public void destroy() {
		try {
			pri_procThread.destroy();
		} catch (Exception e) {
			Log.e("HC", "Exception: " + e.getMessage());
		}
	}
	
	/**
	 * This class implements the process thread of HTTP Client
	 * 
	 * @since 2010.07.16
	 * @version 1.0
	 */
	class MOHttpProcessThread extends Thread {

		/**
		 * HTTP Connection timeout constant
		 */
		private static final int HTTP_CONNECTION_TIMEOUT = 300000;

		/**
		 * HTTP read-timeout constant
		 */
		private static final int HTTP_SO_TIMEOUT = 300000;

		/**
		 * Read unit from Web server
		 */
		private static final int MAX_READ_UNIT = 4096;

		/**
		 * HTTP request processing
		 */
		private MOHttpRequest pri_request = null;
		
		/**
		 * System-level HTTP client to process HTTP request
		 */
		private DefaultHttpClient pri_httpClient = null;
		
		/**
		 * Flag to indicate that the current processing should be stopped
		 */
		private boolean pri_isStop = false;

		/**
		 * Empty constructor of this class
		 */
		public MOHttpProcessThread() {}
		
		/**
		 * Set the new HTTP request that the process thread should process.
		 * 
		 * @param req	HTTP request to be processed by this thread
		 * @return void
		 */
		public void newRequest(MOHttpRequest req) {
			Log.d("MoHttpClient Class", "request is registered");
			pri_request = req;
		}

		/**
		 * Processing part of this thread (Monitor that the new HTTP request exists and if it exists, process it)
		 */
		public void run(){
			while (!pri_isStop) {
				if (pri_request == null) {
					try {
						Thread.sleep(100);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					
					continue;
				}
				
//				if (pri_request.isHttpsRequest())
					procesHttps();
//				else
//					processHttp();
			}
			
		}
		
		/**
		 * Stop this thread
		 * 
		 * @return void
		 */
		public void destroy() {
			pri_isStop = true;
		}
		
		/**
		 * Cancel the process of HTTP request that this thread is processing currently (Disconnect the HTTP connection)
		 * 
		 * @return void
		 */
		public void cancelProcess() {
			try {
				if (pri_httpClient != null)
					pri_httpClient.getConnectionManager().shutdown();
			} catch (Exception e) {}
		}
		
		/**
		 * Process HTTPS request (Connect with HTTP URL to web server, and read HTTP response. 
		 * After processing, pass the result using the callback function of HTTP requester)
		 * 
		 * @return void
		 */
		private void procesHttps(){
			
			Log.d("MoHttpClient Class", "processing the http request");
			
			HttpResponse response;
			String tmpFileName = null;
			String etagVal = null;
			long rangeVal = 0;
			MOHttpResponse result = new MOHttpResponse();

			result.setKey(pri_request.getKey());

			try {
				BasicHttpParams httpParams = new BasicHttpParams();
				HttpConnectionParams.setConnectionTimeout(httpParams, HTTP_CONNECTION_TIMEOUT);
				HttpConnectionParams.setSoTimeout(httpParams, HTTP_SO_TIMEOUT);
				
				if (pri_request.isHttpsRequest()) {
					/* Ignore all certifications */
					TrustAllSSLSocketFactory allTruster = new TrustAllSSLSocketFactory();
					SchemeRegistry schemeRegistry = new SchemeRegistry();
					schemeRegistry.register(new Scheme ("https", allTruster, 443));
					SingleClientConnManager cm = new SingleClientConnManager(httpParams, schemeRegistry);

					pri_httpClient = new DefaultHttpClient(cm, httpParams);
				} else {
					pri_httpClient = new DefaultHttpClient(httpParams);
				}
				
			    /* Check whether there is the file to be download already */
			    if (pri_request.isFileOutputMode()) {
			    	tmpFileName = generateTmpFileName(pri_request.getOutputFile());
			    	if (tmpFileName != null) {
			    		File tmpFile = new File(tmpFileName);
			    		if (tmpFile.exists()) {
			    			String tagFileName = tmpFileName + ".etag";
			    			etagVal = readEtag(tagFileName);
			    			rangeVal = tmpFile.length();
			    		}
			    	}
			    }
			    
				if (pri_request.isPostReq()) {
					HttpPost httpPost = new HttpPost(pri_request.getURL());

					if (pri_request.getUserAgent() != null)
						httpPost.setHeader("User-Agent", pri_request.getUserAgent());
					else
						httpPost.setHeader("User-Agent", USER_AGENT);
					
					/* SET httpPost to POST data */
					if (pri_request.getPostData() != null) {
						ByteArrayEntity postEntity = new ByteArrayEntity(pri_request.getPostData());
						httpPost.setEntity(postEntity);
						
						httpPost.setHeader("Content-Type", "application/x-www-form-urlencoded");
						if (etagVal != null && rangeVal > 0) {
							httpPost.setHeader(IF_RANGE_HEADER, etagVal);
							httpPost.setHeader(RANGE_HEADER, "bytes=" + rangeVal + "-");
						}
						httpPost.setEntity(postEntity);
					} else if (pri_request.isBinaryPost()) {
						
						Log.d("processing the request", "if post is binary post");
						
						Random bNumber = new Random();
						String BoundaryStr = "-----------------"+bNumber.nextInt(50000000);
						String CTypeStr = "";
						if(uploadType == 1) {
							CTypeStr = "multipart/form-data; type=img; boundary="+BoundaryStr + "; server_idx="+uploadedIdx;
						} else if(uploadType == 2) {
							CTypeStr = "multipart/form-data; type=aud; boundary="+BoundaryStr + "; server_idx="+uploadedIdx;
						}
						byte[] postData = getBinaryPostEntityData(pri_request.getBinaryPostFields(), BoundaryStr);
						ByteArrayEntity postEntity = new ByteArrayEntity(postData);
						httpPost.setEntity(postEntity);

						httpPost.setHeader("Content-Type", CTypeStr);
						httpPost.setHeader("Connection", "keep-alive");
//						httpPost.setHeader("Content-Length", String.valueOf(postData.length));
					}

					response = pri_httpClient.execute(httpPost);
				} else {
					HttpGet httpGet = new HttpGet(pri_request.getURL());

					if (pri_request.getUserAgent() != null)
						httpGet.setHeader("User-Agent", pri_request.getUserAgent());
					else
						httpGet.setHeader("User-Agent", USER_AGENT);
					
					if (etagVal != null && rangeVal > 0) {
						httpGet.setHeader(IF_RANGE_HEADER, etagVal);
						httpGet.setHeader(RANGE_HEADER, "bytes=" + rangeVal + "-");
					}
					
					response = pri_httpClient.execute(httpGet);
				}

				StatusLine status = response.getStatusLine();
				int statusCode = status.getStatusCode();
				
				Log.d("response received", "code is " + statusCode);
				
				if (statusCode == 200 || statusCode == 206) {
					HttpEntity httpEntity = response.getEntity();
					InputStream httpIS = httpEntity.getContent();

					long contentLen = httpEntity.getContentLength();
					
//					if (contentLen < 0) {
//						result.setStatus(MOHttpResponse.STATUS_FAILED);
//						result.setErrorMsg("Unknown content length");
						
						String resStr = MOUtils.convertStreamToString(httpIS);
						
						result.setStatus(MOHttpResponse.STATUS_SUCCESS);
						result.setResultDataString(resStr);
//					} else {
//						int readLen = 0;
//						long totalReadLen = 0;
//
//						if (!pri_request.isFileOutputMode()) {
//							pri_request.gTotalSize = contentLen;
//
//							byte[] buffer = new byte[(int)contentLen];
//
//							do {
//								readLen = httpIS.read(buffer, (int)totalReadLen, MAX_READ_UNIT);
//								if (readLen > 0) {
//									totalReadLen += readLen;
//									pri_request.gCurrentSize = totalReadLen;
//								}
//								try {
//									Thread.sleep(50);
//								} catch (Exception e) { }
//							} while ( readLen != -1 && !pri_isCancel);
//
//							if (contentLen != totalReadLen) {
//								if (pri_isCancel) {
//									result.setStatus(MOHttpResponse.STATUS_CANCELLED);
//								} else {
//									result.setStatus(MOHttpResponse.STATUS_FAILED);
//									result.setErrorMsg("Incomplete read");
//								}
//							} else {
//								result.setStatus(MOHttpResponse.STATUS_SUCCESS);
//								result.setResultData(buffer);
//							}
//						} else {
//							String state = Environment.getExternalStorageState();
//							long bytesAvailable = -1;
//							
//							if (Environment.MEDIA_MOUNTED.equals(state)) {
//								// get free size from sdcard 
//								StatFs stat = new StatFs(Environment.getExternalStorageDirectory().getPath());
//								bytesAvailable =(long) stat.getFreeBlocks()* (long)stat.getBlockSize();
//							}
//							
//							if (bytesAvailable >= contentLen) {
//								File resultFile = new File(tmpFileName);
//								FileOutputStream fileOutputStream = null;
//								
//								writeEtag(response, tmpFileName + ".etag");
//								
//								if (statusCode == 200) {
//									fileOutputStream = new FileOutputStream(resultFile, false);
//									pri_request.gTotalSize = contentLen;
//									pri_request.gCurrentSize = 0;
//								} else { // statusCode is 206
//									fileOutputStream = new FileOutputStream(resultFile, true);
//									pri_request.gCurrentSize = resultFile.length();
//									pri_request.gTotalSize = contentLen + pri_request.gCurrentSize;
//								}
//									
//								byte[] buffer = new byte[MAX_READ_UNIT];
//
//								do {
//									readLen = httpIS.read(buffer);
//									if (readLen > 0) {
//										fileOutputStream.write(buffer, 0, readLen);
//										totalReadLen += readLen;
//										pri_request.gCurrentSize += readLen;
//									}
//									try {
//										Thread.sleep(50);
//									} catch (Exception e) { }
//								} while (readLen != -1 && !pri_isCancel);
//
//								if (contentLen != totalReadLen) {
//									if (pri_isCancel) {
//										result.setStatus(MOHttpResponse.STATUS_CANCELLED);
//									} else {
//										result.setStatus(MOHttpResponse.STATUS_FAILED);
//										result.setErrorMsg("Incomplete read");
//									}
//
//									fileOutputStream.close();
//								} else {
//									fileOutputStream.close();
//									
//									if (renameFile(tmpFileName, pri_request.getOutputFile())) {
//										result.setStatus(MOHttpResponse.STATUS_SUCCESS);
//										result.setResultFile(pri_request.getOutputFile());
//									} else {
//										result.setStatus(MOHttpResponse.STATUS_FAILED);
//										result.setErrorMsg("Failed to rename the tmp file.");
//									}
//								}
//							} else if (bytesAvailable < 0) {
//								result.setStatus(MOHttpResponse.STATUS_NO_SDCARD);
//								result.setErrorMsg("No sdcard");
//							} else {
//								result.setStatus(MOHttpResponse.STATUS_LOW_SPACE);
//								result.setErrorMsg("Low space");
//							}
//						}
//					}
					
					httpIS.close();
				} else {
					result.setStatus(MOHttpResponse.STATUS_ERROR);
					result.setErrorMsg(status.getStatusCode() + " " + status.getReasonPhrase());
				}
				
			} catch (Exception e){
				if (pri_isCancel)
					result.setStatus(MOHttpResponse.STATUS_CANCELLED);
				else
					result.setStatus(MOHttpResponse.STATUS_FAILED);
				
				result.setErrorMsg(e.getMessage());
			} finally {
				if (pri_httpClient != null)
					pri_httpClient.getConnectionManager().shutdown();
				
				pri_httpClient = null;
			}

			MOHttpRequester requester = pri_request.requester(); 
			pri_request = null;
			pri_isIdle = true;
			
			/* Debug Info */
			if (result.getStatus() == MOHttpResponse.STATUS_SUCCESS) {
				if (result.isMemoryData()) {
					try {
					} catch (Exception e) {
						e.printStackTrace();
					}
				} else {
				}
			}
			
			String strHttpBody = "null";
			if (result.getResultData() != null)
			{
				try {
					strHttpBody = new String(result.getResultData(), "UTF-8");
				} catch (UnsupportedEncodingException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				Log.v(LOG_TAG, "result->" + strHttpBody);
			}
			requester.callback(result);
		}

		private byte[] getBinaryPostEntityData(Vector<MOHttpBinaryPostField> postFields, String BoundaryStr) {
			byte[] ret = null;
			if (postFields != null) {
				CustomByteArrayBuffer buf = new CustomByteArrayBuffer();
				byte[] file_result = null;
				String PostStr = null;
				String EndBoundary = null;
				String FilePostStr =null;

				MOHttpBinaryPostField PostData;
				
				try {
					EndBoundary = "--"+BoundaryStr+"--\r\n";
					for(int i=0; i< postFields.size(); i++){
						PostData = postFields.get(i);

						PostStr="--"+BoundaryStr+"\r\n";
						buf.append(PostStr.getBytes());

						if(PostData.getType()==null){				    	
							PostStr="Content-Disposition: form-data; name=\""+PostData.getName()+"\"\r\n\r\n";
							PostStr+=new String(PostData.getValue());
							PostStr+="\r\n";
							buf.append(PostStr.getBytes());
						}else{					  	    	
							FilePostStr = "Content-Disposition: form-data; name=\""+PostData.getName()+"\"; filename=\""+i+".png\"\r\nContent-Type: "+PostData.getType()+"\r\n\r\n";
							buf.append(FilePostStr.getBytes());
							file_result = PostData.getValue();	
							PostStr="\r\n";
							buf.append(file_result);
							buf.append(PostStr.getBytes());

							FilePostStr = null;
						}
					}
					buf.append(EndBoundary.getBytes());
					EndBoundary = null;
					
					ret = buf.toByteArray();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			return ret;
		}

//		/**
//		 * Process HTTP request (Connect with HTTP URL to web server, and read HTTP response. 
//		 * After processing, pass the result using the callback function of HTTP requester)
//		 * 
//		 * @return void
//		 */
//		private void processHttp(){
//			int res = 0;
//			int size = 0;
//			int location = 0;
//			int PostDataSize = 0;
//			int ReqKey = 0;
//			byte[] result_str= null;
//			byte[] file_result = null;
//			String PostStr = null;
//			String BoundaryStr = null;
//			String EndBoundary = null;
//			String CTypeStr = null;
//			String FilePostStr =null;
//			String tmpFileName = null;
//			
//			Random bNumber = new Random();
//			ByteArrayBuffer PostDataArray1 = null ;
//			ByteArrayBuffer PostDataArray2 = null ;
//			Vector<ifmw_HttpBinaryPostField> PostDataList = null;
//
//			ifmw_HttpResponse RespResult = new ifmw_HttpResponse();
//			ifmw_HttpBinaryPostField PostData;
//
//			RespResult.setKey(pri_request.getKey());
//			PostDataList = pri_request.getBinaryPostFields();
//
//			try {
//				if(!(PostDataList==null)){
//					size = PostDataList.size();
//					PostDataArray1 = new ByteArrayBuffer(1024);
//
//					BoundaryStr = "-----------------"+bNumber.nextInt(50000000);
//					EndBoundary = "--"+BoundaryStr+"--\r\n";
//					while(size > 0){
//						PostData = PostDataList.get(location);
//
//						PostStr="--"+BoundaryStr+"\r\n";
//						PostDataArray1.append(PostStr.getBytes(), 0, PostStr.length());
//
//
//						if(PostData.getType()==null){				    	
//							PostStr="Content-Disposition: form-data; name=\""+PostData.getName()+"\"\r\n\r\n";
//							PostStr+=new String(PostData.getValue());
//							PostStr+="\r\n";
//							PostDataArray1.append(PostStr.getBytes(), 0, PostStr.length());
//						}else{					  	    	
//							FilePostStr = "Content-Disposition: form-data; name=\""+PostData.getName()+"\"; filename=\""+location+".png\"\r\nContent-Type: "+PostData.getType()+"\r\n\r\n";
//							PostDataArray1.append(FilePostStr.getBytes(), 0, FilePostStr.length());
//							file_result = PostData.getValue();	
//							int bytearray = PostDataArray1.capacity()-PostDataArray1.length();
//							PostStr="\r\n";
//							if(file_result.length > bytearray)
//							{
//								PostDataSize = PostDataArray1.length();
//
//								PostDataArray2 = new ByteArrayBuffer(file_result.length+PostDataSize+1024);
//								PostDataArray2.append(PostDataArray1.buffer(), 0, PostDataSize);	
//								PostDataArray2.append(file_result, 0, file_result.length);
//								PostDataArray2.append(PostStr.getBytes(), 0, PostStr.length());
//
//								PostDataArray1 = PostDataArray2;
//								PostDataArray2 = null;
//
//							}else{
//								PostDataArray1.append(file_result, 0, file_result.length);
//								PostDataArray1.append(PostStr.getBytes(), 0, PostStr.length());
//
//							}
//							FilePostStr = null;
//						}
//						PostData = null;
//						location++;
//						size--;
//					}
//					PostDataArray1.append(EndBoundary.getBytes(),0, EndBoundary.length());
//					CTypeStr = "multipart/form-data; boundary="+BoundaryStr;
//					PostDataArray2 = null;
//					EndBoundary = null;
//
//				}
//
//				synchronized (gLock) {
//					ReqKey = fhcGetReqeustIndex();
//				}
//				
//				if(ReqKey >= 0)
//				{
//					if (pri_request.isFileOutputMode())
//						tmpFileName = generateTmpFileName(pri_request.getOutputFile());
//					
//					pri_reqKey = ReqKey;
//					if(!(pri_request.getURL()==null))
//					{					
//						if(pri_request.isBinaryPost())
//						{
//							if(PostDataArray1 == null ){
//								if(pri_request.isFileOutputMode())
//								{
//									res = fhcProcess(pri_request.getURL(),null,1,tmpFileName,CTypeStr,ReqKey);
//								}else{
//									res = fhcProcess(pri_request.getURL(),null,1,null,CTypeStr,ReqKey);
//								}	
//							}else{
//
//								if(pri_request.isFileOutputMode())
//								{
//									res = fhcProcess(pri_request.getURL(),PostDataArray1.toByteArray(),1,tmpFileName,CTypeStr,ReqKey);
//								}else{
//									res = fhcProcess(pri_request.getURL(),PostDataArray1.toByteArray(),1,null,CTypeStr,ReqKey);
//								}
//
//								PostDataArray1 = null;
//								CTypeStr = null;
//								BoundaryStr = null;
//
//							}
//						}else{
//							if(pri_request.isFileOutputMode())
//							{
//								res = fhcProcess(pri_request.getURL(),pri_request.getPostData(),0,tmpFileName,CTypeStr,ReqKey);
//							}else{
//								res = fhcProcess(pri_request.getURL(),pri_request.getPostData(),0,null,CTypeStr,ReqKey);
//							}						
//							CTypeStr = null;
//							BoundaryStr = null;
//						}
//
//						if(res == 0)
//						{
//							int statusCode = fhcGetStatusCode(ReqKey);
//							if (statusCode == 200) {
//								if(pri_request.isFileOutputMode())
//								{
//									if (renameFile(tmpFileName, pri_request.getOutputFile())) {
//										RespResult.setStatus(ifmw_HttpResponse.STATUS_SUCCESS);
//										RespResult.setDataFormat(ifmw_HttpRequest.FILE_OUTPUT_MODE);
//										RespResult.setResultFile(pri_request.getOutputFile());
//									} else {
//										RespResult.setStatus(ifmw_HttpResponse.STATUS_FAILED);
//										RespResult.setErrorMsg("Failed to rename the tmp file.");
//									}
//
//								}else{
//									RespResult.setStatus(ifmw_HttpResponse.STATUS_SUCCESS);
//									result_str = fhcGetBodyFromBuf(ReqKey);
//									RespResult.setResultData(result_str);
//									result_str = null;
//								}
//							} else {
//								RespResult.setStatus(ifmw_HttpResponse.STATUS_ERROR);
//								RespResult.setErrorMsg(statusCode + " " + fhcGetReasonPhrase(ReqKey));
//							}
//						} else if(res == -1) {
//							if(pri_isCancel==true){
//								RespResult.setStatus(ifmw_HttpResponse.STATUS_CANCELLED);
//							} else {
//								RespResult.setStatus(ifmw_HttpResponse.STATUS_FAILED);
//								RespResult.setErrorMsg(fhcGetErrStr(ReqKey));
//							}
//						} else if(res == -2) {
//							if(pri_isCancel==true){
//								RespResult.setStatus(ifmw_HttpResponse.STATUS_CANCELLED);
//							} else {
//								RespResult.setStatus(ifmw_HttpResponse.STATUS_FAILED);
//								RespResult.setErrorMsg(fhcGetErrStr(ReqKey));
//							}
//						}
//					}else{
//						RespResult.setErrorMsg("Please insert URL!");
//						RespResult.setStatus(ifmw_HttpResponse.STATUS_FAILED);
//					}	
//
//					fhcFreeBodyBuf(ReqKey);
//				}else{
//					RespResult.setStatus(ifmw_HttpResponse.STATUS_FAILED);
//				}			
//			} catch (Exception e){
//				RespResult.setStatus(ifmw_HttpResponse.STATUS_FAILED);
//				RespResult.setErrorMsg(e.getMessage());
//			}
//
//			if (pri_request.isFileOutputMode() && tmpFileName != null) {
//				File tmpFile = new File(tmpFileName);
//				tmpFile.delete();
//			}
//			
//			ifmw_HttpRequester requester = pri_request.requester(); 
//			pri_request = null;
//			pri_isIdle = true;
//			
//			if (RespResult.getStatus() == ifmw_HttpResponse.STATUS_SUCCESS) {
//				if (RespResult.isMemoryData()) {
//					try {
//					} catch (Exception e) {
//						e.printStackTrace();
//					}
//				} else {
//				}
//			}
//			requester.callback(RespResult);
//		}
		
		/**
		 * Generate the filename to save HTTP response temporarily (make 'tmp' folder at the parent folder of orgFile and return the absolute name of tmpFile)
		 * 
		 * @param orgFileName	Filename to save HTTP response really.
		 * @return	Temporary filename
		 */
		private String generateTmpFileName(String orgFileName) {
			String tmpFileName = null;
			String fileSaveDir, fileTmpDir = null;
			
			if (orgFileName != null) {
				File orgFile = new File(orgFileName);
				fileSaveDir = orgFile.getParent();
				if (fileSaveDir != null) {
					fileTmpDir = fileSaveDir + "/tmp";
					File tmpDir = new File(fileTmpDir);
					if (tmpDir.exists() || tmpDir.mkdirs()) {
						tmpFileName = fileTmpDir + "/" + orgFile.getName();
					}
				}
				
			}
			
			return tmpFileName;
		}
		
		/**
		 * Read etag value from tagFile.
		 * 
		 * @param tagFileName	Absolute name of tagFile
		 * @return ETAG value. if there is no, return null 
		 */
		private String readEtag(String tagFileName) {
			String tagVal = null;
			if (tagFileName != null) {
				File tagFile = new File(tagFileName);
				if (tagFile.exists() && tagFile.length() > 0) {
					try {
						BufferedReader br = new BufferedReader(new FileReader(tagFile));
						tagVal = br.readLine();
						br.close();
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}
			
			return tagVal;
		}
		
		/**
		 * Write etag value to tagFile
		 * @param tagFileName	Absolute name of tagFile
		 * @param tagVal		etag value
		 */
		private void writeEtag(HttpResponse resp, String tagFileName) {
			if (tagFileName != null && resp != null) {
				try {
					String tagVal = resp.getFirstHeader(ETAG_HEADER).getValue();
					FileOutputStream out = new FileOutputStream(tagFileName, false);
					out.write(tagVal.getBytes());
					out.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}

		/**
		 * Rename the source file to the destination file
		 * 
		 * @param srcFileName	Source filename
		 * @param dstFileName	Destination filename
		 * @return	If renaming is success, true. Otherwise, false.
		 */
		private boolean renameFile(String srcFileName, String dstFileName) {
			boolean ret = false;
			
			try {
				File dstFile = new File(dstFileName);
				File srcFile = new File(srcFileName);
				ret = srcFile.renameTo(dstFile);
				
				if (ret) {
					File tagFile = new File(srcFileName + ".etag");
					tagFile.delete();
				}
			} catch (Exception e) {
			}
			return ret;
		}
	}	

	private class CustomByteArrayBuffer {
		ByteArrayBuffer m_buf;
		
		public CustomByteArrayBuffer() {
			m_buf = new ByteArrayBuffer(1024);
		}
		
		public void append(byte[] data) {
			int capacity, fillLen, empLen, dataLen;
			if (data != null) {
				capacity = m_buf.capacity();
				fillLen = m_buf.length();
				empLen = capacity - fillLen;
				dataLen = data.length;
				
				if (empLen < dataLen) {
					byte[] oldData = m_buf.buffer();
					m_buf = new ByteArrayBuffer(capacity + dataLen);
					m_buf.append(oldData, 0, fillLen);
				}
				
				m_buf.append(data, 0, dataLen);
			}
		}
		
		public byte[] toByteArray() {
			return m_buf.toByteArray();
		}
	}
	
//	/**
//	 * JNI function that process the HTTP request depending to GHTTP
//	 * 
//	 * @param url	HTTP URL
//	 * @param postData	Post data of HTTP request
//	 * @param postType	Post data type (String post or Binary post)
//	 * @param outputFile	Filename to save HTTP response
//	 * @param boundStr	Boundary used by binary post
//	 * @param ReqKey	Key that identify the HTTP request processed by GHTTP
//	 * @return	If success, 1. If failed, -1. If processing, 2
//	 */
//	public native int fhcProcess(String url, byte[] postData, int postType, String outputFile, String boundStr,int ReqKey);
//
//	/**
//	 * JNI function that get HTTP response data with the given key from GHTTP
//	 * 
//	 * @param nReqKey	Key to identify the HTTP request
//	 * @return	HTTP response data
//	 */
//	public native byte[] fhcGetBodyFromBuf(int nReqKey);
//
//	/**
//	 * JNI function that free HTTP response data with the given key
//	 * 
//	 * @param nReqKey	Key to identify the HTTP request
//	 * @return	If success, 1.
//	 */
//	public native int fhcFreeBodyBuf(int nReqKey);
//
//	/**
//	 * JNI function that stop the HTTP request's process responsible to the given key
//	 * 
//	 * @param nReqKey	Key to identify the HTTP request
//	 * @return
//	 */
//	public native int fhcStopProcess(int nReqKey);
//	
//	/**
//	 * JNI function that get Status Code of HTTP response with the given key
//	 * 
//	 * @param nReqKey	Key to identify the HTTP request
//	 * @return	Status code of HTTP response
//	 */
//	public native int fhcGetStatusCode(int nReqKey);
//	
//	/**
//	 * JNI function that get Reason Phrase of HTTP response
//	 * 
//	 * @param nReqKey	Key to identify the HTTP request
//	 * @return	Reason phrase of HTTP response
//	 */
//	public native String fhcGetReasonPhrase(int nReqKey);
//	
//	/**
//	 * JNI function that get the error message at fail time
//	 * 
//	 * @param nReqKey	Key to identify the HTTP request
//	 * @return	Error message
//	 */
//	public native String fhcGetErrStr(int nReqKey);
//
//	/**
//	 * JNI function that request the new HTTP request key to GHTTP
//	 * 
//	 * @return	Key to identify HTTP request
//	 */
//	public native int fhcGetReqeustIndex();
//
//	/**
//	 * Load GHTTP JNI library
//	 */
//	static {
//		System.loadLibrary("http_client");
//	}

}