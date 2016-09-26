//
//  PictureCollectionViewCell.h
//  Mut_ZLPhotoLib_Demo
//
//  Created by admin on 16/9/25.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureCollectionViewCell : UICollectionViewCell
@property (nonatomic, copy) void (^deleteBlock)();//删除图片的block

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;


- (IBAction)deleteAction:(id)sender;

@end
