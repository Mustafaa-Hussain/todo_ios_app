//
//  TaskDetailsViewController.m
//  Todo List
//
//  Created by JETSMobileLabMini5 on 23/04/2025.
//

#import "TaskDetailsViewController.h"
#import "Task.h"

@interface TaskDetailsViewController ()
@property NSUserDefaults *defaults;
@property (weak, nonatomic) IBOutlet UILabel *screenTitle;
@property (weak, nonatomic) IBOutlet UITextField *titleInputField;
@property (weak, nonatomic) IBOutlet UITextView *infoInputField;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDateInput;
@property (weak, nonatomic) IBOutlet UISegmentedControl *priorityInput;
@property (weak, nonatomic) IBOutlet UILabel *statusTitle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statusInput;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@end

@implementation TaskDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaults = [NSUserDefaults standardUserDefaults];
    
    //in case if we add new task
    if(_status == 0){
        _screenTitle.text = @"New Task";
        [_statusTitle setHidden:YES];
        [_statusInput setHidden:YES];
        _endDateInput.minimumDate = [NSDate date];
    }
    else{
        _titleInputField.text = _tasks[_taskIndex].title;
        _infoInputField.text = _tasks[_taskIndex].info;
        _endDateInput.date = _tasks[_taskIndex].endDate;
        _endDateInput.minimumDate = _tasks[_taskIndex].endDate;
        _priorityInput.selectedSegmentIndex = _tasks[_taskIndex].priority;
        _statusInput.selectedSegmentIndex = _status - 1;
        if(_status == 3){
            [_titleInputField setEnabled:NO];
            [_infoInputField setEditable:NO];
            [_priorityInput setEnabled:NO];
            [_statusInput setEnabled:NO];
            [_endDateInput setEnabled:NO];
            [_saveButton setTitle:@"OK" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)saveTask:(id)sender {
    //save task based on status
    switch (_status) {
        case 0:
            //0 add new task
            if([self saveNewTask]){
                [_refresh refresh];
                [self dismissViewControllerAnimated:YES completion:^{
                    nil;
                }];
            }
            break;
        default:
            if([self updateTask: _status - 1]){
                [_refresh refresh];
                [self dismissViewControllerAnimated:YES completion:^{
                    nil;
                }];
            }
            break;
    }
}

-(BOOL) updateTask: (NSInteger) status{
    BOOL isDataUpdated = NO;
    if(status == _statusInput.selectedSegmentIndex){
        _tasks[_taskIndex].title =[_titleInputField.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        _tasks[_taskIndex].info = [_infoInputField.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        _tasks[_taskIndex].endDate = [_endDateInput date];
        
        _tasks[_taskIndex].priority = [_priorityInput selectedSegmentIndex];
        
        switch (status) {
            case 0:
                isDataUpdated = [self updateCurrentListToFile: @"todo"];
                break;
            case 1:
                isDataUpdated = [self updateCurrentListToFile: @"doing"];
                break;
            case 2:
                isDataUpdated = [self updateCurrentListToFile: @"done"];
                break;
        }
        
    }else{
        isDataUpdated = [self moveToOtherState];
    }
    
    return isDataUpdated;
}

-(BOOL) moveToOtherState{
    BOOL isDataUpdated = NO;
    if(_statusInput.selectedSegmentIndex == _status){
        isDataUpdated = YES;
        //remove from current array
        [_tasks removeObject:_tasks[_taskIndex]];
        switch (_status-1) {
            case 0:
                [self updateCurrentListToFile:@"todo"];
                break;
            case 1:
                [self updateCurrentListToFile:@"doing"];
                break;
        }
        
        
        //save to new array
        switch (_statusInput.selectedSegmentIndex) {
            case 1:
                [self moveToOtherState: @"doing"];
                break;
            case 2:
                [self moveToOtherState: @"done"];
                break;
        }
        
    }else{
        //display alert
        //you cant move to this state
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid move" message:@"You can't move to this state!" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            nil;
        }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:^{
            nil;
        }];
    }
    
    return isDataUpdated;
}

-(void) moveToOtherState: (NSString*)fileName{
    if(![self isValidInputData]){
        //show alert that the data is invalid
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid input data" message:@"You must fill title and task information!" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            nil;
        }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:^{
            nil;
        }];
    }else{
        
        Task *task = [Task new];
        task.title = [_titleInputField.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        task.info = [_infoInputField.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        task.startDate = [NSDate date];
        task.endDate = [_endDateInput date];
        
        task.priority = [_priorityInput selectedSegmentIndex];
        
        //get old list
        NSError *error;
        NSData *savedTasks = [_defaults objectForKey:fileName];
        NSSet *set = [
            NSSet setWithArray:@[
                [NSMutableArray class],
                [Task class]]
        ];
        NSMutableArray *todoTasks = (NSMutableArray*)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedTasks error: &error];
        if(todoTasks == NULL){
            todoTasks = [NSMutableArray new];
        }
        
        //save to file
        [todoTasks addObject:task];
        
        NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:todoTasks requiringSecureCoding:YES error:&error];
        
        [_defaults setObject:archiveData forKey:fileName];
        
        
    }
}



-(BOOL) updateCurrentListToFile: (NSString*) fileName{
    BOOL isDataUpdatd = NO;
    if(![self isValidInputData]){
        //show alert that the data is invalid
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid input data" message:@"You must fill title and task information!" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            nil;
        }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:^{
            nil;
        }];
    }else{
        isDataUpdatd = YES;
        NSError *error;
        
        NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:_tasks requiringSecureCoding:YES error:&error];
        
        [_defaults setObject:archiveData forKey:fileName];
    }
    return isDataUpdatd;
}

-(BOOL) saveNewTask{
    BOOL isSaved = NO;
    //validate data
    if(![self isValidInputData]){
        //show alert that the data is invalid
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid input data" message:@"You must fill title and task information!" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            nil;
        }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:^{
            nil;
        }];
    }else{
        //save it in userDefaults
        
        //prepare task opject
        Task *task = [Task new];
        task.title = [_titleInputField.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        task.info = [_infoInputField.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        task.startDate = [NSDate date];
        task.endDate = [_endDateInput date];
        
        task.priority = [_priorityInput selectedSegmentIndex];
        
        //get old list
        NSError *error;
        NSData *savedTodos = [_defaults objectForKey:@"todo"];
        NSSet *set = [
            NSSet setWithArray:@[
                [NSMutableArray class],
                [Task class]]
        ];
        NSMutableArray *todoTasks = (NSMutableArray*)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedTodos error: &error];
        if(todoTasks == NULL){
            todoTasks = [NSMutableArray new];
        }
        
        //save to file
        [todoTasks addObject:task];
        
        NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:todoTasks requiringSecureCoding:YES error:&error];
        
        [_defaults setObject:archiveData forKey:@"todo"];
        
        isSaved = YES;
    }
    
    return isSaved;
}

-(BOOL) isValidInputData{
    BOOL isValid = YES;
    if([[_titleInputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqual:@""]){
        isValid = NO;
    }
    
    if([[_infoInputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqual:@""]){
        isValid = NO;
    }
    
    return isValid;
}


@end
