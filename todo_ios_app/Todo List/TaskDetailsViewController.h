//
//  TaskDetailsViewController.h
//  Todo List
//
//  Created by JETSMobileLabMini5 on 23/04/2025.
//

#import <UIKit/UIKit.h>
#import "RefreshSource.h"
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaskDetailsViewController : UIViewController
//0 new task, 1 todo task, 2 doing task, 3 done task
@property NSInteger status;
@property id<RefreshSource> refresh;
@property NSInteger taskIndex;
@property NSMutableArray<Task *> *tasks;
@end

NS_ASSUME_NONNULL_END
