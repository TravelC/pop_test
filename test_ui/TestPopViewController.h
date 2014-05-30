//
//  TestUpnpViewController.h
//  test_ui
//
//  Created by udntv on 2014/5/26.
//  Copyright (c) 2014年 pd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlowViewLayout.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <POP/POP.h>

@interface TestPopViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, POPAnimationDelegate>
{
    NSInteger   _cellCount;
    CGRect      _rect;
    CGPoint     _point;
}
@end

typedef enum GestureInitMove {
    GESTURE_INIT_MOVE_NONE = 0,
    GESTURE_INIT_MOVE_LR,
    GESTURE_INIT_MOVE_UD,
    
} GESTURE_INIT_MOVE;

typedef enum GestureState {
    GESTURE_STATE_NONE = 0,
    GESTURE_STATE_SINGLE_TOUCH_DRAG,
    GESTURE_STATE_SINGLE_TOUCH_SWIPE,
    GESTURE_STATE_SINGLE_TOUCH_UD_END,
    GESTURE_STATE_SINGLE_TOUCH_LR_END
    
} GESTURE_STATE;

@interface WildcardGestureRecognizer : UIGestureRecognizer {
    BOOL                _moved;
    CGPoint             _initContentOffset;
    double              _scale;
    CGPoint             _startPoint;
    CGPoint             _startPointInParent;
    CGRect              _initFrame;
    GESTURE_STATE       _actState;
    UITouch             *_startTouch;
    GESTURE_INIT_MOVE   _initMove;
    CGPoint             _movePoint;
    CGPoint             _preMovePoint;
    NSInteger           _dragX;
}

@property (nonatomic, assign, readonly, getter = dragX) NSInteger dragX;
@property (nonatomic, assign, readonly, getter = startPoint) CGPoint _startPoint;
@property (nonatomic, assign, readonly, getter = startPointInParent) CGPoint _startPointInParent;
@property (nonatomic, assign, readonly, getter = scale) double _scale;
@property (nonatomic, assign, readonly, getter = actState) GESTURE_STATE _actState;

-(CGPoint) firstTouchPointInParent;
@end