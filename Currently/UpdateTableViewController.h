//
//  UpdateTableViewController.h
//  Currently
//
//  Created by Darshan Shankar on 9/30/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StatusUpdatedProtocol <NSObject>
@required
- (void)statusHasUpdated;
@end

@interface UpdateTableViewController : UITableViewController

@property (nonatomic, retain) NSURLConnection *updateStatusConnection;
@property (nonatomic, retain) NSURLConnection *refreshTokenConnection;
@property (nonatomic) id <StatusUpdatedProtocol>delegate;

@end
