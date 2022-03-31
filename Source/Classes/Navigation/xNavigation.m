

#import "xNavigation.h"
#import "xRouter.h"
#import "xControllerHelper.h"

@interface xNavigation()

@property(nonatomic,readwrite) NSMutableArray<xUrlInterceptor>  *urlInterceptors;

@end

@implementation xNavigation

-(instancetype)init{
    self = [super init];
    if(self){
        _urlInterceptors = [NSMutableArray<xUrlInterceptor> new];
    }
    return self;
}
-(UIWindow*)window{
    return xControllerHelper.shared.window;
}

-(UIViewController*)rootViewController{
    return xControllerHelper.shared.rootViewController;
}

-(UIViewController*)curViewController{
    return xControllerHelper.shared.curViewController;
}

-(UINavigationController*)curNavController{
    return xControllerHelper.shared.curNavController;
}

-(void)back{
    [self backWithAnimated:true completion:nil];
}

-(void)backWithAnimated:(BOOL)animated completion:(void(^_Nullable)(void))completion{
    UIViewController *curVc = self.curViewController;
    if(!curVc){
        return;
    }
    UINavigationController *navVc = curVc.navigationController;
    if(navVc){
        if(navVc.viewControllers.count > 1){
            [navVc popViewControllerAnimated:animated];
            if(completion){
                completion();
            }
        }
        else{
            [curVc dismissViewControllerAnimated:animated completion:completion];
        }
    }
    else{
        [curVc dismissViewControllerAnimated:animated completion:completion];
    }
}

-(void)push:(UIViewController*)controller{
    [self push:controller animated:true];
}

-(void)push:(UIViewController*)controller animated:(BOOL)animated{
    [self.curNavController pushViewController:controller animated:animated];
}

-(void)present:(UIViewController*)controller{
    [self present:controller animated:true completion:nil];
}

-(void)present:(UIViewController*)controller animated:(BOOL)animated completion:(void(^)(void))completion{
    [self.curNavController presentViewController:controller animated:animated completion:completion];
}

//后添加的先处理
-(void)addUrlInterceptor:(id<xUrlInterceptor>)interceptor{
    [_urlInterceptors insertObject:interceptor atIndex:0];
}

-(BOOL)shouldHandleUrl:(NSString *)url{
    for(id<xUrlInterceptor> interceptor in _urlInterceptors){
        if([interceptor shouldHandleUrl:url]){
            return true;
        }
    }
    if([self isSchemeUrl:url]){
        return true;
    }
    return false;
}

-(BOOL)handleUrl:(NSString *)url{
    [self routeUrl:url];
    return true;
}

-(BOOL)routeUrl:(NSString*)url{
    for(id<xUrlInterceptor> interceptor in _urlInterceptors){
        if([interceptor shouldHandleUrl:url]){
            BOOL isDone = [interceptor handleUrl:url];
            if(isDone){
                return true;
            }
        }
    }
    if([self isSchemeUrl:url]){
        NSString *path = [self pathFor:url] ?: @"";
        NSDictionary<NSString*, NSString*> *params = [self paramsFor:url];
        return [self routeScheme:path params:params];
    }
    if([self isH5Url:url]){
        return [self routeWebView:url];
    }
    return false;
}

//需要子类重写
-(BOOL)isSchemeUrl:(NSString*)url{
    return false;
}

-(BOOL)isH5Url:(NSString*)url{
    return [self startWith:@"http://" urlString:url]||[self startWith:@"https://" urlString:url];
}

-(void)registScheme:(NSString*)path router:(id<xRouter>)router{
    [xRouter.shared registPath:path router:router];
}

-(void)registScheme:(NSString*)path action:(void(^)(NSString* path, NSDictionary<NSString*,NSString*>* __nullable params))handler{
    xActionRouter *r = [xActionRouter new];
    r.callback = handler;
    [xRouter.shared registPath:path router:r];
}

-(void)registScheme:(NSString*)path controllerClass:(Class)controllerClass{
    xControllerRouter *r = [xControllerRouter new];
    r.controllerClass = controllerClass;
    __weak typeof(self) weak = self;
    r.pushCallback = ^(UIViewController * _Nonnull controller) {
        [weak push:controller];
    };
    [xRouter.shared registPath:path router:r];
}

-(BOOL)routeScheme:(NSString*)path params:(NSDictionary<NSString*,NSString*>* __nullable)params{
    return [xRouter.shared routePath:path params:params];
}

//需要子类重写
-(BOOL)routeWebView:(NSString*)url{
    //do nothing
    return false;
}
#pragma mark - 补充方法
-(BOOL)startWith:(NSString*)str urlString:(NSString *)urlString{
    NSRange range = [urlString rangeOfString:str options:NSLiteralSearch];
    return range.location == 0;
}
-(NSString*)pathFor:(NSString*)url{
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    return components.path;
}

-(NSDictionary<NSString*, NSString*>*)paramsFor:(NSString*)url{
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    NSArray<NSURLQueryItem*> *items = components.queryItems;
    if(items){
        NSMutableDictionary<NSString*, NSString*> *dic = [NSMutableDictionary new];
        [self eachArray:items action:^(NSURLQueryItem *item) {
            dic[item.name] = [self urlDecode:(item.value ?: @"")];
        }];
        return dic;
    }
    else{
        return nil;
    }
}
-(NSString*)urlDecode:(NSString*)input{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByRemovingPercentEncoding];
}
-(void)eachArray:(NSArray *)array action:(void (^)(id))action {
    if (!action) return;
    for (id item in array) {
        action(item);
    }
}


@end


@implementation xControllerRouter

-(void)routePath:(NSString*)path params:(NSDictionary<NSString*,NSString*>*)params{
    if([self.controllerClass conformsToProtocol:@protocol(xRoutable)] && [self.controllerClass isSubclassOfClass:UIViewController.class]){
        UIViewController *controller = [(UIViewController<xRoutable>*)[self.controllerClass alloc] initWithPath:path params:params];
        xControllerRouterPushCallback pushCallback = self.pushCallback;
        if(pushCallback){
            pushCallback(controller);
        }
    }
}
@end


@implementation xActionRouter

-(void)routePath:(NSString*)path params:(NSDictionary<NSString*,NSString*>*)params{
    xActionRouterCallback callback = self.callback;
    if(callback){
        callback(path, params);
    }
}

@end
