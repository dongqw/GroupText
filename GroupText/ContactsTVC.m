//
//  ContactsTVC.m
//  GroupText
//
//  Created by W on 15/12/20.
//  Copyright © 2015年 IEC. All rights reserved.
//

#import "ContactsTVC.h"

@interface ContactsTVC ()

@property (strong,nonatomic) NSMutableArray *fetchedContacts; // 获取到的联系人
@property (strong,nonatomic) NSMutableArray *selectedContacts; // 勾选的联系人
@property (strong,nonatomic) NSMutableArray *confirmContacts; // 有多个号码的联系人

- (IBAction)finishButtonClicked:(UIBarButtonItem *)sender;

@end

@implementation ContactsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化 property
    self.fetchedContacts = [[NSMutableArray alloc] init];
    self.selectedContacts = [[NSMutableArray alloc] init];
    self.confirmContacts = [[NSMutableArray alloc] init];
    
    //创建CNContactStore对象,用与获取和保存通讯录信息
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    
    //用户授权
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {//首次访问通讯录会调用
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (error) return;
            if (granted) {//允许
                NSLog(@"授权访问通讯录");
                [self fetchContactWithContactStore:contactStore];//访问通讯录
            }else{//拒绝
                NSLog(@"拒绝访问通讯录");//访问通讯录
            }
        }];
    }else{
        [self fetchContactWithContactStore:contactStore];//访问通讯录
    }
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;// 进入可多选删除状态
    [self.tableView setEditing:YES animated:YES];// 将table设置为可编辑
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contact cell" forIndexPath:indexPath];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    
    CNContact * _Nonnull contact = [self.fetchedContacts objectAtIndex:indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
    nameLabel.text = name;
    
    return cell;
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

- (void)fetchContactWithContactStore:(CNContactStore *) contactStore{
    //访问通讯录
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) { //有权限访问
        NSError *error = nil;
        [self.fetchedContacts removeAllObjects];
        //创建数组,必须遵守CNKeyDescriptor协议,放入相应的字符串常量来获取对应的联系人信息
        NSArray <id<CNKeyDescriptor>> *fetchedContacts = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey];
        //创建获取联系人的请求
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchedContacts];
        //遍历查询
        [contactStore enumerateContactsWithFetchRequest:fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            if (!error) {
                if (((CNPhoneNumber *)(contact.phoneNumbers.lastObject.value)).stringValue != NULL) { //如果该联系人存在电话号码的键值
                    [self.fetchedContacts addObject:contact];
                }
                NSLog(@"familyName = %@", contact.familyName); //姓
                NSLog(@"givenName = %@", contact.givenName); //名字
                NSLog(@"phoneNumber = %@", ((CNPhoneNumber *)(contact.phoneNumbers.lastObject.value)).stringValue); //电话
            }else{
                NSLog(@"error:%@", error.localizedDescription);
            }
        }];
    }else{//无权限访问
        NSLog(@"拒绝访问通讯录");
    }
}

// 获取选中的联系人
- (void) getSelectedContacts {
    [self.selectedContacts removeAllObjects];
    // 选中的行
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    // 取出选中的联系人
    if (selectedRows.count > 0)
    {
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            [self.selectedContacts addObject:[self.fetchedContacts objectAtIndex:selectionIndex.row]];
        }
    }

}

// 点击完成按钮
- (IBAction)finishButtonClicked:(UIBarButtonItem *)sender {
    [self getSelectedContacts];
    
    [self.confirmContacts removeAllObjects];
    for (CNContact *selectedContact in self.selectedContacts) {
        if (selectedContact.phoneNumbers.count > 1) {
            [self.confirmContacts addObject:selectedContact];
        }
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
