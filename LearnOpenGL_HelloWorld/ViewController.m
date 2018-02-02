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

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datas = @[@"Hello World!", @"Two Triangle", @"Learn Shaders", @"Texture", @"Transform", @"Learn 3D", @"Ten Boxes", @"Learn Camera", @"Learn Light"];
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
    if (indexPath.row == 0) {
        SMHelloWorld *helloWorldvc = [[SMHelloWorld alloc] init];
        [self.navigationController pushViewController:helloWorldvc animated:YES];
    } else if (indexPath.row == 1) {
        SMTwoTriangles *twoTrianglesvc = [[SMTwoTriangles alloc] init];
        [self.navigationController pushViewController:twoTrianglesvc animated:YES];
    } else if (indexPath.row == 2) {
        SMLearnShaderVC *learnShadervc = [[SMLearnShaderVC alloc] init];
        [self.navigationController pushViewController:learnShadervc animated:YES];
    } else if (indexPath.row == 3) {
        SMLearnTextureVC *texturevc = [[SMLearnTextureVC alloc] init];
        [self.navigationController pushViewController:texturevc animated:YES];
    } else if (indexPath.row == 4) {
        SMTransformVC *transformvc = [[SMTransformVC alloc] init];
        [self.navigationController pushViewController:transformvc animated:YES];
    } else if (indexPath.row == 5) {
        SMLearn3DVC *threeDvc = [[SMLearn3DVC alloc] init];
        [self.navigationController pushViewController:threeDvc animated:YES];
    } else if (indexPath.row == 6) {
        SMTenBoxesVC *tenBoxesvc = [[SMTenBoxesVC alloc] init];
        [self.navigationController pushViewController:tenBoxesvc animated:YES];
    } else if (indexPath.row == 7) {
        SMLearnCameraVC *learnCameravc = [[SMLearnCameraVC alloc] init];
        [self.navigationController pushViewController:learnCameravc animated:YES];
    } else if (indexPath.row == 8) {
        SMLearnLightVC *learnLightvc = [[SMLearnLightVC alloc] init];
        [self.navigationController pushViewController:learnLightvc animated:YES];
    }
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
