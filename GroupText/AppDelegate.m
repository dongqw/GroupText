//
//  AppDelegate.m
//  GroupText
//
//  Created by W on 15/12/14.
//  Copyright © 2015年 IEC. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //获取应用程序沙盒的Documents目录
    NSArray *docPathA=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docPath = [docPathA objectAtIndex:0];
    //得到Documents目录下完整的文件名
    NSString *filePath=[docPath stringByAppendingPathComponent:@"HistoryList.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断是否首次运行
    if(![fileManager fileExistsAtPath:filePath]) {  //如果Documents目录下不存在该文件
        //获取程序包中相应文件的路径
        NSString *dataPath = [[NSBundle mainBundle]pathForResource:@"HistoryList" ofType:@"plist"];
        NSError *error;
        if([fileManager copyItemAtPath:dataPath toPath:filePath error:&error]) {
            NSLog(@"用户首次运行且文件拷贝成功！");
        } else {
            NSLog(@"%@",error);
        }
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
