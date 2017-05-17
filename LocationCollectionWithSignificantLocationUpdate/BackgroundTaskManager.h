//
//  BackgroundTaskManager.h
//
//  Created by Puru Shukla on 20/02/13.
//  Copyright (c) 2013 Puru Shukla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BackgroundMansterTaskExpireDelagte

-(void)masterTaskExpired;

@end

@interface BackgroundTaskManager : NSObject 
@property (weak) id <BackgroundMansterTaskExpireDelagte> delegate;
+(instancetype)sharedBackgroundTaskManager;

-(UIBackgroundTaskIdentifier)beginNewBackgroundTask;
-(void)endAllBackgroundTasks;

@end
