//
//  DoingTasksViewController.m
//  Todo List
//
//  Created by JETSMobileLabMini5 on 23/04/2025.
//

#import "DoingTasksViewController.h"
#import "Task.h"
#import "TaskTableViewCell.h"
#import "TaskDetailsViewController.h"

@interface DoingTasksViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSUserDefaults *defaults;
@property NSMutableArray <Task *> *doingTasks;
@property NSMutableArray <Task *>*lowTasks;
@property NSMutableArray <Task *>*medumTasks;
@property NSMutableArray <Task *>*highTasks;
@property BOOL isFilterd;
@end

@implementation DoingTasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaults = [NSUserDefaults standardUserDefaults];
    _doingTasks = [NSMutableArray new];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    _isFilterd = YES;
    
    NSError *error;
    NSData *savedTodos = [_defaults objectForKey:@"doing"];
    
    NSSet *set = [
        NSSet setWithArray:@[
            [NSMutableArray class],
            [Task class]]
    ];
    
    _doingTasks = (NSMutableArray*)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedTodos error: &error];
    [self devideArrayTasks];
    [_tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _isFilterd? 3:1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *sectionTitle;
    switch (section) {
        case 0:
            sectionTitle = _isFilterd?@"Low":@"All Tasks";
            break;
        case 1:
            sectionTitle = @"Medum";
            break;
        default:
            sectionTitle = @"High";
            break;
    }
    
    return sectionTitle;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger sectionCount = 0;
    if(_isFilterd){
        switch (section) {
            case 0:
                sectionCount = _lowTasks.count;
                break;
            case 1:
                sectionCount = _medumTasks.count;
                break;
            default:
                sectionCount = _highTasks.count;
                break;
        }
    }else{
        sectionCount = _doingTasks.count;
    }
    
    return sectionCount;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TaskTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"taskCell" forIndexPath:indexPath];
    UIImage *image;
    image = [UIImage new];
    
    //set image pased on perority
    switch (indexPath.section) {
        case 0:
            //low
            image= [self getTaskImage:_isFilterd?[_lowTasks[indexPath.row] priority]:[_doingTasks[indexPath.row] priority]];
            cell.taskTitle.text = _isFilterd?[_lowTasks[indexPath.row] title]:[_doingTasks[indexPath.row] title];
            break;
        case 1:
            //mid
            image= [self getTaskImage:_isFilterd?[_medumTasks[indexPath.row] priority]:[_doingTasks[indexPath.row] priority]];
            cell.taskTitle.text = _isFilterd?[_medumTasks[indexPath.row] title]:[_doingTasks[indexPath.row] title];
            break;
        default:
            //high
            image= [self getTaskImage:_isFilterd?[_highTasks[indexPath.row] priority]:[_doingTasks[indexPath.row] priority]];
            cell.taskTitle.text = _isFilterd?[_highTasks[indexPath.row] title]:[_doingTasks[indexPath.row] title];
            break;
    }
    
    cell.taskImage.image = image;
    
    return cell;
}


-(UIImage*) getTaskImage: (NSInteger) periority{
    UIImage *img;
    switch (periority) {
        case 0:
            img = [UIImage imageNamed:@"blue_dot"];
            break;
        case 1:
            img = [UIImage imageNamed:@"green_dot"];
            break;
        case 2:
            img = [UIImage imageNamed:@"red_dot"];
            break;
    }
    return img;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Task!" message:@"Do you sure you want to delete this task!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteTask: indexPath.section: indexPath.row];
    }];
    
    [alert addAction:ok];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        nil;
    }];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        nil;
    }];
}

-(void) deleteTask: (NSInteger) section :(NSInteger) row{
    if(_isFilterd){
        switch (section) {
            case 0:
                [_lowTasks removeObjectAtIndex:row];
                break;
            case 1:
                [_medumTasks removeObjectAtIndex:row];
                break;
            default:
                [_highTasks removeObjectAtIndex:row];
                break;
        }
        _doingTasks = [NSMutableArray new];
        [_doingTasks addObjectsFromArray:_lowTasks];
        [_doingTasks addObjectsFromArray:_medumTasks];
        [_doingTasks addObjectsFromArray:_highTasks];
    }else{
        [_doingTasks removeObjectAtIndex:row];
    }
    
    [self updateDoingList];
    
    [_tableView reloadData];
}


-(void) updateDoingList{
    NSError *error;
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:_doingTasks requiringSecureCoding:YES error:&error];
    
    [self devideArrayTasks];

    [_defaults setObject:archiveData forKey:@"doing"];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //navigate to details screen
    
    //present add new task screen
    TaskDetailsViewController *detailsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"detailsScreen"];
    detailsScreen.status = 2;
    detailsScreen.refresh = self;
    detailsScreen.tasks = _doingTasks;
    
    if(_isFilterd){
        
        switch (indexPath.section) {
            case 0:
                detailsScreen.taskIndex = [_doingTasks indexOfObject:_lowTasks[indexPath.row]];
                break;
            case 1:
                detailsScreen.taskIndex = [_doingTasks indexOfObject:_medumTasks[indexPath.row]];
                break;
            default:
                detailsScreen.taskIndex = [_doingTasks indexOfObject:_highTasks[indexPath.row]];
                break;
        }
    }else{
        detailsScreen.taskIndex = indexPath.row;
    }
    
    
    [self presentViewController:detailsScreen animated:YES
                     completion:^{
        nil;
    }];
    
}

- (void)refresh{
    //update todo tasks list then refresh table view
    
    NSError *error;
    NSData *savedTodos = [_defaults objectForKey:@"doing"];
    
    NSSet *set = [
        NSSet setWithArray:@[
            [NSMutableArray class],
            [Task class]]
    ];
    _doingTasks = (NSMutableArray*)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedTodos error: &error];
    [self devideArrayTasks];
    [_tableView reloadData];
}

-(void) devideArrayTasks{
    _lowTasks = [NSMutableArray new];
    _medumTasks = [NSMutableArray new];
    _highTasks = [NSMutableArray new];
    for (Task *task in _doingTasks) {
        switch (task.priority) {
            case 0:
                [_lowTasks addObject:task];
                break;
            case 1:
                [_medumTasks addObject:task];
                break;
            default:
                [_highTasks addObject:task];
                break;
        }
    }
}

- (IBAction)filterList:(id)sender {
    _isFilterd = !_isFilterd;
    [_tableView reloadData];
}

@end
