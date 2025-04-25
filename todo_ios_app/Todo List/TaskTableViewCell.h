//
//  TaskTableViewCell.h
//  Todo List
//
//  Created by JETSMobileLabMini5 on 23/04/2025.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *taskImage;
@property (weak, nonatomic) IBOutlet UILabel *taskTitle;
@end

NS_ASSUME_NONNULL_END
