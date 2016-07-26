//
//  UserHttp.m
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UserHttp.h"
#import "UserManager.h"
#import "IdentityManager.h"

@implementation UserHttp
#pragma mark -- 上传图片
//上传图片 得到地址
+ (NSURLSessionDataTask*)updateImageGuid:(NSString*)guid image:(UIImage*)image handler:(completionHandler)handler {
    //开始菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    UserManager *userManager = [UserManager manager];
    NSDictionary *parameters = @{@"user_guid":userManager.user.user_guid,@"app_guid":guid,@"access_token":[IdentityManager manager].identity.accessToken,@"company_no":@(userManager.user.currCompany.company_no)};
    NSURLSessionDataTask * dataTask = [manager POST:@"Attachments/upload_attachment" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        NSData *currData = [image dataInNoSacleLimitBytes:MaXPicSize];
        [formData appendPartWithFileData:currData name:@"doc" fileName:[NSString stringWithFormat:@"%@.jpg",@([[NSDate date] timeIntervalSince1970])] mimeType:@"image/jpeg"];
    }progress:nil success:^(NSURLSessionDataTask * task, id  responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //判断结果
        MError *err = nil;
        id data = nil;
        NSDictionary *responseObjectDic = [responseObject mj_keyValues];
        if([responseObjectDic[@"code"] integerValue] == 0) {
            data = responseObjectDic[@"data"];
        } else {
            err = [MError new];
        }
        //主线程执行回调
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(data,err);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //开始菊花
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        handler(nil,[MError new]);
    }];
    
    [dataTask resume];
    return dataTask;
}
#pragma mark -- 个推
//绑定个推别名
+ (NSURLSessionDataTask*)setupAPNSDevice:(NSString*)clientId userNo:(int)userNo handler:(completionHandler)handler {
    NSString *urlPath = @"PushMessage/bind_alias";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:clientId forKey:@"client_id"];
    [params setObject:@"2" forKey:@"client_type"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 融云
//同步群组
+ (NSURLSessionDataTask*)syncRYGroup:(int)userNo handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/sync";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取融云token
+ (NSURLSessionDataTask*)getRYToken:(int)userNo handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/token";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//将员工加入群聊
+ (NSURLSessionDataTask*)joinRYGroup:(int)userNo companyNo:(int)companyNo handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/join";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//将员工移除群聊
+ (NSURLSessionDataTask*)quitRYGroup:(int)userNo companyNo:(int)companyNo handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/quit";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 邀请链接
+ (NSURLSessionDataTask*)getInviteURL:(int)userNo companyNo:(int)companyNo handler:(completionHandler)handler {
    NSString *urlPath = @"Common/get_invite_link_url_short";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
+ (NSURLSessionDataTask*)getReferrerURL:(int)userNo handler:(completionHandler)handler {
    NSString *urlPath = @"Common/get_referrer_url_short";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 修改用户信息
+ (NSURLSessionDataTask*)updateUserInfo:(User*)user handler:(completionHandler)handler {
    NSString *urlPath = @"Users/update_user";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:user.user_guid forKey:@"user_guid"];
    [params setObject:user.real_name forKey:@"real_name"];
    [params setObject:@(user.sex) forKey:@"sex"];
    [params setObject:user.mobile forKey:@"mobile"];
    [params setObject:user.QQ forKey:@"QQ"];
    [params setObject:user.weixin forKey:@"weixin"];
    [params setObject:user.mood forKey:@"mood"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 工作圈
//转让工作圈
+ (NSURLSessionDataTask*)transCompany:(int)companyNo ownerGuid:(NSString*)ownerGuid toGuid:(NSString*)toGuid handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/transfer";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:ownerGuid forKey:@"owner_userguid"];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:toGuid forKey:@"to_userguid"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//加入工作圈
+ (NSURLSessionDataTask*)joinCompany:(int)companyNo userGuid:(NSString*)userGuid joinReason:(NSString*)joinReason handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/join_company";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:userGuid forKey:@"user_guid"];
    [params setObject:@(companyNo) forKey:@"company_no"];
     [params setObject:joinReason forKey:@"join_reason"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
+ (NSURLSessionDataTask*)createCompany:(NSString*)companyName userGuid:(NSString*)userGuid image:(UIImage*)image companyType:(int)companyType handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/create_company";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:companyName forKey:@"company_name"];
    [params setObject:userGuid forKey:@"user_guid"];
    //把图片压缩 然后弄成data
    [params setObject:image forKey:@"image"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    [params setObject:@(companyType) forKey:@"company_type"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取圈子员工列表
+ (NSURLSessionDataTask*)getEmployeeCompnyNo:(int)companyNo status:(int)status userGuid:(NSString*)userGuid handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/employee_list_new";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(status) forKey:@"status"];
    [params setObject:@(100000) forKey:@"page_size"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    [params setObject:userGuid forKey:@"user_guid"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取用户所在工作圈
+ (NSURLSessionDataTask*)getCompanysUserGuid:(NSString*)userGuid handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/user_companies";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:userGuid forKey:@"user_guid"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//修改工作圈信息
+ (NSURLSessionDataTask*)updateCompany:(int)companyNo companyName:(NSString*)companyName companyType:(int)companyType logo:(NSString*)logo handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/update_company";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(companyType) forKey:@"company_type"];
    [params setObject:companyName forKey:@"company_name"];
    [params setObject:logo forKey:@"logo"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取工作圈列表
+ (NSURLSessionDataTask*)getCompanyList:(NSString*)companyName pageSize:(int)pageSize pageIndex:(int)pageIndex handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/list";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:companyName forKey:@"company_name"];
    [params setObject:@(pageIndex) forKey:@"page_index"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取工作圈创建者信息
+ (NSURLSessionDataTask*)getCompanyOwner:(int)companyNo handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/company_admin_info";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//更新员工状态 如果在圈子中 那么退出圈子都是调的这个方法
+ (NSURLSessionDataTask*)updateEmployeeStatus:(NSString*)employeeGuid status:(int)status reason:(NSString*)reason handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/update_employee_state";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:employeeGuid forKey:@"employee_guid"];
    [params setObject:@(status) forKey:@"status"];
    [params setObject:reason forKey:@"reason"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 讨论组
//获取用户通讯录中的讨论组
+ (NSURLSessionDataTask*)getUserDiscuss:(int)userNo handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/get_discuss_list";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//添加讨论组
+ (NSURLSessionDataTask*)addUserDiscuss:(int)userNo discussId:(NSString*)discussId discussTitle:(NSString*)discussTitle handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/save_discuss_info";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:discussId forKey:@"discuss_id"];
    [params setObject:discussTitle forKey:@"discuss_title"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//删除讨论组
+ (NSURLSessionDataTask*)delUserDiscuss:(int)userNo discussId:(NSString*)discussId handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/delete_discuss";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:discussId forKey:@"discuss_id"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 日程
//创建日程
+ (NSURLSessionDataTask*)createUserCalendar:(Calendar*)calendar handler:(completionHandler)handler {
    NSString *urlPath = @"Calendars/add_v3";
    NSMutableDictionary *params = [@{} mutableCopy];
    [params setObject:@(calendar.company_no) forKey:@"company_no"];
    [params setObject:calendar.event_name forKey:@"event_name"];
    [params setObject:calendar.descriptionStr forKey:@"description"];
    [params setObject:calendar.address forKey:@"address"];
    [params setObject:@(calendar.begindate_utc) forKey:@"begindate_utc"];
    [params setObject:@(calendar.enddate_utc) forKey:@"enddate_utc"];
    [params setObject:@(calendar.is_allday) forKey:@"is_allday"];
    [params setObject:calendar.app_guid forKey:@"app_guid"];
    [params setObject:calendar.target_id forKey:@"target_id"];
    [params setObject:@(calendar.repeat_type) forKey:@"repeat_type"];
    [params setObject:@(calendar.is_alert) forKey:@"is_alert"];
    [params setObject:@(calendar.alert_minutes_before) forKey:@"alert_minutes_before"];
    [params setObject:@(calendar.alert_minutes_after) forKey:@"alert_minutes_after"];
    [params setObject:calendar.user_guid forKey:@"user_guid"];
    [params setObject:calendar.created_by forKey:@"created_by"];
    [params setObject:@(calendar.emergency_status) forKey:@"emergency_status"];
    [params setObject:calendar.rrule forKey:@"rrule"];
    [params setObject:calendar.rdate forKey:@"rdate"];
    [params setObject:@(calendar.r_begin_date_utc) forKey:@"r_begin_date_utc"];
    [params setObject:@(calendar.r_end_date_utc) forKey:@"r_end_date_utc"];
    [params setObject:calendar.members forKey:@"members"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//修改日程
+ (NSURLSessionDataTask*)updateUserCalendar:(Calendar*)calendar handler:(completionHandler)handler {
    NSString *urlPath = @"Calendars/update_v3";
    NSMutableDictionary *params = [@{} mutableCopy];
    [params setObject:@(calendar.company_no) forKey:@"company_no"];
    [params setObject:calendar.event_name forKey:@"event_name"];
    [params setObject:calendar.descriptionStr forKey:@"description"];
    [params setObject:calendar.address forKey:@"address"];
    [params setObject:@(calendar.begindate_utc) forKey:@"begindate_utc"];
    [params setObject:@(calendar.enddate_utc) forKey:@"enddate_utc"];
    [params setObject:@(calendar.is_allday) forKey:@"is_allday"];
    [params setObject:calendar.app_guid forKey:@"app_guid"];
    [params setObject:calendar.target_id forKey:@"target_id"];
    [params setObject:@(calendar.repeat_type) forKey:@"repeat_type"];
    [params setObject:@(calendar.is_alert) forKey:@"is_alert"];
    [params setObject:@(calendar.alert_minutes_before) forKey:@"alert_minutes_before"];
    [params setObject:@(calendar.alert_minutes_after) forKey:@"alert_minutes_after"];
    [params setObject:calendar.user_guid forKey:@"user_guid"];
    [params setObject:calendar.created_by forKey:@"created_by"];
    [params setObject:@(calendar.emergency_status) forKey:@"emergency_status"];
    [params setObject:calendar.rrule forKey:@"rrule"];
    [params setObject:calendar.rdate forKey:@"rdate"];
    [params setObject:@(calendar.r_begin_date_utc) forKey:@"r_begin_date_utc"];
    [params setObject:@(calendar.r_end_date_utc) forKey:@"r_end_date_utc"];
    [params setObject:calendar.members forKey:@"members"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取用户所有日程
+ (NSURLSessionDataTask*)getUserCalendar:(NSString*)userGuid handler:(completionHandler)handler {
    NSString *urlPath = @"Calendars/list_v3";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"1" forKey:@"begin_date"];
    [params setObject:@"1756809030000" forKey:@"end_date"];
    [params setObject:@(1) forKey:@"page_index"];
    [params setObject:@(100000000000) forKey:@"page_size"];
    [params setObject:@"desc" forKey:@"order_by"];
    [params setObject:userGuid forKey:@"user_guid"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 签到
//提交签到信息
+ (NSURLSessionDataTask*)sigin:(SignIn*)sigin handler:(completionHandler)handler {
    NSString *urlPath = @"Attendance/sign";
    NSMutableDictionary *params = [sigin mj_keyValues];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取今天的签到记录
+ (NSURLSessionDataTask*)getSiginList:(int)companyNo employeeGuid:(NSString*)employeeGuid handler:(completionHandler)handler{
    NSString *urlPath = @"Attendance/search_sign_record_list";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSDate *date = [NSDate date];
    NSUInteger dateFirstTime = date.firstTime.timeIntervalSince1970 * 1000;
    NSUInteger dateLastTime = date.lastTime.timeIntervalSince1970 * 1000;
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(dateFirstTime) forKey:@"begin_utc_time"];
    [params setObject:@(dateLastTime) forKey:@"end_utc_time"];
    [params setObject:@(1) forKey:@"page"];
    [params setObject:@(1000) forKey:@"size"];
    [params setObject:@(1) forKey:@"is_asc"];
    [params setObject:employeeGuid forKey:@"employee_guid"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取公司的签到规则
+ (NSURLSessionDataTask*)getSiginRule:(int)companyNo handler:(completionHandler)handler {
    NSString *urlPath = @"Attendance/get_setting_list_v2";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//删除公司签到规则
+ (NSURLSessionDataTask*)deleteSiginRule:(NSString*)settingGuid handler:(completionHandler)handler {
    NSString *urlPath = @"Attendance/delete_setting_v2";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:settingGuid forKey:@"setting_guid"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//更新公司签到规则
+ (NSURLSessionDataTask*)updateSiginRule:(NSDictionary*)siginRule handler:(completionHandler)handler {
    NSString *urlPath = @"Attendance/update_setting_v2";
    NSMutableDictionary *params = [siginRule mutableCopy];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//添加公司签到规则
+ (NSURLSessionDataTask*)addSiginRule:(NSDictionary*)siginRule handler:(completionHandler)handler {
    NSString *urlPath = @"Attendance/setting_v2";
    NSMutableDictionary *params = [siginRule mutableCopy];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取指定年月异常签到记录
+ (NSURLSessionDataTask*)getUsualSigin:(NSString*)userGuid companyNo:(int)companyNo year:(int)year month:(int)month handler:(completionHandler)handler {
    NSString *urlPath = @"Attendance/get_exception_punchcard_records";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:userGuid forKey:@"user_guid"];
    [params setObject:@(year) forKey:@"year"];
    [params setObject:@(month) forKey:@"month"];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
@end
