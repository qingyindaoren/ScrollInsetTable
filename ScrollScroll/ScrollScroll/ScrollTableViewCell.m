//
//  ScrollTableViewCell.m
//  ScrollScroll
//
//  Created by 美融城 on 2017/9/8.
//  Copyright © 2017年 美融城. All rights reserved.
//

#import "ScrollTableViewCell.h"

@implementation ScrollTableViewCell
- (IBAction)didSelectCell:(UIButton *)sender {
    if (self.selectCellBlock) {
        self.selectCellBlock(self.indexPath);
    }
 
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
