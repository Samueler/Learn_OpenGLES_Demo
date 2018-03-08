//
//  ViewController.m
//  LearnOpenGL_HelloWorld
//
//  Created by Samueler on 2018/1/4.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "ViewController.h"
#import "SMHelloWorld.h"
#import "SMTwoTriangles.h"
#import "SMLearnShaderVC.h"
#import "SMLearnTextureVC.h"
#import "SMTransformVC.h"
#import "SMLearn3DVC.h"
#import "SMTenBoxesVC.h"
#import "SMLearnCameraVC.h"
#import "SMLearnLightVC.h"
#import "SMLearnFilterListVC.h"
#import "SMCameraVC.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) NSArray *vcNames;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datas = @[@"Hello World!", @"Two Triangle", @"Learn Shaders", @"Texture", @"Transform", @"Learn 3D", @"Ten Boxes", @"Learn Camera", @"Learn Light", @"Learn Filter", @"SMCamera"];
    self.vcNames = @[@"SMHelloWorld", @"SMTwoTriangles", @"SMLearnShaderVC", @"SMLearnTextureVC", @"SMTransformVC", @"SMLearn3DVC", @"SMTenBoxesVC", @"SMLearnCameraVC", @"SMLearnLightVC", @"SMLearnFilterListVC", @"SMCameraVC"];
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
    
    Class destionClass = NSClassFromString(self.vcNames[indexPath.row]);
    UIViewController *destionvc = [[destionClass alloc] init];
    [self.navigationController pushViewController:destionvc animated:YES];
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
