//
//  StatusTableViewController.m
//  Currently
//
//  Created by Darshan Shankar on 9/28/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "StatusTableViewController.h"
#import "UserCell.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "UpdateTableViewController.h"

@interface StatusTableViewController ()

@end

@implementation StatusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Currently"];
    
    UIBarButtonItem *update = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStylePlain target:self action:@selector(updateStatus:)];
    [self.navigationItem setRightBarButtonItem:update];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"UserCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)updateData {
    NSLog(@"updating data");
    NSString *jsonUrl = @"http://currently-data.herokuapp.com/data";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:jsonUrl]];
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(error != nil){
        NSLog(@"error: %@", error);
    } else {
        self.profileData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [self.tableView reloadData];
    }
}

- (void)registerEngagement {
    NSLog(@"register engagement");
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Statuses Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"engagement"
                                                          action:@"open_app"
                                                           label:nil
                                                           value:nil] build]];
}

- (void)updateStatus:(id)sender {
    UpdateTableViewController *updateController = [[UpdateTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    updateController.delegate = self;
    UINavigationController *updateNav = [[UINavigationController alloc] initWithRootViewController:updateController];
    [self.navigationController presentViewController:updateNav animated:YES completion:nil];
}

- (void)statusHasUpdated
{
    [self updateData];
}

- (void)applicationActive:(id)sender {
    [self updateData];
    [self registerEngagement];
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
    return self.profileData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCell"];
    }
    
    NSString *profileURL = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"image"];
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:profileURL]];
    NSError *error;
    NSData *imageData = [NSURLConnection sendSynchronousRequest:imageRequest returningResponse:nil error:&error];
    if(error != nil){
        NSLog(@"image error: %@", error);
    } else {
        [cell.profile setImage:[UIImage imageWithData:imageData]];
    }
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    NSDictionary *mediumAttribute = @{NSFontAttributeName: [UIFont fontWithName:@"Gotham-Medium" size:16.0f]};
    NSDictionary *bookAttribute = @{NSFontAttributeName: [UIFont fontWithName:@"Gotham-Book" size:16.0f]};
    NSDictionary *timeAttribute = @{NSFontAttributeName: [UIFont fontWithName:@"Gotham-Book" size:13.0f], NSForegroundColorAttributeName: [UIColor grayColor]};
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5.0f];

    NSString *myName = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSAttributedString *name = [[NSAttributedString alloc] initWithString:myName attributes:mediumAttribute];
    [attrString appendAttributedString:name];
    NSAttributedString *is = [[NSAttributedString alloc] initWithString:@" is " attributes:bookAttribute];
    [attrString appendAttributedString:is];
    
    BOOL hasVerb = [[[self.profileData objectAtIndex:indexPath.row] objectForKey:@"hasVerb"] boolValue];
    BOOL hasNoun = [[[self.profileData objectAtIndex:indexPath.row] objectForKey:@"hasNoun"] boolValue];
    BOOL hasLocation = [[[self.profileData objectAtIndex:indexPath.row] objectForKey:@"hasLocation"] boolValue];
 
    if(hasVerb){
        NSString *myVerb = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"verb"];
        NSAttributedString *verb = [[NSAttributedString alloc] initWithString:myVerb attributes:bookAttribute];
        [attrString appendAttributedString:verb];
    }
    if(hasNoun){
        NSString *myNoun = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"noun"];
        NSAttributedString *noun = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", myNoun] attributes:mediumAttribute];
        [attrString appendAttributedString:noun];
    }
    if(hasLocation){
        NSAttributedString *at = [[NSAttributedString alloc] initWithString:@" at " attributes:bookAttribute];
        [attrString appendAttributedString:at];
        
        NSString *myLocation = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"location"];
        NSAttributedString *location = [[NSAttributedString alloc] initWithString:myLocation attributes:mediumAttribute];
        [attrString appendAttributedString:location];
    }
    
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrString.string length])];
    [cell.status setAttributedText:attrString];
    
    NSString *myTime = [[self.profileData objectAtIndex:indexPath.row] objectForKey:@"time"];
    NSAttributedString *time = [[NSAttributedString alloc] initWithString:myTime attributes:timeAttribute];
    [cell.time setAttributedText:time];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end
