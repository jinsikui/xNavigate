

#import "xRouter.h"
#import <UIKit/UIKit.h>

@interface xRouter()

@property(nonatomic,strong) NSMutableDictionary<NSString*, id<xRouter>> *routeTable;

@end

@implementation xRouter

+(instancetype)shared{
    static xRouter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[xRouter alloc] init];
    });
    return instance;
}

-(instancetype)init{
    self = [super init];
    if(self){
        _routeTable = [NSMutableDictionary new];
    }
    return self;
}

-(void)registPath:(NSString*)path router:(id<xRouter>)router{
    _routeTable[path] = router;
}

-(BOOL)routePath:(NSString*)path params:(NSDictionary<NSString *,NSString *> * _Nullable)params{
    id<xRouter> router = _routeTable[path];
    if(router){
        [router routePath:path params:params];
        return true;
    }
    else{
        return false;
    }
}

@end
