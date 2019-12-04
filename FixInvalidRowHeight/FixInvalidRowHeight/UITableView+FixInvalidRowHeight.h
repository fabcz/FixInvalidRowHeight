//
//  UITableView+FixInvalidRowHeight.h
//  FixInvalidRowHeight
//
//  Created by 程聪 on 2019/12/4.
//  Copyright © 2019 程聪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface UITableView (FixInvalidRowHeight)
@end


#pragma mark - QMUI Runtime
// https://github.com/Tencent/QMUI_iOS/blob/master/QMUIKit/QMUICore/QMUIRuntime.h
CG_INLINE BOOL
FixHasOverrideSuperclassMethod(Class targetClass, SEL targetSelector)
{
    Method method = class_getInstanceMethod(targetClass, targetSelector);
    if (!method) return NO;
    
    Method methodOfSuperclass = class_getInstanceMethod(class_getSuperclass(targetClass), targetSelector);
    if (!methodOfSuperclass) return YES;
    
    return method != methodOfSuperclass;
}

CG_INLINE BOOL
FixOverrideImplementation(Class targetClass, SEL targetSelector, id (^implementationBlock)(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)))
{
    Method originMethod = class_getInstanceMethod(targetClass, targetSelector);
    IMP imp = method_getImplementation(originMethod);
    BOOL hasOverride = FixHasOverrideSuperclassMethod(targetClass, targetSelector);
    
    IMP (^originalIMPProvider)(void) = ^IMP(void) {
        IMP result = NULL;
        if (hasOverride) {
            result = imp;
        } else {
            Class superclass = class_getSuperclass(targetClass);
            result = class_getMethodImplementation(superclass, targetSelector);
        }
        
        if (!result) {
            result = imp_implementationWithBlock(^(id selfObject){
                NSLog(([NSString stringWithFormat:@"%@", targetClass]), @"%@ 没有初始实现，%@\n%@", NSStringFromSelector(targetSelector), selfObject, [NSThread callStackSymbols]);
            });
        }
        
        return result;
    };
    
    if (hasOverride) {
        method_setImplementation(originMethod, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)));
    } else {
        if (method_getTypeEncoding(originMethod)) {
            const char *typeEncoding;
            class_addMethod(targetClass, targetSelector, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)), typeEncoding);
        } else {
            NSMethodSignature *methodSignature = [targetClass instanceMethodSignatureForSelector:targetSelector];
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSString *typeString = [methodSignature performSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@String", @"type"])];
            #pragma clang diagnostic pop
            class_addMethod(targetClass, targetSelector, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)), typeString.UTF8String);
        }
    }
    
    return YES;
}
