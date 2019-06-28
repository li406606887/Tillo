//
//  APICommon.h
//  T-Shion
//
//  Created by together on 2018/10/11.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#ifndef APICommon_h
#define APICommon_h

#define NewCloudHostUrl  @"https://newfile.aillo.cc/storage"//新的云存储

#ifdef AilloTest
/****************************************测试服务器********************************************************/

#define UploadHostUrl  @"https://file.aillo.cc"
#define MpushHostUrl   @"http://3.0.143.131:9999" //Mpush
#define UserHostUrl    @"3.0.143.131"  //8001用户
#define SingleHostUrl  @"3.0.143.131"//8002单聊
#define FriendHostUrl  @"3.0.143.131"//8003好友
#define RTCHostUrl     @"3.0.143.131"   //8005RTC
#define GroupHostUrl   @"3.0.143.131" //8006群聊
#define GroupCodeUrl   [NSString stringWithFormat:@"http://%@:8006",GroupHostUrl]


//福美的ip
//#define UploadHostUrl  @"https://file.aillo.cc"
//#define MpushHostUrl   @"http://192.168.1.188:9999" //Mpush
//#define UserHostUrl    @"192.168.1.188"  //8001用户
//#define SingleHostUrl  @"192.168.1.188"//8002单聊
//#define FriendHostUrl  @"192.168.1.188"//8003好友
//#define RTCHostUrl     @"192.168.1.188"   //8005RTC
//#define GroupHostUrl   @"192.168.1.188" //8006群聊
//#define GroupCodeUrl   [NSString stringWithFormat:@"http://%@:8006",GroupHostUrl]

//何威的ip
//#define UploadHostUrl  @"https://file.aillo.cc"
//#define MpushHostUrl   @"http://192.168.1.101:9999" //Mpush
//#define UserHostUrl    @"192.168.1.101"  //8001用户
//#define SingleHostUrl  @"192.168.1.101"//8002单聊
//#define FriendHostUrl  @"192.168.1.101"//8003好友
//#define RTCHostUrl     @"192.168.1.101"   //8005RTC
//#define GroupHostUrl   @"192.168.1.101" //8006群聊
//#define GroupCodeUrl   [NSString stringWithFormat:@"http://%@:8006",GroupHostUrl]
/* * *
 * User block
 * port:8001
 * * */
#define api_login   [NSString stringWithFormat:@"http://%@:8001/login",UserHostUrl]
#define api_register   [NSString stringWithFormat:@"http://%@:8001/register",UserHostUrl]
#define api_get_smsCode   [NSString stringWithFormat:@"http://%@:8001/getSmsCode",UserHostUrl]
#define api_forget   [NSString stringWithFormat:@"http://%@:8001/forget",UserHostUrl]
#define api_get_qntoken  [NSString stringWithFormat:@"http://%@:8001/getToken",UserHostUrl]
#define api_upload_file  [NSString stringWithFormat:@"http://%@:8001/saveFile",UserHostUrl]
#define api_download_file  [NSString stringWithFormat:@"http://%@:8081/getFile",UserHostUrl]
#define api_put_update_info  [NSString stringWithFormat:@"http://%@:8001/updateInfo",UserHostUrl]
#define api_post_device_token [NSString stringWithFormat:@"http://%@:8001/saveDeviceToken",UserHostUrl]
#define api_post_feedback   [NSString stringWithFormat:@"http://%@:8001/feedback",UserHostUrl]
#define api_delete_logout   [NSString stringWithFormat:@"http://%@:8001/logout",UserHostUrl]
#define api_put_update_pwd  [NSString stringWithFormat:@"http://%@:8001/updatePwd",UserHostUrl]
#define api_get_newVersion  [NSString stringWithFormat:@"http://%@:8001/newVersion",UserHostUrl]

#define api_get_userInfo  [NSString stringWithFormat:@"http://%@:8001/getUserInfo",UserHostUrl]
#define api_post_refreshToken  [NSString stringWithFormat:@"http://%@:8001/refreshToken",UserHostUrl]

#define api_post_notice  [NSString stringWithFormat:@"http://%@:8001/notice",UserHostUrl]

/* * *
 * Single block
 * port:8002
 * * */
#define api_message_push  [NSString stringWithFormat:@"http://%@:8002/push",SingleHostUrl]
#define api_get_offline  [NSString stringWithFormat:@"http://%@:8002/getOfflineMsg",SingleHostUrl]

/* * *
 * Friend block
 * port:8003
 * * */
