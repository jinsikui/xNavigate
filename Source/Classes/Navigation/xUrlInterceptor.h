

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol xUrlInterceptor <NSObject>

@required
-(BOOL)shouldHandleUrl:(NSString*)url;
///返回true结束处理，false继续处理
-(BOOL)handleUrl:(NSString*)url;

@end

NS_ASSUME_NONNULL_END
