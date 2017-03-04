//
//  ViewController.m
//  AMShyBarDemo
//
//  Created by Min on 2017/3/4.
//  Copyright © 2017年 Min. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+AMShyBar.h"
#import "StyleOne.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"AMShyBarDemo";
    self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
    
    [self createTableView];
    
    StyleOne *style1 = [[StyleOne alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.bounds), 44.f)];
    
    [self am_shyBarWithScrollView:_tableView];
    [self am_customShyBar:style1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self am_expand];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self am_expand];
}

- (void)dealloc
{
    [self am_stopFollowingScrollView];
}

- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELLIdentifier"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 64.f;
    _tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    
    [self.view addSubview:_tableView];
}

#pragma mark - tableView data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELLIdentifier"];
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.textLabel.text = [NSString stringWithFormat:@"index %ld", indexPath.row];
    return cell;
}



@end
