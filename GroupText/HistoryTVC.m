//
//  HistoryTVC.m
//  GroupText
//
//  Created by W on 15/12/18.
//  Copyright © 2015年 IEC. All rights reserved.
//

#import "HistoryTVC.h"

@interface HistoryTVC ()

@property (strong,nonatomic) NSMutableArray *historyList;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;

- (IBAction)editButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)deleteButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender;


@end

@implementation HistoryTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //载入本地群发记录
    NSString *filePath = [self getDocumentsHistoryListPath];
    self.historyList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    //放置导航栏按钮
    self.navigationItem.leftBarButtonItem = self.editBarButton;
    self.navigationItem.rightBarButtonItem = self.addBarButton;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.historyList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //引用 cell 及 cell 中的 label
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"history cell"];
    UILabel *receiverLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:3];
    //读取本地短信历史
    //NSDictionary historyItem = [[NSDictionary alloc]initWithDictionary:[self.historyList objectAtIndex:indexPath.row]]
    NSDictionary *historyItem = [self.historyList objectAtIndex:indexPath.row];
    NSDate *time = [historyItem objectForKey:@"time"];
    NSNumber *status = [historyItem objectForKey:@"status"];
    NSString *content = [historyItem objectForKey:@"content"];
    NSArray *receiver = [historyItem objectForKey:@"receiver"];
    //显示内容
    contentLabel.text = content;
    [contentLabel sizeToFit]; //使其在垂直方向顶端对齐
    //显示日期
    NSNumber *days=[self daysFrom:time];
    int intdays = [days intValue];
    if (intdays > 7) { //一周前的信息
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yy/M/d"];
        timeLabel.text = [dateFormatter stringFromDate:time];
    } else if (intdays > 1) { //两天前的信息
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"EEEE"];
        timeLabel.text = [dateFormatter stringFromDate:time];
    } else if (intdays > 0) { //昨天的信息
        timeLabel.text = @"昨天";
    } else { //今天的信息
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"HH:mm"];
        timeLabel.text = [dateFormatter stringFromDate:time];
    }
    //显示接收人
    NSString *firstReceiver = [receiver objectAtIndex:0];
    NSInteger count = [receiver count];
    NSString *receiverLabelText = [firstReceiver stringByAppendingFormat:@" 等%ld位联系人",(long)count];
    receiverLabel.text = receiverLabelText;

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    // 从数据源中删除所选行对应的值
    [self.historyList removeObjectAtIndex:indexPath.row];
    NSString *filePath=[self getDocumentsHistoryListPath];
    [self.historyList writeToFile:filePath atomically:YES];
    // 删除对应的行
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
}

//重写左滑删除按钮的标题
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

//选中某行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateDeleteButtonTitle];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateDeleteButtonTitle];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - 自定义方法

//获取Documents目录下HistoryList.plist的路径
- (NSString *)getDocumentsHistoryListPath {
    //获取应用程序沙盒的Documents目录
    NSArray *docPathA=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docPath = [docPathA objectAtIndex:0];
    //得到Documents目录下完整的文件名
    NSString *filePath=[docPath stringByAppendingPathComponent:@"HistoryList.plist"];
    return filePath;
}

//计算到今日23:59:59的日期差
- (NSNumber *)daysFrom:(NSDate *)givenDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //获取到今日23:59:59的时间偏移量components
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:[NSDate date]];
    [components setHour:-[components hour] + 23];
    [components setMinute:-[components minute] + 59];
    [components setSecond:-[components second] + 59]; //相差整24小时时计算出的时间差为1天
    //计算出givenDate到今日23:59:59的日期差
    NSDate *day = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    NSDateComponents *daysComponents = [calendar components:(NSCalendarUnitDay) fromDate:givenDate toDate:day options:0];
    NSNumber *days = [NSNumber numberWithLong:[daysComponents day]];
    return days;
}

#pragma mark - 导航栏按钮方法

// 点击编辑按钮
- (IBAction)editButtonClicked:(UIBarButtonItem *)sender {
    self.tableView.allowsMultipleSelectionDuringEditing = YES;// 进入可多选删除状态
    [self.tableView setEditing:YES animated:YES];// 将table设置为可编辑
    [self updateBarButtons];  //更改导航栏的导航按钮
}

// 点击删除按钮
- (IBAction)deleteButtonClicked:(UIBarButtonItem *)sender {
    // 选中的行
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    // 删除选中的行
    if (selectedRows.count > 0)
    {
        // 将所选的行的索引值放在一个集合中进行批量删除
        NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
        
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            [indicesOfItemsToDelete addIndex:selectionIndex.row];
        }
        // 从数据源中删除所选行对应的值
        [self.historyList removeObjectsAtIndexes:indicesOfItemsToDelete];
        NSString *filePath=[self getDocumentsHistoryListPath];
        [self.historyList writeToFile:filePath atomically:YES];
        
        // 删除所选的行
        [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.tableView setEditing:NO animated:YES];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    [self updateBarButtons];
}

// 点击取消按钮
- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender {
    
    [self.tableView setEditing:NO animated:YES];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self updateBarButtons];
}

// 更新导航栏按钮
-(void) updateBarButtons
{
    // 如果是允许多选的状态，即进入批量删除模式
    if (self.tableView.allowsSelectionDuringEditing == YES) {
        //更新删除按钮
        [self updateDeleteButtonTitle];
        // 导航栏左边按钮设置为空
        self.navigationItem.leftBarButtonItems = nil;
        // 将左边按钮设置为'删除'按钮
        self.navigationItem.leftBarButtonItem = self.deleteBarButton;
        // 导航栏右键设置为'取消'按钮
        self.navigationItem.rightBarButtonItem = self.cancelBarButton;
        
    } else { // 如果不是多选状态，将导航栏设置为初始状态的样式
        self.navigationItem.leftBarButtonItem = self.editBarButton;
        self.navigationItem.rightBarButtonItem = self.addBarButton;
    }
}

// 更新删除按钮的标题
-(void)updateDeleteButtonTitle
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];//得到选中行
    
    BOOL allItemsAreSelected = selectedRows.count == self.historyList.count;// 是否全选
    
    if (allItemsAreSelected) { // 如果全选，则删除键为删除全部
        self.deleteBarButton.title = @"删除全部";
    } else { // 否则 删除键为删除（选中行数量）
        self.deleteBarButton.title = [NSString stringWithFormat:@"删除 (%lu)", (unsigned long)selectedRows.count];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
