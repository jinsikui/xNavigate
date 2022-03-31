

#import <Foundation/Foundation.h>
#import "xUrlInterceptor.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface xDocumentUrlInterceptor : NSObject<xUrlInterceptor>

///UI附加逻辑，需要子类重写
-(void)loadingInWindow;

///UI附加逻辑，需要子类重写
-(void)hideLoading;

///UI附加逻辑，需要子类重写
-(void)showErrorToast:(NSString*)toast;

@end

NS_ASSUME_NONNULL_END
