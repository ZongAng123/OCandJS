//
//  ViewController.m
//  OCandJS
//
//  Created by ios  on 2019/8/14.
//  Copyright © 2019 纵昂. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
//1.HTML 要标记添加标记电话代码  2.WKWebView 调用 <WKNavigationDelegate> 代理
@interface ViewController ()<WKNavigationDelegate, WKUIDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *wkWebView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences.minimumFontSize = 50;
    
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) configuration:config];
    [self.view addSubview:self.wkWebView];
    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate = self;
    
//    https://m.benlai.com/huanan/zt/1231cherry
//    http://47.105.214.158:8081/h5/service.jsp
    NSURL *url = [NSURL URLWithString:@"http://47.105.214.158:8081/h5/service.jsp"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.wkWebView loadRequest:request];
    WKUserContentController *userCC = config.userContentController;
    [userCC addScriptMessageHandler:self name:@"showToast"]; //showMessage showToast
    
    
}

#pragma mark - WKNavigationDelegate
//加载完成网页的时候才开始注入JS代码,要不然还没加载完时就可以点击了,就不能调用我们的代码了!
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"data.txt" ofType:nil];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.wkWebView evaluateJavaScript:str completionHandler:nil];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"11---%@",NSStringFromSelector(_cmd));
    NSLog(@"message--%@",message);
    NSLog(@"message.body--%@",message.body);
    NSLog(@"message.name--%@",message.name);
    
    UIApplication *app = [UIApplication sharedApplication];
    //这个是注入JS代码后的处理效果,尽管html已经有实现了,但是没用,还是执行JS中的实现
    if ([message.name isEqualToString:@"showToast"]) {  //showMessage    showToast
        
        NSString *arrayStr = message.body;
        NSString *str = [NSString stringWithFormat:@"tel://%@",arrayStr]; //拨打电话
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        
        //        [self showMsg:str];
    }

}
/****************以下方法均没有用到*****************************************************/
#pragma mark - private
//- (void)showMsg:(NSString *)msg {
//    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
////    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNumber]]];
//
//}

#pragma mark - 3.实现代理方法   js页面拨打电话   处理拨打电话以及Url跳转等等    showToast  客服电话:400-090-8851
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    //    NSString *telNumber = [NSString stringWithFormat:@"tel:%@", @"88888888"];
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *URL = navigationAction.request.URL;
    //        NSURL *URL = [NSURL URLWithString:telNumber];
    
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:@"showToast"]) {
        if ([app canOpenURL:URL]) {
            CGFloat version = [[[UIDevice currentDevice]systemVersion]floatValue];
            if (version >= 10.0) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication]openURL:URL options:@{} completionHandler:nil];
                } else {
                    // Fallback on earlier versions
                }
            }else{
                
            }
        }
        NSString *resourceSpecifier = [URL resourceSpecifier];
        NSString *callPhone = [NSString stringWithFormat:@"tel://%@", resourceSpecifier];
        /// 防止iOS 10及其之后，拨打电话系统弹出框延迟出现
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
        });
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
