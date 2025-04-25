//
//  Task.h
//  Todo List
//
//  Created by JETSMobileLabMini5 on 23/04/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Task : NSObject<NSCoding, NSSecureCoding>
@property NSString *title;
@property NSString *info;
@property NSDate *startDate;
@property NSDate *endDate;
@property NSInteger priority;//0 low, 1 mid, 2 high


-(void) encodeWithCoder: (NSCoder *) encoder;
@end

NS_ASSUME_NONNULL_END
