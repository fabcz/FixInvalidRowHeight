//
//  ViewController.m
//  FixInvalidRowHeight
//
//  Created by 程聪 on 2019/12/4.
//  Copyright © 2019 程聪. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@end


@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.grayColor;
    
    [self.view addSubview:({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(30, 50, 300, 500) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView;
    })];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ({
        UITableViewCell *cell = UITableViewCell.new;
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.blueColor : UIColor.greenColor;
        cell;
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = (int)arc4random_uniform(2) == 1 ? 50 : -100;
    if (height < 0) {
        // 模拟 layout 后能拿到正常的高度
        [tableView reloadData];
    }
    return height;
}
@end
