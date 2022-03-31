

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "xUrlInterceptor.h"
#import "xRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface xNavigation : NSObject<xUrlInterceptor>

@property(nonatomic,readonly) UIWindow    *window;
@property(nonatomic,readonly) UIViewController  *rootViewController;
@property(nonatomic,readonly) UIViewController  *curViewController;
@property(nonatomic,readonly,nullable)  UINavigationController  *curNavController;

-(void)back;
-(void)backWithAnimated:(BOOL)animated completion:(void(^_Nullable)(void))completion;
-(void)push:(UIViewController*)controller;
-(void)push:(UIViewController*)controller animated:(BOOL)animated;
-(void)present:(UIViewController*)controller;
-(void)present:(UIViewController*)controller animated:(BOOL)animated completion:(void(^__nullable)(void))completion;

@property(nonatomic,readonly) NSArray<xUrlInterceptor>  *urlInterceptors;
///后添加的先处理
-(void)addUrlInterceptor:(id<xUrlInterceptor>)interceptor;
///子类需要重写isSchemeUrl:url方法才能用本方法跳转scheme
///子类需要重写routeWebView:url方法才能用本方法跳转webView页面
-(BOOL)routeUrl:(NSString*)url;
///需要子类重写，本类中恒返回false
-(BOOL)isSchemeUrl:(NSString*)url;
-(BOOL)isH5Url:(NSString*)url;
-(void)registScheme:(NSString*)path action:(void(^)(NSString* path, NSDictionary<NSString*,NSString*>* __nullable params))handler;
-(void)registScheme:(NSString*)path controllerClass:(Class)controllerClass;
-(void)registScheme:(NSString*)path router:(id<xRouter>)router;
-(BOOL)routeScheme:(NSString*)path params:(NSDictionary<NSString*,NSString*>* __nullable)params;
///需要子类重写，本类中是空函数
-(BOOL)routeWebView:(NSString*)url;

@end


typedef void(^xControllerRouterPushCallback)(UIViewController*);

@interface xControllerRouter : NSObject<xRouter>
///controllerClass should be kind of UIViewController and conform to protocol xRoutable
@property(nonatomic) Class controllerClass;
@property(nonatomic,copy) xControllerRouterPushCallback pushCallback;
@end


typedef void(^xActionRouterCallback)(NSString*, NSDictionary<NSString*,NSString*>* __nullable);

@interface xActionRouter : NSObject<xRouter>
@property(nonatomic,copy) xActionRouterCallback callback;
@end

NS_ASSUME_NONNULL_END
