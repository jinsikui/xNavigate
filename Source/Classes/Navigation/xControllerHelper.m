

#import "xControllerHelper.h"

@implementation xControllerHelper

+(instancetype)shared{
    static xControllerHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[xControllerHelper alloc] init];
    });
    return instance;
}

-(UIWindow*)window{
    return UIApplication.sharedApplication.delegate.window;
}

-(UIViewController*)rootViewController{
    return self.window.rootViewController;
}

-(UIViewController*)curViewController{
    xCurrentControllerProvider provider = self.curControllerProvider;
    if(provider){
        return provider();
    }
    else{
        return [self _curVcFromRootVc:self.rootViewController];
    }
}

-(UIViewController*)_curVcFromRootVc:(UIViewController*)rootVc{
    if(rootVc != nil){
        UIViewController *curVC = nil;
        UIViewController *presentedVC = rootVc.presentedViewController;
        if(presentedVC){
            rootVc = presentedVC;
        }
        if([rootVc isKindOfClass:UITabBarController.class]){
            curVC = [self _curVcFromRootVc:((UITabBarController*)rootVc).selectedViewController];
        }
        else if([rootVc isKindOfClass:UINavigationController.class]){
            curVC = [self _curVcFromRootVc:((UINavigationController*)rootVc).visibleViewController];
        }
        else{
            curVC = rootVc;
        }
        return curVC;
    }
    else{
        return nil;
    }
}

-(UINavigationController*)curNavController{
    return self.curViewController.navigationController;
}

@end
