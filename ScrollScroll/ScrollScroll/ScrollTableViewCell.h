//
//  ScrollTableViewCell.h
//  ScrollScroll
//
//  Created by 美融城 on 2017/9/8.
//  Copyright © 2017年 美融城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *Titletext;
@property (weak, nonatomic) IBOutlet UILabel *detailText;
@property (nonatomic,strong)NSIndexPath* indexPath;
@property (nonatomic,strong)void (^selectCellBlock)(NSIndexPath*indexPath);

@end
