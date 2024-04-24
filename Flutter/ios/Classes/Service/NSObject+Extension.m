//
//  Created by vincepzhang
//  Copyright (c) 2022 Tencent. All rights reserved.
//

#import "NSObject+Extension.h"
@implementation NSObject (Extension)

+ (void)load {
#pragma GCC diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(swiftLoad)]) {
        [self performSelector:@selector(swiftLoad)];
    }
}
@end
