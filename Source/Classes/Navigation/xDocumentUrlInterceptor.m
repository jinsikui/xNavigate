

#import "xDocumentUrlInterceptor.h"
#import "xControllerHelper.h"
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif


@interface xDocumentUrlInterceptor()<UIDocumentInteractionControllerDelegate>

@end

@implementation xDocumentUrlInterceptor

///UI附加逻辑，需要子类重写
-(void)loadingInWindow{}

///UI附加逻辑，需要子类重写
-(void)hideLoading{}

///UI附加逻辑，需要子类重写
-(void)showErrorToast:(NSString*)toast{}

-(BOOL)shouldHandleUrl:(NSString*)url{
    return  [self endWith:@".doc" urlString:url] || [self endWith:@".docx" urlString:url] || [self endWith:@".xls" urlString:url]  || [self endWith:@".xlsx" urlString:url]  || [self endWith:@".ppt" urlString:url]  || [self endWith:@".pptx" urlString:url]  || [self endWith:@".pdf" urlString:url];
}

///返回true结束处理，false继续处理
-(BOOL)handleUrl:(NSString*)url{
    [self loadingInWindow];
    //下载配置文件并保存
    //用downloadTask
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response){
            NSURLComponents *comp = [[NSURLComponents alloc] initWithString:url];
            NSString *path = comp.path;
            NSString *name = path.lastPathComponent;
            return [NSURL fileURLWithPath:[self tmpPath:name]];
        }
        completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error){
            if(error){
                [self hideLoading];
                [self showErrorToast:@"下载文档失败"];
            }
            else{
                [self hideLoading];
                UIDocumentInteractionController *docInter = [UIDocumentInteractionController interactionControllerWithURL:filePath];
                docInter.delegate = self;
                [docInter presentPreviewAnimated:true];
            }
        }];
    [downloadTask resume];
    return true;
}

#pragma mark - 补充方法

-(NSString *)tmpPath:(NSString *)filename {
    NSString *tempPath = NSTemporaryDirectory();
    return [tempPath stringByAppendingPathComponent:filename];
}
-(BOOL)endWith:(NSString*)str urlString:(NSString *)urlString{
    NSRange range = [urlString rangeOfString:str options:NSLiteralSearch | NSBackwardsSearch];
    return range.location == urlString.length - str.length;
}

-(void)showLoading{
    
}
#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return xControllerHelper.shared.curViewController;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller{
    return xControllerHelper.shared.curViewController.view.bounds;
}

- (nullable UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller{
    return xControllerHelper.shared.curViewController.view;
}


@end
