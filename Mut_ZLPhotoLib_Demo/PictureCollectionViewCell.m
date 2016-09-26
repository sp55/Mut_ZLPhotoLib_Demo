//
//  PictureCollectionViewCell.m
//  Mut_ZLPhotoLib_Demo
//
//  Created by admin on 16/9/25.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import "PictureCollectionViewCell.h"

@implementation PictureCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)deleteAction:(id)sender {
    
    if (self.deleteBlock) {
        self.deleteBlock();
    }
    
}

@end