#define api_search_friend  [NSString stringWithFormat:@"http://%@:8003/searchFriend",FriendHostUrl]
#define api_add_friend  [NSString stringWithFormat:@"http://%@:8003/addFriend",FriendHostUrl]
#define api_friend_request  [NSString stringWithFormat:@"http://%@:8003/searchRequest",FriendHostUrl]
#define api_pass_friend  [NSString stringWithFormat:@"http://%@:8003/passFriend",FriendHostUrl]
#define api_post_friendRequest  [NSString stringWithFormat:@"http://%@:8003/friendRequest",FriendHostUrl]
#define api_get_friends  [NSString stringWithFormat:@"http://%@:8003/friends",FriendHostUrl]
#define api_delete_friend  [NSString stringWithFormat:@"http://%@:8003/deleteFriend",FriendHostUrl]
#define api_update_friend  [NSString stringWithFormat:@"http://%@:8003/updateFriend",FriendHostUrl]
#define api_get_session  [NSString stringWithFormat:@"http://%@:8003/getOfflineSession",FriendHostUrl]
#define api_post_complaintFriend  [NSString stringWithFormat:@"http://%@:8003/complaintFriend",FriendHostUrl]
#define api_post_friendInfo   [NSString stringWithFormat:@"http://%@:8003/friendInfo",FriendHostUrl]
#define api_room_setting   [NSString stringWithFormat:@"http://%@:8003/room/setting",FriendHostUrl]
#define api_get_new_firend_prompt   [NSString stringWithFormat:@"http://%@:8003/request/flag",FriendHostUrl]
#define api_get_blackUserList   [NSString stringWithFormat:@"http://%@:8003/blacklist",FriendHostUrl]
#define api_put_blackUser    [NSString stringWithFormat:@"http://%@:8003/blacklist/status",FriendHostUrl]

/* * *
 * Group block
 * port:8006
 * * */
#define api_post_creat_session  [NSString stringWithFormat:@"http://%@:8006/createGroup",GroupHostUrl]
#define api_get_group_offline  [NSString stringWithFormat:@"http://%@:8006/pullGroupMsg",GroupHostUrl]
#define api_groupMessage_push  [NSString stringWithFormat:@"http://%@:8006/push",GroupHostUrl]
#define api_get_group_Member  [NSString stringWithFormat:@"http://%@:8006/getGroupMember",GroupHostUrl]
#define api_post_add_Member  [NSString stringWithFormat:@"http://%@:8006/addGroupMember",GroupHostUrl]
#define api_get_group_List  [NSString stringWithFormat:@"http://%@:8006/getGroupList",GroupHostUrl]
#define api_put_deleteMember  [NSString stringWithFormat:@"http://%@:8006/delGroupMember",GroupHostUrl]
#define api_delete_exit_group  [NSString stringWithFormat:@"http://%@:8006/exitGroup",GroupHostUrl]
#define api_put_modify_group_name  [NSString stringWithFormat:@"http://%@:8006/updateGroupName",GroupHostUrl]

#define api_put_updateGroupAvatar  [NSString stringWithFormat:@"http://%@:8006/updateGroupAvatar",GroupHostUrl]

#define api_get_groupQrCode  [NSString stringWithFormat:@"http://%@:8006/group/qrcode",GroupHostUrl]

#define api_put_groupInviteSwitch  [NSString stringWithFormat:@"http://%@:8006/group/invite/switch",GroupHostUrl]

#define api_put_transferGroup  [NSString stringWithFormat:@"http://%@:8006/transferGroup",GroupHostUrl]

#define api_get_groupInfo  [NSString stringWithFormat:@"http://%@:8006/groupInfo",GroupHostUrl]

#define api_put_modify_nickNameInGroup  [NSString stringWithFormat:@"http://%@:8006/updateName",GroupHostUrl]

#define api_get_groupQrCode_join  [NSString stringWithFormat:@"http://%@:8006/group/qrcode/join",GroupHostUrl]

/* * *
 * RTC block
 * port:8005
 * * */
#define api_post_call  [NSString stringWithFormat:@"http://%@:8005/push",RTCHostUrl]
#define api_post_refused  [NSString stringWithFormat:@"http://%@:8005/refused",RTCHostUrl]
#define api_post_hangup  [NSString stringWithFormat:@"http://%@:8005/hang",RTCHostUrl]
#define api_get_RTCToken  [NSString stringWithFormat:@"http://%@:8005/",RTCHostUrl]
#define api_get_initiating [NSString stringWithFormat:@"http://%@:8005/initiating",RTCHostUrl]



/*******
 EndToEndEncryption
 *******/
