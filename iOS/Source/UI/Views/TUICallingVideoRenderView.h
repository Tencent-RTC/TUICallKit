//
//  TUICallingVideoRenderView.h
//  TUICalling
//
//  Created by noah on 2021/8/24.
//

#import <UIKit/UIKit.h>
@class CallUserModel;

NS_ASSUME_NONNULL_BEGIN

@protocol TUICallingVideoRenderViewDelegate <NSObject>

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture;

- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture;

@end

@interface TUICallingVideoRenderView : UIView

/// 手势回调
@property (nonatomic, weak) id<TUICallingVideoRenderViewDelegate> delegate;

/// 配置页面信息
/// @param userModel 用户数据模型
- (void)configViewWithUserModel:(CallUserModel *)userModel;

@end

NS_ASSUME_NONNULL_END
