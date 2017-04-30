/**
* This class implements Binary post field of HTTP
*
* @since	2010.07.22
* @version	1.0
*/

package com.goalgroup.chat.imageupload;

public class MOHttpBinaryPostField {
	/**
	 * Name of Binary post field
	 */
	private String pri_fieldName;
	
	/**
	 * Value of Binary post field
	 */
	private byte[] pri_fieldVal;
	
	/**
	 * MIME type of Binary post field
	 */
	private String pri_mimeType;
	
	/**
	 * Constructor of this class (Create the object with the specific name and value)
	 * 
	 * @param name	Name of Binary post field to be created
	 * @param val	Value of Binary post field to be created
	 */
	public MOHttpBinaryPostField(String name, byte[] val) {
		pri_fieldName = name;
		pri_fieldVal = val;
		pri_mimeType = null;
	}
	
	/**
	 * Constructor of this class (Create the object with the specific name, value and MIME type)
	 * 
	 * @param name	Name of Binary post field
	 * @param val	Value of Binary post field
	 * @param type	MIME type of Binary post field
	 */
	public MOHttpBinaryPostField(String name, byte[] val, String type) {
		pri_fieldName = name;
		pri_fieldVal = val;
		pri_mimeType = type;
	}
	
	/**
	 * Getter of Binary post field name
	 * 
	 * @return	Name of Binary post field
	 */
	public String getName() { return pri_fieldName; }
	
	/**
	 * Getter of Binary post field value
	 * 
	 * @return	Value of Binary post field
	 */
	public byte[] getValue() { return pri_fieldVal; }
	
	/**
	 * Getter of Binary post field's MIME type
	 * 
	 * @return	MIME type of Binary post field
	 */
	public String getType() { return pri_mimeType; }
}
