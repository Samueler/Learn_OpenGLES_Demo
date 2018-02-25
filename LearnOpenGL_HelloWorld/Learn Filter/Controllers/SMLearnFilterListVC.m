//
//  SMLearnFilterListVC.m
//  LearnOpenGL_HelloWorld
//
//  Created by Douqu on 2018/2/25.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMLearnFilterListVC.h"
#import "SMLearnFilterVC.h"

@interface SMLearnFilterListVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *datas;

@end

@implementation SMLearnFilterListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datas = @[@"SMFilterGray", @"SMFilterMosaic"];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SMLearnFilterVC *learnFilterVC = [[SMLearnFilterVC alloc] init];
    learnFilterVC.filterName = self.datas[indexPath.row];
    [self.navigationController pushViewController:learnFilterVC animated:YES];
}

#pragma mark - Lazy Load

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

@end
