//
//  Constants.h
//  Chatting
//
//  Created by YunCholHo on 2/28/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//


#define SERVER_IP_ADDRESS       @"218.61.196.230"
#define PORT                    1931 
#define _PORT                   9600

#define DEBUG_SOCKET_IO_LOGS              1

#define HANDSHAKE_URL @"http://%@:%d/socket.io/1/t=%d%@"
#define SOCKET_URL @"ws://%@:%d/socket.io/1/websocket/%@"
#define COOKIE_URL @"http://%@:%d/iOS"
#define FILE_UPLOAD_URL @"http://%@:%d/goalsrv/api"



/** Table Names */
#define TABLE_NAME_MESSAGE                   @"messages"
#define TABLE_NAME_RECEIVEMSGTIME            @"receivemsgtime"

/** Column Names */
#define COL_NAME_ROOM_PK                     @"id"
#define COL_NAME_ROOM_ID                     @"room_id"
#define COL_NAME_ROOM_NAME                   @"room_name"

#define COL_NAME_USER_PK                     @"id"
#define COL_NAME_USER_ID                     @"user_id"
#define COL_NAME_USER_NAME                   @"user_name"

#define COL_NAME_REF_PK                      @"id"
#define COL_NAME_REF_ROOM_ID                 @"room_id"
#define COL_NAME_REF_USER_ID                 @"user_id"

#define COL_NAME_MSG_PK                      @"id"
#define COL_NAME_MSG_ROOM_ID                 @"room_id"
#define COL_NAME_MSG_SENDER_ID               @"sender_id"
#define COL_NAME_MSG_MESSAGE                 @"msg"
#define COL_NAME_MSG_SEND_TIME               @"send_time"
#define COL_NAME_STATE                       @"state"
#define COL_NAME_MSG_SENDER_PHOTO            @"sender_photo"
#define COL_NAME_MSG_SENDER_NAME             @"sender_name"
#define COL_NAME_MSG_READSTATE               @"read_state"
#define COL_NAME_MSG_SENDSTATE               @"send_state"
#define COL_NAME_MSG_OWNER                   @"app_owner"

#define COL_NAME_SENDER_NAME                 @"sender_name"



#define PARAM_KEY_SUCCESS             @"success"
#define PARAM_KEY_FILE_NAME          @"server_file_name"
#define PARAM_KEY_SERVER_FILE_PATH     @"server_file_path"
#define PARAM_KEY_SERVER_IDX            @"server_idx"

#define LOGTAG                          @"KCHN-LOG: "
