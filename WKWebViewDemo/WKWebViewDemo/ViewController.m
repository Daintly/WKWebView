//
//  ViewController.m
//  WKWebViewDemo
//
//  Created by renwen on 2018/8/23.
//  Copyright © 2018年 Dainty. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "NSString+EXtension.h"
#define POST_JS @"function my_post(path, params) {\
var method = \"POST\";\
var form = document.createElement(\"form\");\
form.setAttribute(\"method\", method);\
form.setAttribute(\"action\", path);\
for(var key in params){\
if (params.hasOwnProperty(key)) {\
var hiddenFild = document.createElement(\"input\");\
hiddenFild.setAttribute(\"type\", \"hidden\");\
hiddenFild.setAttribute(\"name\", key);\
hiddenFild.setAttribute(\"value\", params[key]);\
}\
form.appendChild(hiddenFild);\
}\
document.body.appendChild(form);\
form.submit();\
}"
@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation ViewController{
    WKUserContentController *userContentController ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, 2)];
    self.progressView.backgroundColor = [UIColor blueColor];
    //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.2f);
    [self.view addSubview:self.progressView];

    userContentController = [[WKUserContentController alloc] init];
    
     //第一个参数是userContentController的代理对象，第二个参数是JS里发送postMessage的对象。
    [userContentController addScriptMessageHandler:self name:@"NativeMethod"];
    
    config.userContentController = userContentController;
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    
    [self.view addSubview:self.webView];
    //自定义UserAgent值，常用于区分是本地APP还是浏览器
    NSString *customUserAgent = @"iPhone";
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":customUserAgent}];
    [self.webView setCustomUserAgent:customUserAgent];
    self.webView.navigationDelegate = self;

    self.webView.UIDelegate = self;
    
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
//    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"WKWebViewHandler" ofType:@"html"];
//    NSString *fileURL = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//  //  [self.webView loadHTMLString:fileURL baseURL:nil];
//
//    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.jianshu.com/p/d3c8ba672760"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
//    [self.webView loadRequest:request];
//    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cleanCache)];
//    self.navigationItem.leftBarButtonItem = item;
//
//    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"user"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*清除缓存测试中
- (void)cleanCache{
    
    // 清除所有
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    //// Date from
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    //// Execute
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        // Done
        NSLog(@"清楚缓存完毕");

        NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES)[0];
        NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        //内存
        NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
        //磁盘
        NSString *webKitFolderInCaches = [NSString stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
        
        NSLog(@"%ld  --- %ld",[NSString fileSizeAtPath:webkitFolderInLib] ,[NSString fileSizeAtPath:webKitFolderInCaches] );
//        double filesize = [NSString getFileSize:webkitFolderInLib] + [NSString getFileSize:webKitFolderInCaches];
     //   NSLog(@"%f",filesize);
        
    }];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
   
    

}
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    // 此方法可以禁止长按图片弹出效果
    [self.webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES)[0];
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    //内存
    NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
    
    NSLog(@"%@",webkitFolderInLib);
    //磁盘
    NSString *webKitFolderInCaches = [NSString stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
        NSLog(@"%@",webKitFolderInCaches);
    double t = [NSString fileSizeAtPath:webkitFolderInLib] ;
        double d = [NSString fileSizeAtPath:webKitFolderInCaches];
    NSLog(@"%f  --- %f",t ,d);

}
//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}



//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败");
    //加载失败同样需要隐藏progressView
    self.progressView.hidden = YES;
}




#pragma mark KVO监听代理  监听加载进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
      if ([keyPath isEqualToString:@"title"]) {
          
              self.title = self.webView.title;
      }

 else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (self.webView.estimatedProgress == 1.0) {
            
            self.progressView.progress = self.webView.estimatedProgress;
            if (self.progressView.progress == 1) {
                [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                } completion:^(BOOL finished) {
                    self.progressView.hidden = YES;
                    
                }];
            }
        }

    }
}

#pragma mark 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    
    if ([url.absoluteString rangeOfString:@"https://github.com/Daintly/DYKit.git"].length > 0) {
        
        /*
         *注入js代码，发送post请求
         ***/
        NSString *token = @"测试";
        NSString *jsonParam = [NSString stringWithFormat:@"{\"token\":\"%@\"}",token];
        
        NSString *js = [NSString stringWithFormat:@"%@my_post(\"%@\",%@)",POST_JS,url,jsonParam];
        
        [webView evaluateJavaScript:js completionHandler:nil];

          decisionHandler(WKNavigationActionPolicyCancel);
    }else{
              decisionHandler(WKNavigationActionPolicyAllow);
    }

   
}



/**
 *  JS 调用 OC 时 webview 会调用此方法 ,在此处拦截
 
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSString *messageName = message.name;

    NSDictionary * responseJSON;
    if ([@"NativeMethod" isEqualToString:messageName]) {
        
        if ([message.body isKindOfClass:[NSDictionary class]]) {
            responseJSON = message.body;
        }else if ([message.body isKindOfClass:[NSString class]]){
            NSData *jsondata = [message.body dataUsingEncoding:NSUTF8StringEncoding];
            responseJSON = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableContainers error:nil];
        }
        if ([responseJSON[@"type"] isEqualToString:@"share"]) {
            //调用分享界面
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:responseJSON[@"title"] message:responseJSON[@"url"] preferredStyle:UIAlertControllerStyleAlert];
                        [self presentViewController:alert animated:YES completion:nil];
                        //控制提示框显示的时间为2秒
                        [self performSelector:@selector(dismiss:) withObject:alert afterDelay:2.0];
            
        }else if ([responseJSON[@"type"] isEqualToString:@"shareimg"]){
            //防止不是图片的时候，自己生成一个二维码
           [self saveImgWithString:responseJSON[@"url"]];
        }
   
    }
 
}

- (void)saveImgWithString:(NSString *)string{
    NSString *str = string;
 
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"提示" preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        //创建一个二维码种类的滤镜
        //CIQRCodeGenerator 不能错
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        //恢复滤镜的默认设置  （清除已经设置过的效果）
        [filter setDefaults];
        
        //将 data 数据交给 滤镜进行过滤
        //inputMessage 该属性是私有的 如果需要修改该私有属性需要时 KVC
        //    filter.inputMessage = data;
        [filter setValue:data forKey:@"inputMessage"];
        
        //通过滤镜 输出 二进制数据对应的二维码图片
        CIImage *ciImage = [filter outputImage];
        //将CIImage 转换成 UIImage
        
        UIImage *img = [self createNonInterpolatedUIImageFormCIImage:ciImage withSize:170];

        [strongSelf saveImage:img];

    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"识别二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));

    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);

    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}


//image是要保存的图片
- (void) saveImage:(UIImage *)image{
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    };
}
//保存完成后调用的方法
- (void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        NSLog(@"保存图片出错%@", error.localizedDescription);

    }
    else {
        NSLog(@"保存图片成功");

    }
}


/** 弹出框2s后消失 */
- (void)dismiss:(UIAlertController *)alert {
    
    if(alert){

        [alert dismissViewControllerAnimated:YES completion:nil];
        
    }

    
}

/*
 *下面三个方法是解决js端alert,oc端不弹出
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
   
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
       [self.webView removeObserver:self forKeyPath:@"title"];
}

@end
