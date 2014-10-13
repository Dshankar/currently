//
//  UpdateTableViewController.m
//  Currently
//
//  Created by Darshan Shankar on 9/30/14.
//  Copyright (c) 2014 Darshan Shankar. All rights reserved.
//

#import "UpdateTableViewController.h"
#import "UpdateStatusCell.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface UpdateTableViewController ()
@end

@implementation UpdateTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Update Status"];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView:)];
    [self.navigationItem setLeftBarButtonItem:cancel];
    
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(updateStatus:)];
    [self.navigationItem setRightBarButtonItem:submit];
    
    [self.tableView registerClass:[UpdateStatusCell class] forCellReuseIdentifier:@"UpdateStatusCell"];
}

- (void)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateStatus:(id)sender {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    UpdateStatusCell *verbCell = (UpdateStatusCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UpdateStatusCell *nounCell = (UpdateStatusCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UpdateStatusCell *locationCell = (UpdateStatusCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    NSString *verb = verbCell.textField.text;
    NSString *noun = nounCell.textField.text;
    NSString *location = locationCell.textField.text;
    if(verb.length > 0) {
        [data setObject:verb forKey:@"verb"];
    }
    if(noun.length > 0) {
        [data setObject:noun forKey:@"noun"];
    }
    if(location.length > 0) {
        [data setObject:location forKey:@"location"];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [NSString stringWithFormat:@"Bearer %@", [defaults objectForKey:@"accesstoken"]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://currently-test.herokuapp.com/update"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];

    self.updateStatusConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.updateStatusConnection start];
}

- (void)refreshTokens{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:@"refresh_token" forKey:@"grant_type"];
    [data setObject:@"currentlyiOSV1" forKey:@"client_id"];
    [data setObject:@"abc123456" forKey:@"client_secret"];
    [data setObject:[defaults objectForKey:@"refreshtoken"] forKey:@"refresh_token"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://currently-test.herokuapp.com/oauth/token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    self.refreshTokenConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.refreshTokenConnection start];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection == self.updateStatusConnection){
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            [self.delegate statusHasUpdated];
            [self dismissView:nil];
        } else if([((NSHTTPURLResponse *)response) statusCode] == 401) {
            // access token has expired, refresh with refresh token
            [self refreshTokens];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection == self.updateStatusConnection){
        // ?
    } else if(connection == self.refreshTokenConnection){
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@", dict);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[dict objectForKey:@"access_token"] forKey:@"accesstoken"];
        [defaults setObject:[dict objectForKey:@"refresh_token"] forKey:@"refreshtoken"];
        [defaults synchronize];
        
        [self updateStatus:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Update Status Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UpdateStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpdateStatusCell" forIndexPath:indexPath];
    if(cell == nil){
        cell = [[UpdateStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UpdateStatusCell"];
    }
    
    switch (indexPath.row) {
        case 0:
            [cell.label setText:@"What are you doing?"];
            [cell.textField setPlaceholder:@"ex. eating, sleeping"];
            break;
        case 1:
            [cell.label setText:@"Noun"];
            [cell.textField setPlaceholder:@"ex. a burger, a book"];
            break;
        case 2:
            [cell.label setText:@"Where are you?"];
            [cell.textField setPlaceholder:@"ex. Home, Work"];
            break;
    }
    // Configure the cell...
    
    return cell;
}

@end
