//
//  main.m
//  PrismHelper
//
//  Created by Tomoyuki Sahara on 2/7/16.
//  Copyright © 2016 Tomoyuki Sahara. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PrismHelper.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"PrismHelper started");
        [[[PrismHelper alloc] init] run];
    }
    return 0;
}
