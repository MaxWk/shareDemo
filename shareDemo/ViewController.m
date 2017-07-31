//
//  ViewController.m
//  shareDemo
//
//  Created by MAX_W on 16/6/27.
//  Copyright © 2016年 MAX_W. All rights reserved.
//

#import "ViewController.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>

#import <ShareSDKExtension/ShareSDK+Extension.h>

#import "WebViewJavascriptBridge.h"


@interface ViewController ()<UIWebViewDelegate>
{
    UIWebView *vb;
}
@property WebViewJavascriptBridge* bridge;

@end

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated
{
    
//    [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    vb = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20, 375, 667-20 )];
    vb.delegate = self;
    [self.view addSubview:vb];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSURL *url  = [NSURL fileURLWithPath:path];
    // NSURL *url = [[NSURL alloc]initWithString:@"http://www.huami-tech.com/"];
    
    
    //    NSURL *url = [[NSURL alloc]initWithString:@"http://www.huami-tech.com/pan/babywheretogo/main.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    //    NSHTTPURLResponse  *response;
    //    NSError *error;
    //
    //    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    //    NSLog(@"------%@", returnString);
    
    [vb loadRequest:request];
    [(UIScrollView *)[[vb subviews] objectAtIndex:0] setBounces:NO];
    
    if (_bridge) { return; }
    
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:vb];
    [_bridge setWebViewDelegate:self];
    
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self createUI:(NSDictionary *)data];
        responseCallback(@"Response from testObjcCallback");
    }];
    NSString *str = @"ssa";
    [str copy];
    [str mutableCopy];
    


}


- (void)createUI:(NSDictionary *)dict{
    
    /**
     * 在简单分享中，只要设置共有分享参数即可分享到任意的社交平台
     **/
    __weak ViewController *theController = self;
    
    //1、创建分享参数（必要）
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"imageurl"]]];
    
    NSArray* imageArray = @[[UIImage imageWithData:data]];
    [shareParams SSDKSetupShareParamsByText:@"分享内容"
                                     images:imageArray
                                        url:[NSURL URLWithString:[dict objectForKey:@"url"]]
                                      title:[dict objectForKey:@"title"]
                                       type:SSDKContentTypeAuto];
    
    //1.2、自定义分享平台（非必要）
    NSMutableArray *activePlatforms = [NSMutableArray arrayWithArray:[ShareSDK activePlatforms]];
    //添加一个自定义的平台（非必要）
    SSUIShareActionSheetCustomItem *item = [SSUIShareActionSheetCustomItem itemWithIcon:[UIImage imageNamed:@"Icon.png"]
                                                                                  label:@"自定义"
                                                                                onClick:^{
                                                                                    
                                                                                    //自定义item被点击的处理逻辑
                                                                                    NSLog(@"=== 自定义item被点击 ===");
                                                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"自定义item被点击"
                                                                                                                                        message:nil
                                                                                                                                       delegate:nil
                                                                                                                              cancelButtonTitle:@"确定"
                                                                                                                              otherButtonTitles:nil];
                                                                                    [alertView show];
                                                                                }];
    [activePlatforms addObject:item];
    
    //设置分享菜单栏样式（非必要）
    //        [SSUIShareActionSheetStyle setActionSheetBackgroundColor:[UIColor colorWithRed:249/255.0 green:0/255.0 blue:12/255.0 alpha:0.5]];
    //        [SSUIShareActionSheetStyle setActionSheetColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
    //        [SSUIShareActionSheetStyle setCancelButtonBackgroundColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
    //        [SSUIShareActionSheetStyle setCancelButtonLabelColor:[UIColor whiteColor]];
    //        [SSUIShareActionSheetStyle setItemNameColor:[UIColor whiteColor]];
    //        [SSUIShareActionSheetStyle setItemNameFont:[UIFont systemFontOfSize:10]];
    //        [SSUIShareActionSheetStyle setCurrentPageIndicatorTintColor:[UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0]];
    //        [SSUIShareActionSheetStyle setPageIndicatorTintColor:[UIColor colorWithRed:62/255.0 green:62/255.0 blue:62/255.0 alpha:1.0]];
    
    //2、分享
    [ShareSDK showShareActionSheet:self.view
                             items:nil
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   
                   switch (state) {
                           
                       case SSDKResponseStateBegin:
                       {
//                           [theController showLoadingView:YES];
                           break;
                       }
                       case SSDKResponseStateSuccess:
                       {
                           [_bridge callHandler:@"testJavascriptHandler" data:@{ @"result":@"success"}];
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                           [_bridge callHandler:@"testJavascriptHandler" data:@{ @"result":@"failed"}];
                           break;
                       }
                       case SSDKResponseStateCancel:
                       {
                           [_bridge callHandler:@"testJavascriptHandler" data:@{ @"result":@"cancel"}];
                           break;
                       }
                       default:
                           break;
                   }
                   
//                   if (state != SSDKResponseStateBegin)
//                   {
//                       [theController showLoadingView:NO];
//                       [theController.tableView reloadData];
//                   }
                   
               }];
    
    //另附：设置跳过分享编辑页面，直接分享的平台。
    //        SSUIShareActionSheetController *sheet = [ShareSDK showShareActionSheet:view
    //                                                                         items:nil
    //                                                                   shareParams:shareParams
    //                                                           onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
    //                                                           }];
    //
    //        //删除和添加平台示例
    //        [sheet.directSharePlatforms removeObject:@(SSDKPlatformTypeWechat)];
    //        [sheet.directSharePlatforms addObject:@(SSDKPlat
}

@end
