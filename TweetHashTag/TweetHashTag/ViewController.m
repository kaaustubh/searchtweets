//
//  ViewController.m
//  TweetHashTag
//
//  Created by Kaustubh on 22/01/16.
//  Copyright © 2016 Self. All rights reserved.
//

#import "ViewController.h"
#import "Tweet.h"
#import "TweetManager.h"
#import "ResultsTableViewController.h"
@interface ViewController ()<UISearchBarDelegate, UITableViewDataSource>
{
    TweetManager *sharedInstance;
}

@property (nonatomic, strong) NSMutableArray *arrOfTweets;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *searchTag;
@property (nonatomic, strong) NSTimer *searchTimer;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) ResultsTableViewController *resultsViewController;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.definesPresentationContext = NO;
    sharedInstance=[TweetManager sharedInstance];
    _searchTimer=nil;
    
    _resultsViewController=[[ResultsTableViewController alloc] init];
    _searchController=[[UISearchController alloc] initWithSearchResultsController:_resultsViewController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.resultsViewController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    self.definesPresentationContext = YES;
    self.tableView.delegate=self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _searchTag=_searchBar.text;
    [self searchHashTag];
}

-(void)searchHashTag
{
    if (_searchTag.length==0)
    {
        return;
    }
    [sharedInstance getTweetsForHashTags:_searchTag Completion:^(NSMutableArray *arr, NSError *error)
    {
        if (_searchTimer==nil)
        {
            _searchTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerFunction:) userInfo:nil repeats:YES];
        }
        if (error==nil)
        {
            _arrOfTweets=arr;
            [self.tableView reloadData];
            ResultsTableViewController *resultController=(ResultsTableViewController*)self.searchController.searchResultsController;
            resultController.tweets=arr;
            [resultController.tableView reloadData];
        }
    }];
}

-(void)timerFunction:(NSTimer*)timer
{
    [self searchHashTag];
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
    self.navigationController.navigationBar.translucent = YES;
}

-(void)willDismissSearchController:(UISearchController *)searchController
{
    self.navigationController.navigationBar.translucent = NO;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height=0;
    UIFont *font = [UIFont systemFontOfSize:16.0f];
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          font, NSFontAttributeName,
                                          nil];
    Tweet *tweet=_arrOfTweets[indexPath.row];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString: tweet.tweetText attributes:attributesDictionary];
    CGRect size=[string boundingRectWithSize:CGSizeMake(300.0f, 999.0f)
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     context:nil];
    height=size.size.height + 10;
    return height;
}

#pragma TableView datasoruce methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _arrOfTweets.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    Tweet *tweet=_arrOfTweets[indexPath.row];
    cell.textLabel.numberOfLines=0;
    cell.textLabel.text=tweet.tweetText;
    cell.detailTextLabel.text=tweet.tweetUserName;
    return cell;
}


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchText = searchController.searchBar.text;
    _searchTag=searchText;
    [self searchHashTag];
}

@end
