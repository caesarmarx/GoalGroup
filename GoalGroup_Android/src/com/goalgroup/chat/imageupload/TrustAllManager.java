/**
 * This class implements the SSL Trust manager for HTTP Client.
 * 
 * @since 2010.08.08
 * @version 1.0
 */

package com.goalgroup.chat.imageupload;

import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.X509TrustManager;

public class TrustAllManager implements X509TrustManager {

	/**
	 * Check SSL certification of Client and allow all.
	 */
	public void checkClientTrusted(X509Certificate[] chain, String authType)
			throws CertificateException {
	}

	/**
	 * Check SSL certification of Server and allow all.
	 */
	public void checkServerTrusted(X509Certificate[] chain, String authType)
			throws CertificateException {
	}

	public X509Certificate[] getAcceptedIssuers() {
		return null;
	}
}
