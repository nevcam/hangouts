//
//  LocationsViewController.m
//  hangouts
//
//  Created by josemurillo on 7/18/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "LocationsViewController.h"
#import "LocationCell.h"

#define SERVICE_FORMAT @".json"

static NSString * const clientID = @"QA1L0Z0ZNA2QVEEDHFPQWK0I5F1DE3GPLSNW4BZEBGJXUCFL";
static NSString * const clientSecret = @"W2AOE1TYC4MHK5SZYOUGX0J3LVRALMPB4CXT3ZH21ZCPUMCU";

@interface LocationsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation LocationsViewController

#pragma mark - Global Variables

{
    NSMutableArray *_results;
}

#pragma mark - Load View Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Load Locations

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    [cell updateWithLocation:_results[indexPath.row]];
    return cell;
}

#pragma mark - Save Location When Selected

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *const venue = _results[indexPath.row];
    NSNumber *const lat = [venue valueForKeyPath:@"location.lat"];
    NSNumber *const lng = [venue valueForKeyPath:@"location.lng"];
    NSString *const loc_name = venue[@"name"];
    NSString *const loc_address = [venue valueForKeyPath:@"location.address"];
    
    [_delegate locationsViewController: self didPickLocationWithLatitude:lat longitude:lng name:loc_name address:loc_address];
}

#pragma mark - Search Bar

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *const newText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    [self fetchLocationsWithQuery:newText];
    return true;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self fetchLocationsWithQuery:searchBar.text];
}

// Cancel button has been implemented through view controller

#pragma mark - Fetch Locations From API

- (void)fetchLocationsWithQuery:(NSString *)query
{
    // Default geo-point is MPK
    NSString *latLong = @"37.452961,-122.181725";
    if (_userLocation) {
        latLong = _userLocation;
    }
    NSString *todayDate = [self getCurrentDate];
    
    NSString *const baseURLString = @"https://api.foursquare.com/v2/venues/search?";
    NSString *queryString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&ll=%@&query=%@&v=%@", clientID, clientSecret, latLong, query, todayDate];
    queryString = [queryString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *const url = [NSURL URLWithString:[baseURLString stringByAppendingString:queryString]];
    NSURLRequest *const request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *const session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data) {
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                strongSelf->_results = [responseDictionary valueForKeyPath:@"response.venues"];
                [self.tableView reloadData];
                
            } else {
                NSLog(@"Error: View Controller was closed");
            }
        }
    }];
    [task resume];
}

- (NSString *)getCurrentDate
{
    NSDate *date= [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

@end