//发起加密聊天，获取加密的房间号以及对方的3个公钥
#define api_get_crypt_room_id [NSString stringWithFormat:@"http://%@:8002/beforeEndToEndChat",SingleHostUrl]
//向服务端保存自己的三个公钥
#define api_save_my_three_key [NSString stringWithFormat:@"http://%@:8001/saveUserPublicKey",UserHostUrl]
//查询自己还有多少个一次性密钥
#define api_query_onetimekey_count [NSString stringWithFormat:@"http://%@:8001/getOneTimeKeyCount",UserHostUrl]
//补充自己的一次性密钥
#define api_increment_onetimekey [NSString stringWithFormat:@"http://%@:8001/incrementOneTimeKey",UserHostUrl]

//批量获取群内用户公钥
#define api_get_group_user_key [NSString stringWithFormat:@"http://%@:8006/getGroupUserKeys", FriendHostUrl]

//群聊push
#define api_crypt_groupMessage_push  [NSString stringWithFormat:@"http://%@:8006/encryptGroupPush",GroupHostUrl]


/*******
 消息回执
 *******/
#define api_single_message_ack [NSString stringWithFormat:@"http://%@:8002/msgAck",SingleHostUrl]

#endif



#ifdef AilloRelease
/****************************************正式服务器********************************************************/

#define UploadHostUrl  @"https://file.aillo.cc"
#define MpushHostUrl   @"https://mpush.aillo.cc" //Mpush
#define UserHostUrl    @"user.aillo.cc"  //8001用户
#define SingleHostUrl  @"single.aillo.cc"//8002单聊
#define FriendHostUrl  @"friend.aillo.cc"//8003好友
#define RTCHostUrl     @"rtc121.aillo.cc"   //8005RTC
#define GroupHostUrl   @"group.aillo.cc" //8006群聊

#define GroupCodeUrl   [NSString stringWithFormat:@"https://%@",GroupHostUrl]
/* * *
 * User block
 * port:8001
 * * */
#define api_login   [NSString stringWithFormat:@"https://%@/login",UserHostUrl]
#define api_register   [NSString stringWithFormat:@"https://%@/register",UserHostUrl]
#define api_get_smsCode   [NSString stringWithFormat:@"https://%@/getSmsCode",UserHostUrl]
#define api_forget   [NSString stringWithFormat:@"https://%@/forget",UserHostUrl]
#define api_get_qntoken  [NSString stringWithFormat:@"https://%@/getToken",UserHostUrl]
#define api_upload_file  [NSString stringWithFormat:@"https://%@/saveFile",UserHostUrl]
#define api_put_update_info  [NSString stringWithFormat:@"https://%@/updateInfo",UserHostUrl]
#define api_post_device_token [NSString stringWithFormat:@"https://%@/saveDeviceToken",UserHostUrl]
#define api_post_feedback   [NSString stringWithFormat:@"https://%@/feedback",UserHostUrl]
#define api_delete_logout   [NSString stringWithFormat:@"https://%@/logout",UserHostUrl]
#define api_put_update_pwd  [NSString stringWithFormat:@"https://%@/updatePwd",UserHostUrl]
#define api_get_newVersion  [NSString stringWithFormat:@"https://%@/newVersion",UserHostUrl]

#define api_get_userInfo  [NSString stringWithFormat:@"https://%@:/getUserInfo",UserHostUrl]
#define api_post_refreshToken  [NSString stringWithFormat:@"https://%@:/refreshToken",UserHostUrl]
#define api_post_notice  [NSString stringWithFormat:@"https://%@:/notice",UserHostUrl]


/* * *
 * Single block
 * port:8002
 * * */
#define api_message_push  [NSString stringWithFormat:@"https://%@/push",SingleHostUrl]
#define api_get_offline  [NSString stringWithFormat:@"https://%@/getOfflineMsg",SingleHostUrl]
/* * *
 * Friend block
 * port:8003
 * * */
