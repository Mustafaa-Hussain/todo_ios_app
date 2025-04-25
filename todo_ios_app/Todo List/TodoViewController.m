//
//  TodoViewController.m
//  Todo List
//
//  Created by JETSMobileLabMini5 on 23/04/2025.
//

#import "TodoViewController.h"
#import "TaskTableViewCell.h"
#import "TaskDetailsViewController.h"
#import "Task.h"

@interface TodoViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSUserDefaults *defaults;
@property NSMutableArray <Task *> *todoTasks;
@property NSMutableArray <Task *>*lowTasks;
@property NSMutableArray <Task *>*medumTasks;
@property NSMutableArray <Task *>*highTasks;
@end

@implementation TodoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //get data from user defaults
    _defaults = [NSUserDefaults standardUserDefaults];
    _todoTasks = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated{
    NSError *error;
    NSData *savedTodos = [_defaults objectForKey:@"todo"];
    
    NSSet *set = [
        NSSet setWithArray:@[
            [NSMutableArray class],
            [Task class]]
    ];
    
    _todoTasks = (NSMutableArray*)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedTodos error: &error];
    [self devideArrayTasks];
    [_tableView reloadData];
}

-(void) devideArrayTasks{
    _lowTasks = [NSMutableArray new];
    _medumTasks = [NSMutableArray new];
    _highTasks = [NSMutableArray new];
    for (Task *task in _todoTasks) {
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


-(void) devideArrayTasks: (NSMutableArray*) arrayOfTasks{
    _lowTasks = [NSMutableArray new];
    _medumTasks = [NSMutableArray new];
    _highTasks = [NSMutableArray new];
    
    for (Task *task in arrayOfTasks) {
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


- (IBAction)addNewTask:(id)sender {
    //present add new task screen
    TaskDetailsViewController *detailsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"detailsScreen"];
    detailsScreen.status = 0;
    detailsScreen.refresh = self;
    
    
    [self presentViewController:detailsScreen animated:YES
                     completion:^{
        nil;
    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *sectionTitle;
    switch (section) {
        case 0:
            sectionTitle = @"Low";
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
            image=[self getTaskImage:[_lowTasks[indexPath.row] priority]];
            cell.taskTitle.text = [_lowTasks[indexPath.row] title];
            break;
        case 1:
            //mid
            image=[self getTaskImage:[_medumTasks[indexPath.row] priority]];
            cell.taskTitle.text = [_medumTasks[indexPath.row] title];
            break;
        default:
            //high
            image=[self getTaskImage:[_highTasks[indexPath.row] priority]];
            cell.taskTitle.text = [_highTasks[indexPath.row] title];
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


- (void)refresh{
    //update todo tasks list then refresh table view
    
    NSError *error;
    NSData *savedTodos = [_defaults objectForKey:@"todo"];
    
    NSSet *set = [
        NSSet setWithArray:@[
            [NSMutableArray class],
            [Task class]]
    ];
    _todoTasks = (NSMutableArray*)[NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedTodos error: &error];
    [self devideArrayTasks];
    [_tableView reloadData];
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
    
    _todoTasks = [NSMutableArray new];
    [_todoTasks addObjectsFromArray:_lowTasks];
    [_todoTasks addObjectsFromArray:_medumTasks];
    [_todoTasks addObjectsFromArray:_highTasks];
    
    [self updateTodoList];
    
    [_tableView reloadData];
}

-(void) updateTodoList{
    NSError *error;
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:_todoTasks requiringSecureCoding:YES error:&error];
    
    [_defaults setObject:archiveData forKey:@"todo"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //navigate to details screen
    
    //present add new task screen
    TaskDetailsViewController *detailsScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"detailsScreen"];
    detailsScreen.status = 1;
    detailsScreen.refresh = self;
    
    detailsScreen.tasks = _todoTasks;
    
    switch (indexPath.section) {
        case 0:
            detailsScreen.taskIndex = [_todoTasks indexOfObject:_lowTasks[indexPath.row]];
            break;
        case 1:
            detailsScreen.taskIndex = [_todoTasks indexOfObject:_medumTasks[indexPath.row]];
            break;
        default:
            detailsScreen.taskIndex = [_todoTasks indexOfObject:_highTasks[indexPath.row]];
            break;
    }
    
    
    [self presentViewController:detailsScreen animated:YES
                     completion:^{
        nil;
    }];
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length ==0) {
        [self devideArrayTasks];
    }else{
        NSMutableArray *tempList = [NSMutableArray new];
        for (int i = 0; i<_todoTasks.count; i++) {
            NSString *temp = _todoTasks[i].title.lowercaseString;
            if ([temp containsString:searchText.lowercaseString]) {
                [tempList addObject: _todoTasks[i]];
            }
        }
        [self devideArrayTasks: tempList];
        
    }
    [_tableView reloadData];
}
@end
