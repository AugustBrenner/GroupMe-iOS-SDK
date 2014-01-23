//
//  GMViewController.m
//  GroupMe-iOS-SDK
//
//  Created by Ryan Brenner on 1/21/14.
//  Copyright (c) 2014 AugustBrenner. All rights reserved.
//

#import "GMViewController.h"

#define GroupMe

@interface GMViewController ()

// Websocket Library
@property (nonatomic, readwrite) SRWebSocket *webSocket;

// Websocket State:
//  true:   Connected
//  false:  Disconnected
@property (nonatomic, readwrite) BOOL socketReady;

// ID tag for handshake messages incremented upon each successive request
@property (nonatomic, readwrite) NSInteger handshakeID;

// Test outlets (Development)
@property (weak, nonatomic) IBOutlet UITextView *response;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatus;


@end

@implementation GMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





/*
 *
 *  Connection Button
 *      for connecting to websockets
 *
 */
- (IBAction)connect:(id)sender {
    
    // Code for Connecting to Websockets
    self.socketReady = NO;
    self.webSocket = [[SRWebSocket alloc] initWithURL:[[NSURL alloc] initWithString:WEBSOCKETS_BASEURL]];
    self.webSocket.delegate = self;
    [self.webSocket open];
    
    
}






/*
 *
 *  Connection Button
 *      for disconnecting from websockets
 *
 */
- (IBAction)disconnect:(id)sender {
    
    // Code for disconnecting from web sockts
    [self.webSocket close];
    self.webSocket = nil;
}



/*
 *
 * Method called when Recieves messages from websockets
 *
 */
-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    self.response.text = (NSString *)message;
}




/*
 *
 *  Method called when websocket connection opened
 *
 */
-(void)webSocketDidOpen:(SRWebSocket *)webSocket{
    self.socketReady = YES;
    self.connectionStatus.text = @"Connected";
    self.connectionStatus.textColor = [UIColor greenColor];
    
    // Begin Handshake
    [self handshake];
}




/*
 *
 *  Method called when websocket connection closed
 *
 */
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    self.socketReady = NO;
    self.connectionStatus.text = @"Disconnected";
    self.connectionStatus.textColor = [UIColor redColor];
}

/*
 *
 *  Method called when websocket connection closed
 *
 */
-(void)handshake
{
    // Reset Handshake ID
    self.handshakeID = 1;
    
    // Initialize an Array of Supported connection Types
    NSArray *supportedConnectionTypes = [NSArray arrayWithObjects:
                                         @"long-polling",
                                         nil];
    
    // Initialize the Dicitonary of Request Objects
    NSDictionary *handshakeDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"/meta/handshake",                              @"channel",
                                   @"1.0",                                          @"version",
                                   supportedConnectionTypes,                        @"supportedConnectionTypes",
                                   [NSNumber numberWithInteger: self.handshakeID],  @"id",
                                   nil];
    
    // Serialize the handshakeRequest Dictionary to JSON format
    NSData *handshakeJSON = [handshakeDict JSONData];
    
    
    
    // Start the Handshake by Sending handshakeJSON Object Through the Socket Connection
    [self.webSocket send:handshakeJSON];
    
}


@end
