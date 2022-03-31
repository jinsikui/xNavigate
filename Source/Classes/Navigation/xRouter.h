

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol xRouter

-(void)routePath:(NSString*)path params:(NSDictionary<NSString*,NSString*>* __nullable)params;

@end

@protocol xRoutable

-(instancetype)initWithPath:(NSString*)path params:(NSDictionary<NSString*,NSString*>* __nullable)params;

@end

@interface xRouter : NSObject<xRouter>

+(instancetype)shared;

-(void)registPath:(NSString*)path router:(id<xRouter>)router;

-(BOOL)routePath:(NSString*)path params:(NSDictionary<NSString *,NSString *> * _Nullable)params;

@end

NS_ASSUME_NONNULL_END
