

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef  UIViewController* _Nonnull (^xCurrentControllerProvider)(void);

@interface xControllerHelper : NSObject

+(instancetype)shared;
///如果没设置这个，会用默认的逻辑找
@property(nonatomic,copy) xCurrentControllerProvider curControllerProvider;
@property(nonatomic,readonly) UIWindow    *window;
@property(nonatomic,readonly) UIViewController  *rootViewController;
@property(nonatomic,readonly) UIViewController  *curViewController;
@property(nonatomic,readonly,nullable)  UINavigationController  *curNavController;

@end

NS_ASSUME_NONNULL_END
