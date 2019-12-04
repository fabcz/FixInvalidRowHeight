//
//  UITableView+FixInvalidRowHeight.m
//  FixInvalidRowHeight
//
//  Created by 程聪 on 2019/12/4.
//  Copyright © 2019 程聪. All rights reserved.
//

#import "UITableView+FixInvalidRowHeight.h"


@implementation UITableView (FixInvalidRowHeight)
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FixOverrideImplementation(object_getClass(NSException.class), @selector(raise:format:arguments:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            
            return ^(NSException *selfObject, NSExceptionName raise, NSString *format, va_list argList) {
                
                if (raise == NSInternalInconsistencyException &&
                    [format containsString:@"Invalid row height"] &&
                    [format containsString:@"provided by table delegate. Value must be at least 0.0, or UITableViewAutomaticDimension"]) {
                    
                    NSLog(@"%@",format);
                    
                    // iOS13 如果 tableView:heightForRowAtIndexPath: 返回负数会导致崩溃，这里将 exception return 掉
                    // 经测试假如该代理方法一直返回都是负数，那么会导致系统递归调用 layoutSubview 来获取正确的高度，最终因内存溢出而崩溃
                    // 这种暂没法进行防护，只是将原来的直接崩溃改为卡顿然后崩溃
                    
                    // 但对于项目排查出的大部分业务场景来说，都是因为初始化的时候布局为 0 导致计算出来的负数，但再次进行 layoutSubview 的时候就能拿到正确的值了

                    // TODO 这里将错误上报到自己的崩溃收集平台(如 bugly)然后解决问题，忽略崩溃并不是本意，意在收集问题然后进行解决
                    // [Bugly reportException:selfObject];
                    return;
                }
                
                void (*originSelectorIMP)(id, SEL, NSExceptionName name, NSString *, va_list);
                originSelectorIMP = (void (*)(id, SEL, NSExceptionName name, NSString *, va_list))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, raise, format, argList);
            };
        });
    });
}
#endif
@end
