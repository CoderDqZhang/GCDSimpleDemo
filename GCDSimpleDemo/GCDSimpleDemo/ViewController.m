//
//  ViewController.m
//  GCDSimpleDemo
//
//  Created by Zhang on 29/10/2016.
//  Copyright © 2016 Zhang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (nonatomic, strong) dispatch_queue_t concurrentQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self dispatch_sync];
//    [self dispatch_async];
//    self.serialQueue = dispatch_queue_create("zhang.serialqueue.cn", DISPATCH_QUEUE_SERIAL);
//    self.concurrentQueue = dispatch_queue_create("cn.chutong.www", DISPATCH_QUEUE_CONCURRENT);
//    
//    for (int i = 0; i < 100; i++) {
////        [self serialPrintNumber:i];
//        [self concurrentPrintNumber:i];
//    }
//    dispatch_queue_t concurrent = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(concurrent, ^{
//        
//    });
//    [self dispatch_apply];
//    [self dispatch_semaphore];
    // Do any additional setup after loading the view, typically from a nib.
    [self dispatch_group];
}
//dispatch_queue_t queue = dispatch_queue_create("cn.chutong.www", DISPATCH_QUEUE_CONCURRENT);
//
//dispatch_async(queue, ^{
//    
//    /**
//     
//     放一些极其耗时间的任务在此执行
//     */
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        /**
//         耗时任务完成，拿到资源，更新UI
//         更新UI只可以在主线程中更新
//         */
//        
//    });
//    
//});

/**
 diapatch_semaphore 是一种多线程同步机制，在一个异步线程中需要放回一个网络请求的数据就可以使用这个了，在这里的dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER); 如果semaphore计数大于等于1.计数-1.返回。程序继续等待,DISPATCH_TIME_FOREVER是永远等待，这个可以保证在多线程的环境下只有一个线程可以进入
 */
- (void)dispatch_semaphore
{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int index = 0; index < 10; index++) {
        
        if (index == 5) {
            semaphore = dispatch_semaphore_create(1);
        }else{
            semaphore = dispatch_semaphore_create(0);
        }
        
        dispatch_async(queue, ^(){
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//
            
            NSLog(@"addd :%d", index);
            
            [array addObject:[NSNumber numberWithInt:index]];
            
            dispatch_semaphore_signal(semaphore);
            
        });
        
    }
}

/**
 dispathc_apply 是dispatch_sync 和dispatch_group的关联API.它以指定的次数将指定的Block加入到指定的队列中。并等待队列中操作全部完成.
 输出 copy-index 顺序不确定，因为它是并行执行的（dispatch_get_global_queue是并行队列），但是done是在以上拷贝操作完成后才会执行，因此，它一般都是放在dispatch_async里面（异步）。实际上，这里 dispatch_apply如果换成串行队列上，则会依次输出index，但这样违背了我们想并行提高执行效率的初衷。

 */
- (void)dispatch_apply
{
    NSArray *array = [NSArray arrayWithObjects:@"~/Desktop/copy_res/gelato.ds",
                      @"~/Desktop/copy_res/jason.ds",
                      @"~/Desktop/copy_res/jikejunyi.ds",
                      @"~/Desktop/copy_res/molly.ds",
                      @"~/Desktop/copy_res/zhangdachuan.ds",
                      nil];
    NSString *copyDes = @"~/Desktop/copy_des";
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    dispatch_async(dispatch_get_global_queue(0, 0), ^(){
//        dispatch_apply([array count], dispatch_get_global_queue(0, 0), ^(size_t index){
//            NSLog(@"dispatch_async copy-%ld", index);
//            NSString *sourcePath = [array objectAtIndex:index];
//            NSString *desPath = [NSString stringWithFormat:@"%@/%@", copyDes, [sourcePath lastPathComponent]];
//            [fileManager copyItemAtPath:sourcePath toPath:desPath error:nil];
//        });
//        NSLog(@"done");
//    });
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
       dispatch_apply([array count], dispatch_get_global_queue(0, 0), ^(size_t index) {
           NSLog(@"dispatch_sync copy-%ld",index);
           NSString *sourcePath = [array objectAtIndex:index];
           NSString *desPath = [NSString stringWithFormat:@"%@/%@", copyDes, [sourcePath lastPathComponent]];
           [fileManager copyItemAtPath:sourcePath toPath:desPath error:nil];
       });
        NSLog(@"done");
    });
}


/**
 dispatch_sync(),同步添加操作。他是等待添加进队列里面的操作完成之后再继续执行。
 */
- (void)dispatch_sync
{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"1");
    dispatch_sync(concurrentQueue, ^(){
        NSLog(@"2");
        [NSThread sleepForTimeInterval:10];
        NSLog(@"3");
    });
    NSLog(@"4");
}

/**
 dispatch_async ,异步添加进任务队列，它不会做任何等待
 */
- (void)dispatch_async
{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"1");
    dispatch_async(concurrentQueue, ^(){
        NSLog(@"2");
        [NSThread sleepForTimeInterval:5];
        NSLog(@"3");
    });
    NSLog(@"4");
}

/**
 *  异步串行队列
 *
 */
- (void)serialPrintNumber:(int)number
{
    dispatch_async(self.serialQueue, ^{
        
        NSLog(@"%d   %@",number, [NSThread currentThread]);
        
    });
}

/**
 *  异步并行队列
 *
 */
- (void)concurrentPrintNumber:(int)number
{
    dispatch_async(self.concurrentQueue, ^{
        if (number == 70) {
            NSLog(@"");
        }
        NSLog(@"%d   %@",number, [NSThread currentThread]);
    });
}


- (void)dispatch_group
{
    dispatch_queue_t aDQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    // Add a task to the group
    dispatch_group_async(group, aDQueue, ^{
        printf("task 1 \n");
    });
    dispatch_group_async(group, aDQueue, ^{
        printf("task 2 \n");
    });
    dispatch_group_async(group, aDQueue, ^{
        printf("task 3 \n");
    });
    printf("wait 1 2 3 \n");
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    printf("task 1 2 3 finished \n");
    group = dispatch_group_create();
    // Add a task to the group
    dispatch_group_async(group, aDQueue, ^{
        printf("task 4 \n");
    });
    dispatch_group_async(group, aDQueue, ^{
        printf("task 5 \n");
    });
    dispatch_group_async(group, aDQueue, ^{
        printf("task 6 \n");
    });
    printf("wait 4 5 6 \n");
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    printf("task 4 5 6 finished \n");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
