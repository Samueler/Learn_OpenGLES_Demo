//
//  SMLearnFilterVC.m
//  LearnOpenGL_HelloWorld
//
//  Created by Douqu on 2018/2/25.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMLearnFilterVC.h"
#import "SMFilterView.h"

@interface SMLearnFilterVC ()

@property (nonatomic, strong) SMFilterView *filterView;

@end

@implementation SMLearnFilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.filterView = [[SMFilterView alloc] initWithFrame:self.view.bounds filter:self.filterName];
    [self.view addSubview:self.filterView];
}

@end
