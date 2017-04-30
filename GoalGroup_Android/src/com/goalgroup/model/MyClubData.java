package com.goalgroup.model;

import com.goalgroup.GgApplication;

public class MyClubData{
	private String[] clubName;
	private String[] clubID;
	private int[] post;
	
	public MyClubData() {
		clubName = GgApplication.getInstance().getClubName();
		clubID = GgApplication.getInstance().getClubId();
		post = GgApplication.getInstance().getPost();
	}
	
	public String[] getClubNames() {
		return clubName;
	}
	
	public String[] getClubIDs() {
		return clubID;
	}
	
	public String getNameFromID(int id) {
		for (int i = 0; i < clubName.length; i++)
			if (id == Integer.valueOf(clubID[i]))
				return clubName[i];
		
		return "";
	}
	
	public String[] getOwnerClubNames() {
		int count = getOwnerClubCount();
		String[] ownerClubName = new String[count];
		count = 0;
		for (int i = 0; i < clubName.length; i++)
			if (post[i] == 1 || post[i] == 3) {
				ownerClubName[count] = clubName[i];
				count++;
			}
		return ownerClubName;
	}
	
	public int[] getOwnerClubIDs() {
		int count = getOwnerClubCount();
		int[] ownerClubID = new int[count];
		count = 0;
		
		for (int i = 0; i < clubID.length; i++)
			if (post[i] == 1 || post[i] == 3) {
				ownerClubID[count] = Integer.valueOf(clubID[i]);
				count++;
			}
		
		return ownerClubID;
	}
	
	public int getOwnerClubCount() {
		String[] clubId = GgApplication.getInstance().getClubId();
		post = GgApplication.getInstance().getPost();
		int count = 0;
		
		if (clubId == null)
			return count;
		
		for (int i = 0; i < clubId.length; i++) 
			if (post[i] == 1 || post[i] == 3)
				count ++;
		
		return count;
	}
	
	public boolean isOwner(int nClubID) {
		int[] ownerClubID = getOwnerClubIDs();
		
		for (int i = 0; i < ownerClubID.length; i++)
			if (ownerClubID[i] == nClubID)
				return true;
		
		return false;
	}
	
	public boolean isOwner() {
		int[] ownerClubID = getOwnerClubIDs();
		
		if (ownerClubID.length == 0)
			return false;
		
		return true;
	}
	
	public boolean isOwnClub(int clubID) {
		for (int i = 0; i < this.clubID.length; i++) {
			if (Integer.valueOf(this.clubID[i]) == clubID)
				return true;
		}
		return false;
	}
	
	public boolean isManagerOfClub(int clubID) {
		if(!isOwner())
			return false;
		
		int[] ownerClubID = getOwnerClubIDs();
		for (int i = 0; i < ownerClubID.length; i++) {
			if (ownerClubID[i] == clubID)
				return true;
		}
		return false;
	}
	
	public boolean isInstructorOfClub(int clubID) {
		for (int i = 0; i < this.clubID.length; i++) {
			if (clubID == Integer.valueOf(this.clubID[i]) && (post[i] == 2 || post[i] == 3))
				return true;
		}
		return false;
	}
	
	public boolean isPlayerOfClub() {
		if (clubID.length > 0)
			return true;
		return false;
	}
}
