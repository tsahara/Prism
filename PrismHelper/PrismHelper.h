//
//  PrismHelper.h
//  Prism
//
//  Created by Tomoyuki Sahara on 2016/12/07.
//  Copyright © 2016 Tomoyuki Sahara. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PrismHelperProtocol

@required

- (void)getVersion:(void(^)(NSString * version))reply;

- (void)openBPF:(void(^)(int))reply;

@end


@interface PrismHelper : NSObject

- (id)init;

- (void)run;


@end
