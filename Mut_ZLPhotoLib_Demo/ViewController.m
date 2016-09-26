//
//  ViewController.m
//  Mut_ZLPhotoLib_Demo
//
//  Created by admin on 16/9/25.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#define kMaxUploads 15
#import "ZLPhoto.h"
#import "PictureCollectionViewCell.h"

#import "ViewController.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height


@interface ViewController ()<UICollectionViewDelegateFlowLayout,ZLPhotoPickerViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *imgDataArr;//检查报告
@property (weak, nonatomic) IBOutlet UICollectionView *checkReportPicsCollectionView;
@property (weak, nonatomic) IBOutlet UIView *checkReportPicsMaskView;
@property (weak, nonatomic) IBOutlet UIImageView *addImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imgDataArr = [NSMutableArray new];
    
    [self.checkReportPicsCollectionView registerNib:[UINib nibWithNibName:@"PictureCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PictureCollectionViewCell"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseCheckReport:)];
    [self.addImageView addGestureRecognizer:tap];
}
- (void)chooseCheckReport:(UITapGestureRecognizer *)tap {
    
    [self.view endEditing:YES];
    
    UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //添加
    __weak typeof(self) weakSelf = self;
    UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //拍照
        [weakSelf openZLCameraPickerVC];
    }];
    UIAlertAction *neverAction = [UIAlertAction actionWithTitle:@"从相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // 相册
        [weakSelf openZLPhotoPickerVC];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // 取消按键
    }];
    
    // 添加操作（顺序就是呈现的上下顺序）
    [alertDialog addAction:laterAction];
    [alertDialog addAction:neverAction];
    [alertDialog addAction:okAction];
    
    // 呈现警告视图
    [self presentViewController:alertDialog animated:YES completion:nil];
}

#pragma mark --- 选择照片的代理方法
//照相
-(void)openZLCameraPickerVC
{
    ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
    // 拍照最多个数
    NSInteger currentImgs = self.imgDataArr.count - 1;
    if (currentImgs >= kMaxUploads) {
        cameraVc.maxCount = 0;
    }else{
        cameraVc.maxCount = kMaxUploads - currentImgs;
    }
    __weak typeof(self) weakSelf = self;
    cameraVc.callback = ^(NSArray *cameras){
        [weakSelf refreshCollection:cameras];
    };
    [cameraVc showPickerVc:self];
    
}
#pragma mark - 打开ZLPhotoPickerViewController - 相册
//相册
-(void)openZLPhotoPickerVC
{
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.delegate = self;
    // 最多能选1张图片 这里 self.photoArr里面包含添加照片那个View
    NSInteger currentImgs = self.imgDataArr.count - 1;
    if (currentImgs >= kMaxUploads) {
        pickerVc.maxCount = 0;
    }else{
        pickerVc.maxCount =  kMaxUploads - currentImgs;
    }
    pickerVc.status = PickerViewShowStatusCameraRoll;
    [pickerVc showPickerVc:self];
    
}
#pragma mark - ZLPhotoPickerViewControllerDelegate

- (void)pickerViewControllerDoneAsstes:(NSArray *)assets{
    [self refreshCollection:assets];
}


#pragma mark ---获取照片后显示图片
- (void)refreshCollection:(NSArray *)array {
    __block UIImage *image = [UIImage new];
    
    if (self.imgDataArr.count > 0) {
        [self.imgDataArr removeLastObject];
    }
    for (id asset in array) {
        if ([asset isKindOfClass:[ZLPhotoAssets class]]) {
            image = [asset aspectRatioImage];
        }else if ([asset isKindOfClass:[NSString class]]){
            
        }else if ([asset isKindOfClass:[UIImage class]]){
            image = (UIImage *)asset;
        }else if ([asset isKindOfClass:[ZLCamera class]]){
            image = [asset thumbImage];
        }
        
        [self.imgDataArr addObject:image];
    }
    
    
    
    [self.imgDataArr addObject:[UIImage imageNamed:@"jh"]];
    
    if (self.imgDataArr.count > 0) {
        NSLog(@"照片--->:%@",self.imgDataArr);
        self.checkReportPicsMaskView.hidden = YES;
        [self.checkReportPicsCollectionView reloadData];
    }else{
        self.checkReportPicsMaskView.hidden = NO;
    }
    
}

#pragma mark -- UICollectionView delegate & dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.imgDataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PictureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PictureCollectionViewCell" forIndexPath:indexPath];

    if (self.imgDataArr.count == 1) {
        [self.imgDataArr removeAllObjects];
        self.checkReportPicsMaskView.hidden = NO;
        cell.imageView.image = nil;
        
    }else{
        cell.imageView.image = self.imgDataArr[indexPath.item];
    }
    
    if (indexPath.item == self.imgDataArr.count -1 && self.imgDataArr.count > 0) {
        cell.deleteBtn.hidden = YES;
    }else{
        cell.deleteBtn.hidden = NO;
    }
    
    
    __weak typeof(self) weakSelf = self;

    cell.deleteBlock = ^(){
        [weakSelf.imgDataArr removeObjectAtIndex:indexPath.item];
        [weakSelf.checkReportPicsCollectionView reloadData];
    };
    return cell;
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.imgDataArr.count - 1) {
        [self chooseCheckReport:nil];
    }else{
        //next
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    //行间距
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    //列间距
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (ScreenWidth - 20) / 3;
    return CGSizeMake(width, width);
}

@end
