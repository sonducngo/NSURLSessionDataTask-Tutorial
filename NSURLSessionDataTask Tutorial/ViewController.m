//
//  ViewController.m
//  NSURLSessionDataTask Tutorial
//
//  Created by Son Ngo on 3/17/14.
//  Copyright (c) 2014 Son Ngo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

// 1
@property (nonatomic, strong) NSDictionary *searchResultsDict;
@property (nonatomic, strong) NSURLSession *defaultSession;

@end

#pragma mark -
@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // 2
  self.searchResultsDict = [NSDictionary dictionary];
  
  self.searchBar.delegate   = self;
  self.tableView.dataSource = self;
  
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
  self.defaultSession = [NSURLSession sessionWithConfiguration:config];
}

// 3
#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
  NSLog(@"Should end editing");
  return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {

  // create search query based on search input
  NSString *encodedSearch = [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *searchString = [NSString stringWithFormat:@"http://api.duckduckgo.com/?q=%@&format=json", encodedSearch];
  NSURL *url = [NSURL URLWithString:searchString];
  
  NSURLSessionDataTask *task =
  [self.defaultSession dataTaskWithURL:url
         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           
           if (error) {
             [NSException raise:@"Exception downloading data"
                         format:@"%@", error.localizedDescription];
             
           }
           
           NSError *jsonError;
           
           // Parse the JSON response
           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                options:kNilOptions
                                                                  error:&jsonError];
           if (jsonError) {
             [NSException raise:@"Exception on parsing JSON data"
                         format:@"%@", jsonError.localizedDescription];
           }
           
           
           NSMutableDictionary *resultsDict = [NSMutableDictionary dictionary];
           
           NSArray *resultsArray = [dict objectForKey:@"RelatedTopics"];
           for (NSDictionary *result in resultsArray) {
             if (result[@"Text"] && result[@"FirstURL"]) {
               NSString *url   = result[@"FirstURL"];
               NSString *title = result[@"Text"];
               [resultsDict setObject:url forKey:title];
             }
           }
           
           self.searchResultsDict = [NSDictionary dictionaryWithDictionary:resultsDict];
           
           dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
           });
           
         }];
  [task resume];}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
}

// 4
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.searchResultsDict count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                          forIndexPath:indexPath];
  
  NSString *key   = [self.searchResultsDict allKeys][indexPath.row];
  NSString *value = [self.searchResultsDict objectForKey:key];

  cell.textLabel.text       = key;
  cell.detailTextLabel.text = value;
  
  return cell;
}


@end