#define api_search_friend  [NSString stringWithFormat:@"https://%@/searchFriend",FriendHostUrl]
#define api_add_friend  [NSString stringWithFormat:@"https://%@/addFriend",FriendHostUrl]
#define api_friend_request  [NSString stringWithFormat:@"https://%@/searchRequest",FriendHostUrl]
#define api_pass_friend  [NSString stringWithFormat:@"https://%@/passFriend",FriendHostUrl]
#define api_post_friendRequest  [NSString stringWithFormat:@"https://%@/friendRequest",FriendHostUrl]
#define api_get_friends  [NSString stringWithFormat:@"https://%@/friends",FriendHostUrl]
#define api_delete_friend  [NSString stringWithFormat:@"https://%@/deleteFriend",FriendHostUrl]
#define api_update_friend  [NSString stringWithFormat:@"https://%@/updateFriend",FriendHostUrl]
#define api_get_session  [NSString stringWithFormat:@"https://%@/getOfflineSession",FriendHostUrl]
#define api_post_complaintFriend  [NSString stringWithFormat:@"https://%@/complaintFriend",FriendHostUrl]
#define api_post_friendInfo   [NSString stringWithFormat:@"https://%@/friendInfo",FriendHostUrl]
#define api_room_setting   [NSString stringWithFormat:@"https://%@/room/setting",FriendHostUrl]
#define api_get_new_firend_prompt   [NSString stringWithFormat:@"https://%@/request/flag",FriendHostUrl]
#define api_get_blackUserList   [NSString stringWithFormat:@"https://%@/blacklist",FriendHostUrl]
#define api_put_blackUser    [NSString stringWithFormat:@"https://%@/blacklist/status",FriendHostUrl]

/* * *
 * RTC block
 * port:8005
 * * */
#define api_post_call  [NSString stringWithFormat:@"https://%@/push",RTCHostUrl]
#define api_post_refused  [NSString stringWithFormat:@"https://%@/refused",RTCHostUrl]
#define api_post_hangup  [NSString stringWithFormat:@"https://%@/hang",RTCHostUrl]
#define api_get_RTCToken  [NSString stringWithFormat:@"https://%@",RTCHostUrl]
#define api_get_initiating [NSString stringWithFormat:@"https://%@/initiating",RTCHostUrl]
/* * *
 * Group block
 * port:8006
 * * */
#define api_post_creat_session  [NSString stringWithFormat:@"https://%@/createGroup",GroupHostUrl]
#define api_get_group_offline  [NSString stringWithFormat:@"https://%@/pullGroupMsg",GroupHostUrl]
#define api_groupMessage_push  [NSString stringWithFormat:@"https://%@/push",GroupHostUrl]
#define api_get_group_Member  [NSString stringWithFormat:@"https://%@/getGroupMember",GroupHostUrl]
#define api_post_add_Member  [NSString stringWithFormat:@"https://%@/addGroupMember",GroupHostUrl]
#define api_get_group_List  [NSString stringWithFormat:@"https://%@/getGroupList",GroupHostUrl]
#define api_put_deleteMember  [NSString stringWithFormat:@"https://%@/delGroupMember",GroupHostUrl]
#define api_delete_exit_group  [NSString stringWithFormat:@"https://%@/exitGroup",GroupHostUrl]
#define api_put_modify_group_name  [NSString stringWithFormat:@"https://%@/updateGroupName",GroupHostUrl]
#define api_put_updateGroupAvatar  [NSString stringWithFormat:@"https://%@/updateGroupAvatar",GroupHostUrl]

#define api_get_groupQrCode  [NSString stringWithFormat:@"https://%@/group/qrcode",GroupHostUrl]

#define api_put_groupInviteSwitch  [NSString stringWithFormat:@"https://%@/group/invite/switch",GroupHostUrl]

#define api_put_transferGroup  [NSString stringWithFormat:@"https://%@/transferGroup",GroupHostUrl]

#define api_get_groupInfo  [NSString stringWithFormat:@"https://%@/groupInfo",GroupHostUrl]

#define api_put_modify_nickNameInGroup  [NSString stringWithFormat:@"https://%@/updateName",GroupHostUrl]

#define api_get_groupQrCode_join  [NSString stringWithFormat:@"https://%@/group/qrcode/join",GroupHostUrl]



/*******
 EndToEndEncryption
 *******/
//发起加密聊天，获取加密的房间号以及对方的3个公钥
#define api_get_crypt_room_id [NSString stringWithFormat:@"https://%@/beforeEndToEndChat",SingleHostUrl]
//向服务端保存自己的三个公钥
#define api_save_my_three_key [NSString stringWithFormat:@"https://%@/saveUserPublicKey",UserHostUrl]
//查询自己还有多少个一次性密钥
#define api_query_onetimekey_count [NSString stringWithFormat:@"https://%@/getOneTimeKeyCount",UserHostUrl]
//补充自己的一次性密钥
#define api_increment_onetimekey [NSString stringWithFormat:@"https://%@/incrementOneTimeKey",UserHostUrl]

//批量获取群内用户公钥
#define api_get_group_user_key [NSString stringWithFormat:@"http://%@/getGroupUserKeys", FriendHostUrl]

//群聊push
#define api_crypt_groupMessage_push  [NSString stringWithFormat:@"http://%@:8006/encryptGroupPush",GroupHostUrl]

#endif



#endif /* APICommon_h */

