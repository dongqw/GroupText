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

@end

@implementation HistoryTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *filePath = [self getDocumentsHistoryListPath];
    self.historyList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];

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
    [self.historyList removeObjectAtIndex:indexPath.row];
    NSString *filePath=[self getDocumentsHistoryListPath];
    [self.historyList writeToFile:filePath atomically:YES];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
