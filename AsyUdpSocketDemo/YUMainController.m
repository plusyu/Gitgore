//
//  YUMainController.m
//  AsyUdpSocketDemo
//
//  Created by yuxiang on 14-8-5.
//  Copyright (c) 2014年 yu. All rights reserved.
//

#import "YUMainController.h"
#import "AsyncUdpSocket.h"


#define kIP @"192.168.120.227"
#define kSERVERPORT 9956

#define KCLIENTIP 20001



@interface YUMainController ()
{
    AsyncUdpSocket *socket;
    UITextField *receiveText;
    UITextField *writeText;
    UIButton *openBt;
}

@end

@implementation YUMainController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildUI];
}


-(void)buildUI
{
    openBt= [[UIButton alloc]init];
    openBt.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
    [openBt addTarget:self action:@selector(openSocket) forControlEvents:UIControlEventTouchDown];
    [openBt setTitle:@"开启" forState:UIControlStateNormal];
    [openBt setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:openBt];
    
    writeText= [[UITextField alloc]init];
    writeText.layer.cornerRadius = 9.0;
    writeText.borderStyle = UITextBorderStyleLine;
    writeText.frame = CGRectMake(0, 100, self.view.frame.size.width, 50);
    writeText.placeholder = @"请输入要发送的信息";
    [self.view addSubview:writeText];
    
    UIButton *sendBt = [[UIButton alloc]init];
    sendBt.frame = CGRectMake(0, 150, self.view.frame.size.width, 50);
    [sendBt addTarget:self action:@selector(sendMsg) forControlEvents:UIControlEventTouchDown];
    [sendBt setTitle:@"发送" forState:UIControlStateNormal];
    [sendBt setBackgroundColor:[UIColor redColor]];
    
    [self.view addSubview:sendBt];
    
    
    receiveText  = [[UITextField alloc]init];
    receiveText.layer.cornerRadius = 9.0;
    receiveText.borderStyle = UITextBorderStyleLine;
    receiveText.frame = CGRectMake(0, 200, self.view.frame.size.width, 50);
    receiveText.placeholder = @"这里显示接收到的信息";
    receiveText.enabled = NO;
    [self.view addSubview:receiveText];
    
    UIButton *sendPicBt = [[UIButton alloc]init];
    sendPicBt.frame = CGRectMake(0, 280, self.view.frame.size.width, 50);
    [sendPicBt addTarget:self action:@selector(sendPic) forControlEvents:UIControlEventTouchDown];
    [sendPicBt setTitle:@"发送图片" forState:UIControlStateNormal];
    [sendPicBt setBackgroundColor:[UIColor redColor]];
    
    [self.view addSubview:sendPicBt];
}
-(void)sendPic
{
    //后面的0.5代表生成的图片质量 
    NSLog(@"----sendPic---");
    //IMG_0822.JPG
    UIImage *image = [UIImage imageNamed:@"a.jpg"];
    NSData *myBlob = UIImageJPEGRepresentation(image, 0.6);
    [socket sendData:myBlob
                       toHost:kIP port:kSERVERPORT withTimeout:-1 tag:0];
     NSUInteger length = [myBlob length];
    NSLog(@"length:%ld",(unsigned long)length);
//    NSUInteger length = [myBlob length];
//    NSUInteger chunkSize = 2 * 1024;
//    NSUInteger offset = 0;
//    do {
//        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
//        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[myBlob bytes] + offset
//                                             length:thisChunkSize
//                                       freeWhenDone:NO];
//        offset += thisChunkSize;
//        [socket sendData:chunk
//                  toHost:kIP port:kSERVERPORT withTimeout:-1 tag:0];
//        
//        // do something with chunk
//    } while (offset < length);
    
    
//
    
}

-(void)sendMsg
{

    NSString *name = writeText.text;
    
    [socket sendData:[name dataUsingEncoding:NSUTF8StringEncoding]
              toHost:kIP port:kSERVERPORT withTimeout:-1 tag:0];
}

-(void)openSocket
{
    NSLog(@"openSocket");
    [self initSocket];
    
}


//初始化socket通信
- (void)initSocket {
    //初始化udp
    socket=[[AsyncUdpSocket alloc] initIPv4];
    
    [socket setDelegate:self];//这步很重要，否则无法自定义监听方法
 
    //绑定端口
    NSError *error = nil;
	[socket bindToPort:kSERVERPORT error:&error];
//    //发送广播设置
//    [socket enableBroadcast:YES error:&error];
//    //加入群里，能接收到群里其他客户端的消息
//    [socket joinMulticastGroup:kIP error:&error];
//    //启动接收线程
//	[socket receiveWithTimeout:-1 tag:0];
    
    
    
    [openBt setTitle:@"开启成功" forState:UIControlStateNormal];
    //发送广播
    for (int i=0; i<3; i++) {
//        [self broadcastEntry:kBroadCastIp];
    }
}

//发送广播，通知其他客户端
//- (void)broadcastEntry:(NSString *)host {
//    NSMutableString *str = [[NSMutableString alloc] init];
//    [str appendFormat:@"%@:%@:%@:%@:%@",@"MacOS",@"bjx",@"1",@"自己",@"Hello"];
//    [self->socket sendData:[str dataUsingEncoding:NSUTF8StringEncoding]
//                    toHost:host port:kPORT withTimeout:-1 tag:0];
//    
//    str = nil;
//}

//----------------------------UDP delegate---------------------------------
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
  
//    receiveText.text =(NSString *) data;
    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    receiveText.text = newStr;
    //启动监听下一条消息
    [socket receiveWithTimeout:-1 tag:0];
    //这里可以加入你想要的代码
    return YES;
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    
    NSLog(@"Message not received for error: %@", error);
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    
    NSLog(@"Message not send for error: %@",error);
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    
    NSLog(@"Message send success!");
    writeText.text = @"";
}

- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    NSLog(@"onUdpSocketDidClose");
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
