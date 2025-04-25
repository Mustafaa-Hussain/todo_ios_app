//
//  Task.m
//  Todo List
//
//  Created by JETSMobileLabMini5 on 23/04/2025.
//

#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@implementation Task

- (void)encodeWithCoder:(nonnull NSCoder *)encoder {
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_info forKey:@"info"];
    [encoder encodeObject:_startDate forKey:@"startDate"];
    [encoder encodeObject:_endDate forKey:@"endDate"];
    [encoder encodeInteger:_priority forKey:@"priority"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        _title = [coder decodeObjectOfClass:[NSString class] forKey:@"title"];
        _info = [coder decodeObjectOfClass:[NSString class] forKey:@"info"];
        _startDate = [coder decodeObjectOfClass:[NSDate class] forKey:@"startDate"];
        _endDate = [coder decodeObjectOfClass:[NSDate class] forKey:@"endDate"];
        _priority = [coder decodeIntegerForKey:@"priority"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding{
    return YES;
}

@end

NS_ASSUME_NONNULL_END
