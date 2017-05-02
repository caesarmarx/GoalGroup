//
//  Language.m
//
//  Created by JinYongHao on 9/25/14.
//  Copyright (c) 2014 JinYongHao. All rights reserved.
//

#import "Language.h"
#import "HttpManager.h"

@implementation Language

+ (Language *)sharedInstance
{
    @synchronized(self)
    {
        if (gLanguage == nil)
            gLanguage = [[Language alloc] init];
    }
    return gLanguage;
}

- (id)init
{
    if (self)
    {
        NSUserDefaults *language = [NSUserDefaults standardUserDefaults];
        
        //-----------------------------Button-------------------------------//
        [language setObject:@"足球の城"        forKey:@"title"];
        
        [language setObject:@"是"            forKey:@"ok"];
        [language setObject:@"不"            forKey:@"no"];
        
        [language setObject:@"确定"          forKey:@"yes"];
        [language setObject:@"取消"           forKey:@"cancel"];
        
        
        //-----------------------------Http Communication-------------------//
        [language setObject:@"没有开启网连接"  forKey:@"network_invalid"];
        
        //-----------------------------LogIn--------------------------------//
        [language setObject:@"登录" forKey:@"login"];
        [language setObject:@"登录中..." forKey:@"registering..."];
        
        [language setObject:@"请输入您的电话号码"
                     forKey:@"login_placeholder_phonenumber"];
        
        [language setObject:@"请输入1~10个数字和文字"
                     forKey:@"login_placeholder_password"];
        
        [language setObject:@"用户名不存在"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeUnregisterUser]];
        [language setObject:@"您输入的密码错误，请重新输入"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeWrongPassword]];
        [language setObject:@"forbidden"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeForbiddenUser]];
        
        //-----------------------------LogOut-------------------------------//
        [language setObject:@"退出"                            forKey:@"logout"];
        [language setObject:@"您想退出足球の城吗?"               forKey:@"logout_verify"];
        [language setObject:@"退出失败"                         forKey:[Language stringWithInteger:ProtocolErrorTypeLogoutFail]];
        
        //-----------------------------Register-----------------------------//
        [language setObject:@"注册"       forKey:@"register"];
        [language setObject:@"昵称"       forKey:@"alias"];
        [language setObject:@"手机号码"     forKey:@"phone_number"];
        [language setObject:@"密码"       forKey:@"password"];
        [language setObject:@"密码确认"     forKey:@"password_conf"];
    
        [language setObject:@"请输入用户"                forKey:@"register_username_empty"];
        [language setObject:@"昵称长度限制10个字符以内。"    forKey:@"register_username_length_invalid"];
        [language setObject:@"不能输入特殊文字。"        forKey:@"register_username_input_invalid"];
        
        [language setObject:@"请输入手机号码"          forKey:@"register_phonenumber_empty"];
        [language setObject:@"请输入真实手机号码"       forKey:@"register_phonenumber_invalid"];
        
        [language setObject:@"请输入密码"              forKey:@"register_password_empty"];
        [language setObject:@"密码长度限制10个字符以内"      forKey:@"register_password_length_invalid"];
        [language setObject:@"密码不能输入特殊文字"    forKey:@"register_password_input_invalid"];
        
        [language setObject:@"请输入密码"              forKey:@"register_password_confirm"];
        [language setObject:@"您输入的密码和确认密码不一致"  forKey:@"register_password_diff"];
        
        [language setObject:@"昵称已存在"            forKey:@"register_username_duplicated"];
        [language setObject:@"手机号码已注册"         forKey:@"register_phone_duplicated"];
        
        [language setObject:@"注册成功"              forKey:@"register_user_success"];
        [language setObject:@"注册失败"              forKey:@"register_user_fail"];
        [language setObject:@"注册失败"              forKey:[Language stringWithInteger:ProtocolErrorTypeRegisterFail]];
        [language setObject:@"手机号码已注册"         forKey:[Language stringWithInteger:ProtocolErrorTypePhoneNumberDuplicate]];
        
        //----------------------------Menu-------------------------------------//
        [language setObject:@"发布擂台"      forKey:@"general_menu_first"];
        [language setObject:@"创建俱乐部"    forKey:@"general_menu_second"];
        [language setObject:@"个人设置"      forKey:@"general_menu_third"];
        [language setObject:@"俱乐部成员"    forKey:@"club_menu_first"];
        [language setObject:@"俱乐部信息"    forKey:@"club_menu_second"];
        [language setObject:@"编制赛程表"    forKey:@"club_menu_third"];
        [language setObject:@"俱乐部设置"    forKey:@"club_menu_fourth"];
        [language setObject:@"解散"         forKey:@"club_menu_fifth"];
        [language setObject:@"编制比赛"             forKey:@"club_custom_game"];
        
        //----------------------------Challenge--------------------------------//
        [language setObject:@"擂台大厅"          forKey:@"challenge_list_title"];
        [language setObject:@"主队是您的俱乐部"    forKey:@"manager_club"];
        
        [language setObject:@"推荐成功"           forKey:@"recommend_success"];
        [language setObject:@"推荐失败"           forKey:@"recommend_failed"];
        
        [language setObject:@"我推荐这个"          forKey:@"myrecommend"];
        [language setObject:@"擂台"               forKey:@"challenge"];
        [language setObject:@"主队"               forKey:@"sendteam"];
        [language setObject:@"我们会议吧"          forKey:@"challenge_talk"];
        
        [language setObject:@"请输入主队"         forKey:@"challenge_team_empty"];
        [language setObject:@"请选择比赛日期"      forKey:@"challenge_date_empty"];
        [language setObject:@"请选择比赛时间"      forKey:@"challenge_time_empty"];
        [language setObject:@"请选择赛制"         forKey:@"challenge_member_empty"];
        [language setObject:@"请选择场地区域"      forKey:@"challenge_stadium_empty"];
        [language setObject:@"请输入场地详细地址"      forKey:@"challenge_stadiumaddr_empty"];
        [language setObject:@"请输入客队"      forKey:@"challenge_invite_team_empty"];
        
        //----------------------------Discuss-----------------------------------//
        [language setObject:@"球谈"               forKey:@"discuss"];
        [language setObject:@"阅览球谈"            forKey:@"read_bbs"];
        [language setObject:@"评价"               forKey:@"answer"];
        [language setObject:@"回复"               forKey:@"restore"];
        
        //----------------------------Research----------------------------------//
        [language setObject:@"发现" forKey:@"research"];
        
        
        //----------------------------Club--------------------------------------//
        [language setObject:@"俱乐部"              forKey:@"club"];
        [language setObject:@"请选择场上位置"       forKey:@"position is empty"];
        [language setObject:@"比赛信息"             forKey:@"game_detail_information"];
        
        //----------------------------Common-----------------------------------//
        [language setObject:@"权限不足"  forKey:@"no_manager"];
        [language setObject:@"成功"      forKey:@"success"];
        
        [language setObject:@"无法连接到服务器。"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeInvalidService]];
        
        
        [language setObject:@"没有资料"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeNoData]];
        [language setObject:@"report failed"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeReportFailed]];
        [language setObject:@"您已经使用最新版本。"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeNoUpdateApp]];
        [language setObject:@"创造俱乐部失败"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeCreateClubFailed]];
        [language setObject:@"昵称已存在"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeNickNameDuplicate]];
        [language setObject:@"应战失败"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeAgreeFail]];
        [language setObject:@"浏览资料失败"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeBrowseDataFail]];
        [language setObject:@"失败"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeProcessFail]];
        [language setObject:@"已发送邀请"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeInviteDuplicate]];
        [language setObject:@"已加盟申请过"
                     forKey:[Language stringWithInteger:protocolerrortypeJoinReqDuplicate]];
        [language setObject:@"退出失败"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeLogoutFail]];
        
        [language setObject:@"离队俱乐部失败"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeDismissClubFail]];
        [language setObject:@"您在重复创造的。创造失败。"
                     forKey:[Language stringWithInteger:protocolerrortypeCreateDuplicate]];
        [language setObject:@"请您联系足球的城管理员。"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeAskForManager]];
        [language setObject:@"创造商议厅失败。"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeCreateChattingRoomFail]];
        [language setObject:@"输入比分失败"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeSetGameResultFail]];
        
        [language setObject:@"输入球员们的比分失败" forKey:[Language stringWithInteger:ProtocolErrorTypeSetUserPointFail]];
        [language setObject:@"退赛失败。"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeGameResignFail]];
        [language setObject:@"退赛成功。"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeGameResignSucceess]];
        [language setObject:@"强调退赛。"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeGameResignForce]];
        [language setObject:@"已退赛"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeGameResignAlready]];
        [language setObject:@"他是您的俱乐部成员"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeHeIsYourClubMember]];
        [language setObject:@"该俱乐部拒绝球员加盟"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeJoinReqForbidden]];
        [language setObject:@"该球员拒绝俱乐部邀请"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeInviteForbidden]];
        [language setObject:@"比赛不结束"
                     forKey:[Language stringWithInteger:ProtocolErrorTypeGameNotFinished]];
        
        [language setObject:@"报名参赛成功。"
                     forKey:@"apply game success"];
        
        [language setObject:@"您的应战申请处理失败。请再确认申请的准确性。"
                     forKey:@"apply game failed"];
        
        [language setObject:@"已经应战过"
                     forKey:@"already received"];
        
        [language setObject:@"您不能编辑比分"
                     forKey:@"cannot input marks"];
        
        [language setObject:@"现在您不能申请退赛。"
                     forKey:@"cannot discard game"];
        
        [language setObject:@"现在您不能应战"
                     forKey:@"cannot join game"];
        
        
        [language setObject:@"协议退赛"
                     forKey:@"consult_discard"];
        
        [language setObject:@"请选择所属城市"
                     forKey:@"create club city invalid"];
        
        [language setObject:@"创造俱乐部成功"
                     forKey:@"create_club_success"];
        
        [language setObject:@"请输入俱乐部名称"
                     forKey:@"create club name invalid"];
        
        [language setObject:@"请选择成立时间"
                     forKey:@"create club day invalid"];
        
        [language setObject:@"请选择活动时间"
                     forKey:@"create club activeTime invalid"];
        
        [language setObject:@"请选择主场区域"
                     forKey:@"create club stadiumArea invalid"];
        
        [language setObject:@"请输入场地详细地址"
                     forKey:@"create club stadiumAddr invalid"];
        
        [language setObject:@"请选择活动区域"
                     forKey:@"create club zone invalid"];
        
        [language setObject:@"创造俱乐部失败"
                     forKey:@"create club establish invalid"];
        
        [language setObject:@"您真的要退赛吗?"
                     forKey:@"discard game?"];
        
        [language setObject:@"失败"
                     forKey:@"failed"];
        
        [language setObject:@"强制退赛"
                     forKey:@"force_discard"];
        
        [language setObject:@"比赛正在进行中。。。"
                     forKey:@"game is running"];
        
        [language setObject:@"比赛因退赛已失效。"
                     forKey:@"game is cancelled"];
        
        [language setObject:@"比赛已结束"
                     forKey:@"game is finished"];
        
        [language setObject:@"现在您不能申请退赛。"
                     forKey:@"game is not be accepted"];
        
        
        
        [language setObject:@"球员"
                     forKey:@"member"];
        
        [language setObject:@"无"
                     forKey:@"none"];
        
        [language setObject:@"战书"
                     forKey:@"notice"];
        
        [language setObject:@"没有加盟俱乐部"
                     forKey:@"no club belongs to you"];
        
        [language setObject:@"权限不足"
                     forKey:@"no admin club belongs to you"];
        
        [language setObject:@"请选择领队"
                     forKey:@"select another admin"];
        
        [language setObject:@"请先更换领队"
                     forKey:@"select another admin 2"];
        
        [language setObject:@"加盟申请成功"
                     forKey:@"register UserToClub success"];
        
        [language setObject:@"加盟申请失败"
                     forKey:@"register UserToClub failed"];
        
        [language setObject:@"请选择4个小时以后的比赛时间。"
                     forKey:@"timeselect invalid"];
        
        [language setObject:@"对不起。这是编制比赛。不能操作。"
                     forKey:@"this is custom game"];
        
        [language setObject:@"退赛成功。"
                     forKey:@"reject game success"];
        
        [language setObject:@"不能邀请自己"
                     forKey:@"sorry, cannot operate on you"];
        
        [language setObject:@"个人资料更新成功"
                     forKey:@"update_playerdetail_success"];
        
        [language setObject:@"已是该俱乐部成员"
                     forKey:@"user exist in club"];
        
        [language setObject:@"您真的要离队吗？"
                     forKey:@"would do you like leave this club?"];
        
        [language setObject:@"您想删除所有聊天记录吗?"
                     forKey:@"Do you really want to delete message history?"];
        
        [language setObject:@"您想删除所有记录吗?"
                     forKey:@"Do you really want to remove cache?"];
        
        [language setObject:@"请输入真实身高"
                     forKey:@"height is too long"];
        
        [language setObject:@"请输入真实体重"
                     forKey:@"weight is too much"];
        
        [language setObject:@"请输入真实球龄"
                     forKey:@"footballAge is too old"];
        
        [language setObject:@"请输入10字以内的内容"
                     forKey:@"sponsor is not more than 10 char"];
        
        [language setObject:@"请选择俱乐部"
                     forKey:@"No club is selected"];
        
        [language setObject:@"解散俱乐部吗？"
                     forKey:@"would you like to break this club down"];
        
        [language setObject:@"发布擂台成功"
                     forKey:@"challenge is created successfully"];
        
        [language setObject:@"战书发布成功"
                     forKey:@"notice is created successfully"];
        
        [language setObject:@"比赛擂台成功"
                     forKey:@"game is created successfully"];

        [language setObject:@"投诉成功"
                     forKey:@"ClubReport Success"];
        
        [language setObject:@"投诉失败"
                     forKey:@"Report failed"];
        
        [language setObject:@"保存成功"
                     forKey:@"save success"];

        [language setObject:@"浏览图片"
                     forKey:@"EGOPHOTO_VIEW_TITLE"];
		     
        [language setObject:@"请选择所属城市"
                     forKey:@"city is not selected"];
        
        [language setObject:@"权限不足"
                     forKey:@"game is unable to edit"];
        
        [language setObject:@"投诉成功"
                     forKey:@"PersonReport Success"];
        
        [language setObject:@"俱乐部暂时没有赛程"
                     forKey:@"the club has no schedules"];
        
        [language setObject:@"不存在球员"
                     forKey:@"no player exists"];
        
        [language setObject:@"已是该俱乐部成员"
                     forKey:@"HeIsClubMember"];
        
        
        [language setObject:@"您不能编辑比分"
                     forKey:@"cannot input game score"];
        
        [language setObject:@"权限不足"
                     forKey:@"you are not corch"];
        
        [language setObject:@"软件介绍"
                     forKey:@"app_info"];
        
        //최신판본이 존재하지 않습니다.
        [language setObject:@"不存在"
                     forKey:@"no exist"];
        
        [language setObject:@"比分"
                     forKey:@"score"];
        
        [language setObject:@"上半场"
                     forKey:@"first_half"];
        
        [language setObject:@"下半场"
                     forKey:@"second_half"];
        
        [language setObject:@"决定"
                     forKey:@"confirm"];
        
        [language setObject:@"租"
                     forKey:@"invitation"];
        
        [language setObject:@"进行中..."
                     forKey:@"working..."];
        

        
        //대화방이 존재하지 않습니다.
        [language setObject:@"不存在商议厅"
                     forKey:@"no chatting room"];
        
        [language setObject:@"所属城市"
                     forKey:@"select city"];
        
        [language setObject:@"俱乐部资料"
                     forKey:@"club detail"];
        
        [language setObject:@"俱乐部1"
                     forKey:@"club1"];
        
        [language setObject:@"活跃度"
                     forKey:@"action rate"];
        
        [language setObject:@"成立时间 :"
                     forKey:@"establish date"];
        
        [language setObject:@"所属城市 :"
                     forKey:@"active city"];
        
        [language setObject:@"活动时间 :"
                     forKey:@"active time"];
        
        [language setObject:@"活动时间"
                     forKey:@"active time with out comma"];
        
        [language setObject:@"活动活动:"
                     forKey:@"active time with out space"];
        
        [language setObject:@"活动区域 :"
                     forKey:@"active zone"];
        
        [language setObject:@"活动区域"
                     forKey:@"active zone with out comma"];
        
        [language setObject:@"活动区域:"
                     forKey:@"active zone with out space"];

        [language setObject:@"场地区域 :"
                     forKey:@"home zone"];
        
        [language setObject:@"场地区域"
                     forKey:@"home zone without comma"];
        
        [language setObject:@"主场区域 :"
                     forKey:@"main home zone"];
        
        [language setObject:@"主场区域"
                     forKey:@"main home zone without comma"];
        
        [language setObject:@"详细地址 :"
                     forKey:@"stadiumAddr"];
        
        [language setObject:@"成绩 :"
                     forKey:@"club_marks"];
        
        [language setObject:@"成员数 :"
                     forKey:@"member count"];
        
        [language setObject:@"赞助商 :"
                     forKey:@"sponsor"];
        
        [language setObject:@"简介 :"
                     forKey:@"introduce"];
        
        [language setObject:@"加盟"
                     forKey:@"join"];
        
        [language setObject:@"不能转送相机照片"
                     forKey:@"cannot use camera"];
        
        [language setObject:@"的战书"
                     forKey:@"club-notice"];
        
        [language setObject:@"发布的擂台"
                     forKey:@"club-challenge"];
        
        [language setObject:@"没有资料"
                     forKey:@"No Data"];
        
        [language setObject:@"俱乐部中心"
                     forKey:@"club center"];
        
        [language setObject:@"推荐"
                     forKey:@"challenge_play_swipe_recommend"];
        
        [language setObject:@"应战"
                     forKey:@"challenge_play_swipe_battle"];
        
        [language setObject:@"商议"
                     forKey:@"challenge_play_swipe_chat"];
        
        [language setObject:@"完成"
                     forKey:@"lbl_make_challenge_save"];
        
        [language setObject:@"保存"
                     forKey:@"lbl_club_detail_save"];
        
        [language setObject:@"投诉"
                     forKey:@"lbl_setting_report_save"];
        
        [language setObject:@"签到"
                     forKey:@"game_schedule_join"];
        
        
        [language setObject:@"应战成功"
                     forKey:@"agree_game_success"];
        
        [language setObject:@"不能推荐"
                     forKey:@"you can't recommend yourself"];
        
        [language setObject:@"人制" forKey:@"player number"];

        [language setObject:@"周一" forKey:@"week_mon"];
        [language setObject:@"周二" forKey:@"week_tue"];
        [language setObject:@"周三" forKey:@"week_web"];
        [language setObject:@"周四" forKey:@"week_thu"];
        [language setObject:@"周五" forKey:@"week_fri"];
        [language setObject:@"周六" forKey:@"week_sat"];
        [language setObject:@"周日" forKey:@"week_sun"];
        
        [language setObject:@"确认" forKey:@"DONE"];
        [language setObject:@"胜" forKey:@"ClubDetail_All"];
        [language setObject:@"平" forKey:@"ClubDetail_Draw"];
        [language setObject:@"负" forKey:@"ClubDetail_Loss"];
        [language setObject:@"人" forKey:@"PLAYER"];

        [language setObject:@"平均年龄" forKey:@"Average_Age"];
        
        [language setObject:@"俱乐部战绩" forKey:@"Club_Mark_Result"];
        
        [language setObject:@"赛季" forKey:@"ClubMarkItem_Title_1"];
        [language setObject:@"赛" forKey:@"ClubMarkItem_Title_2"];
        [language setObject:@"胜" forKey:@"ClubMarkItem_Title_3"];
        [language setObject:@"负" forKey:@"ClubMarkItem_Title_4"];
        [language setObject:@"进球" forKey:@"ClubMarkItem_Title_5"];
        [language setObject:@"失球" forKey:@"ClubMarkItem_Title_6"];
        [language setObject:@"胜球" forKey:@"ClubMarkItem_Title_7"];
        [language setObject:@"不存在您要的资料" forKey:@"ClubMarkItem_Label"];

        [language setObject:@"领队" forKey:@"LEADING"];
        [language setObject:@"教练" forKey:@"TRAINING"];

        [language setObject:@"前锋" forKey:@"FRONT_YARD"];
        [language setObject:@"中场" forKey:@"MIDDLE_YARD"];
        [language setObject:@"后卫" forKey:@"BACK_YARD"];
        [language setObject:@"门将" forKey:@"ClubMemberController_label_1"];
        
        [language setObject:@"前锋" forKey:@"ClubMemberController_Forward"];
        [language setObject:@"后卫" forKey:@"ClubMemberController_Defence"];
        
        [language setObject:@"俱乐部教练选择" forKey:@"CLUB_TRAINING"];
        [language setObject:@"俱乐部领队选择" forKey:@"CLUB_LEADING"];
        
        [language setObject:@"俱乐部大厅" forKey:@"CLUB_BIG_ROOM"];
        [language setObject:@"会议厅" forKey:@"METTING_ROOM"];
        
        [language setObject:@"发送" forKey:@"SEND"];
        [language setObject:@"战书大厅" forKey:@"DECLARATION_ROOM"];
        
        [language setObject:@"年龄" forKey:@"AGE_AGE"];
        [language setObject:@"岁" forKey:@"AGE"];
        [language setObject:@"以下" forKey:@"LESSTHAN"];
        [language setObject:@"以上" forKey:@"MORETHAN"];

        [language setObject:@"年龄区间" forKey:@"SEARCH_COND_AGE"];
        [language setObject:@"活动区域" forKey:@"SEARCH_COND_AREA"];
        [language setObject:@"活动时间" forKey:@"SEARCH_COND_WEEK"];
        
        [language setObject:@"健康状况" forKey:@"ClubSettingController_title_1"];
        [language setObject:@"聊天消息通知" forKey:@"ClubSettingController_title_2"];
        [language setObject:@"比赛消息通知" forKey:@"ClubSettingController_title_3"];
        [language setObject:@"战书消息通知" forKey:@"ClubSettingController_title_4"];
        [language setObject:@"加盟申请通知" forKey:@"ClubSettingController_title_5"];
        [language setObject:@"平台消息通知" forKey:@"ClubSettingController_title_6"];
        [language setObject:@"允许球员加盟" forKey:@"ClubSettingController_title_7"];
        [language setObject:@"清空聊天记录" forKey:@"ClubSettingController_title_8"];
        
        [language setObject:@"俱乐部大厅-设置" forKey:@"CLUB_ROOM_SETTING"];

        [language setObject:@"前锋【中锋】" forKey:@"DETAILPOSITIONS_1"];
        [language setObject:@"前锋【二前锋】" forKey:@"DETAILPOSITIONS_2"];
        [language setObject:@"前锋【边锋】" forKey:@"DETAILPOSITIONS_3"];
        [language setObject:@"中场【前腰】" forKey:@"DETAILPOSITIONS_4"];
        [language setObject:@"中场【前卫】" forKey:@"DETAILPOSITIONS_5"];
        [language setObject:@"中场【边前卫】" forKey:@"DETAILPOSITIONS_6"];
        [language setObject:@"中场【后腰】" forKey:@"DETAILPOSITIONS_7"];
        [language setObject:@"后卫【边后卫】" forKey:@"DETAILPOSITIONS_8"];
        [language setObject:@"后卫【中后卫】" forKey:@"DETAILPOSITIONS_9"];
        [language setObject:@"后卫【盯人中卫】" forKey:@"DETAILPOSITIONS_10"];
        [language setObject:@"消息" forKey:@"REPORT"];
        [language setObject:@"平台消息" forKey:@"SYSTEM_NOTICE"];
        [language setObject:@"俱乐部名称" forKey:@"CLUB NAME"];
        [language setObject:@"包含特殊字符" forKey:@"INCLUDE SPECIAL CAHR"];
        
        [language setObject:@"要播放的文件不存在" forKey:@"DECAPSULATOR LOG"];
        [language setObject:@"邀请信" forKey:@"INVITATION LETTER"];
        [language setObject:@"邀请您加入他们的俱乐部" forKey:@"DemandLetterItem Title"];
        
        [language setObject:@"主队支付" forKey:@"MAIN TEAM GIVE"];
        [language setObject:@"客队支付" forKey:@"OTHER TEAM GIVE"];
        [language setObject:@"制" forKey:@"SYSTEM"];
        [language setObject:@"场地费用" forKey:@"GROUND COST"];
        [language setObject:@"助攻" forKey:@"HELP ATTACK"];

        [language setObject:@"赛季评分" forKey:@"GameDetailCell Label 1"];
        [language setObject:@"比赛日程" forKey:@"GAME REPORT"];
        
        
        [language setObject:@"大连" forKey:@"DEFAULT_CITY_NAME"];
        [language setObject:@"加盟审核" forKey:@"REGISTER_USER_TO_CLUB"];
        
        [language setObject:@"发起战书" forKey:@"RESEARCH NOTICE"];

        [language setObject:@"编辑比赛" forKey:@"MakingChallengeController title"];
        [language setObject:@"客队" forKey:@"OTHER"];
        [language setObject:@"比赛日期" forKey:@"GAME WEATHER"];
        [language setObject:@"比赛时间" forKey:@"GAME TIME"];
        [language setObject:@"赛制" forKey:@"GAME NUMBER"];
        [language setObject:@"发布【论点/文章】" forKey:@"MakingDiscussController Title"];
        [language setObject:@"发布" forKey:@"ANNOUNCE"];
        [language setObject:@"发布论坛成功" forKey:@"DISCUSS MAKE SUCCESS"];
        [language setObject:@"个人数据" forKey:@"PersonalMarkDetailController Title"];
        [language setObject:@"参赛" forKey:@"Enter Game"];
        [language setObject:@"赛季平分" forKey:@"Game Point Avg"];
        [language setObject:@"比赛赛制" forKey:@"PlayerCountSelectController Title"];
        [language setObject:@"编辑个人资料" forKey:@"PlayerDetailController Title"];
        [language setObject:@"个人资料" forKey:@"PlayerDetailController Title 2"];
        
        [language setObject:@"性别" forKey:@"SEX"];
        [language setObject:@"出生日期" forKey:@"BIRTHDAY"];

        [language setObject:@"身高" forKey:@"HEIGHT"];
        [language setObject:@"身重" forKey:@"WEIGHT"];
        [language setObject:@"体重" forKey:@"MAINWEIGHT"];
        [language setObject:@"年" forKey:@"YEAR"];
        [language setObject:@"球龄" forKey:@"FOOTBALLAGE"];
        [language setObject:@"场上位置" forKey:@"POSITION"];
        [language setObject:@"所在城市" forKey:@"LIVING_CITY"];
        [language setObject:@"男" forKey:@"MALE"];
        [language setObject:@"女" forKey:@"FEMALE"];
        [language setObject:@"开启距离监听" forKey:@"ProxyMonitorEnabled"];
        [language setObject:@"关闭距离监听" forKey:@"ProxyMonitorDisabled"];
        [language setObject:@"球员市场" forKey:@"PLAYER_MARKET_TITLE"];
        
        [language setObject:@"程序错误，无法继续录音，请重启程序试试" forKey:@"RECORD_FAILED_LABEL"];
        [language setObject:@"裁判" forKey:@"REFEREE"];
        [language setObject:@"意见反馈" forKey:@"SUGGEST"];
        [language setObject:@"租借信" forKey:@"RENT_LETTER"];
        [language setObject:@"足球装备" forKey:@"FOOTBALL_EQUIPMENT"];
        [language setObject:@"每周一星" forKey:@"EVERY_PENTA"];
        [language setObject:@"允许俱乐部邀请" forKey:@"ALLOW_CLUB_INVITATION"];
        [language setObject:@"分享给小伙伴" forKey:@"SETTING_VIEW_LABEL_1"];
        [language setObject:@"清理内存" forKey:@"SETTING_VIEW_LABEL_2"];
        
        [language setObject:@"跟朋友们分享足球的城" forKey:@"SETTING_VIEW_LABEL_11"];
        [language setObject:@"足球的城就是为了您准备的。您可以创建俱乐部， 可以跟别人提足球。" forKey:@"SETTING_VIEW_LABEL_12"];
        [language setObject:@"足球的城" forKey:@"FOOTBALL_CITY"];
        [language setObject:@"这是一条演示信息" forKey:@"SETTING_VIEW_LABEL_13"];
        
        [language setObject:@"分享成功" forKey:@"REASON_STATE_SUCCESS"];
        [language setObject:@"分享失败" forKey:@"REASON_STATE_FAIL"];
        [language setObject:@"失败描述" forKey:@"REASON_STATE_FAIL_DESCRIBE"];

        
        [language setObject:@"主场" forKey:@"MAIN_YARD"];
        [language setObject:@"选择俱乐部" forKey:@"SELECT_CLUB"];
        

        
        [language setObject:@"已经另一个俱乐部应战了。不能重复申请应战"
                     forKey:@"game recevied by other team"];
        [language setObject:@"您已作为"
                     forKey:@"joined in other team already prefix"];
        [language setObject:@"的球员参赛"
                     forKey:@"joined in other team already suffix"];
        [language setObject:@"请输入99以内的数字"
                     forKey:@"available number small than 99"];
        [language setObject:@"请输入用户" forKey:@"name is empty"];
        [language setObject:@"请输入性别" forKey:@"sex is empty"];
        [language setObject:@"请输入出生日期" forKey:@"birthday is empty"];
        [language setObject:@"请首先选择城市" forKey:@"city is empty"];
        [language setObject:@"请选择活动时间" forKey:@"time is empty"];
        [language setObject:@"请选择活动区域" forKey:@"area is empty"];
        [language setObject:@"请输入体重" forKey:@"weightTextField is empty"];
        [language setObject:@"请输入身高" forKey:@"height is empty"];
        [language setObject:@"请输入球龄" forKey:@"footballage is empty"];
        [language setObject:@"离队成功" forKey:@"leave from club successfully"];
        [language setObject:@"编辑成功" forKey:@"game is edited successfully"];
        [language setObject:@"对不起，我要退赛。 如您同意协议退赛， 请选择协议退赛！" forKey:@"resigncause is belowing"];
        [language setObject:@"从%@图片邮件来了。" forKey:@"ImageMessage from"];
        [language setObject:@"从%@音声邮件来了。" forKey:@"VoiceMessage from"];
        [language setObject:@"请确认是否删除？" forKey:@"would you like to cancel game"];
        [language setObject:@"邀请" forKey:@"invite"];
        [language setObject:@"失败"
                     forKey:@"image upload failed"];
        [language setObject:@"租" forKey:@"tempInvite"];
        
        [language setObject:@"图片邮件" forKey:@"image_mail"];
        [language setObject:@"语音邮件" forKey:@"voice_mail"];
        [language setObject:@"改变领队后 您无法再管理俱乐部。\r\n您要改变领队吗?" forKey:@"would you like to change captain"];
        [language setObject:@"相册" forKey:@"Choose From Library"];
        [language setObject:@"照相机" forKey:@"Take Photo or Video"];
        [language setObject:@"请选择图片来源" forKey:@"Select picture source"];
        [language setObject:@"这是您的俱乐部" forKey:@"sendteam is yours"];

    }
    return self;
}

+ (NSString *)GetStringByKey:(NSString *)key
{
    NSString *result = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return result == nil ? [NSString stringWithFormat:@"key: %@", key] : result;
}

+ (NSString *)stringWithInteger:(int)key
{
    return [NSString stringWithFormat:@"%d", key];
}
@end
