//
//  TestUpnpViewController.m
//  test_ui
//
//  Created by udntv on 2014/5/26.
//  Copyright (c) 2014年 pd. All rights reserved.
//

#import "TestPopViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FlowViewLayout.h"
#import <POP/POP.h>
#import "ReflectionView.h"


@implementation WildcardGestureRecognizer

@synthesize _actState;
@synthesize _scale;
@synthesize _startPoint;
@synthesize _startPointInParent;



-(id) init{
    if (self = [super init])
    {
        self.cancelsTouchesInView = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _initFrame = self.view.frame;
    _initContentOffset = ((UICollectionView*)self.view).contentOffset;
    _startTouch = [touches anyObject];
    _startPoint = [_startTouch locationInView:self.view];
    _startPointInParent = [_startTouch locationInView:self.view.superview];
    
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _moved = YES;
    
    if(_initMove == GESTURE_INIT_MOVE_NONE)
    {
        CGPoint locationPoint  = [[touches anyObject] locationInView:self.view];
        CGFloat diffX = abs(_startPoint.x -locationPoint.x);
        CGFloat diffY = abs(_startPoint.y -locationPoint.y);
        if(diffX > diffY)
            _initMove = GESTURE_INIT_MOVE_LR;
        else
            _initMove = GESTURE_INIT_MOVE_UD;
    }
    
    _movePoint = [_startTouch locationInView:self.view.superview];
    _dragX = _preMovePoint.x - _movePoint.x ;
    _preMovePoint = _movePoint;

    CGPoint fp = [_startTouch locationInView:self.view.superview];
    double startDistance = _initFrame.size.height + _initFrame.origin.y - _startPointInParent.y;
    double moveDistance = _initFrame.size.height + _initFrame.origin.y - fp.y;
    
    if(_initMove == GESTURE_INIT_MOVE_LR)
    {
        _actState = GESTURE_STATE_SINGLE_TOUCH_SWIPE;
    }
    else if(_initMove == GESTURE_INIT_MOVE_UD)
    {
        _scale = moveDistance / startDistance;
        _actState = GESTURE_STATE_SINGLE_TOUCH_DRAG;
    }
}

-(CGPoint) firstTouchPointInParent
{
    return [_startTouch locationInView:self.view.superview];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if(_initMove == GESTURE_INIT_MOVE_LR)
    {
        _actState = GESTURE_STATE_SINGLE_TOUCH_LR_END;
    }
    else{
        _actState = GESTURE_STATE_SINGLE_TOUCH_UD_END;
    }
    self.state = UIGestureRecognizerStateRecognized;
}

- (void)reset
{
    _actState = GESTURE_STATE_NONE;
    _moved = NO;
    _initMove = GESTURE_INIT_MOVE_NONE;
}

@end



@interface TestPopViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet ReflectionView *reflectionView;
@end

@implementation TestPopViewController

static CGRect       tempFrame;
static CGPoint      tempCenter;
static CGSize       tempContentSize;
static CGPoint      tempContentOffset;
static NSIndexPath  *tempPath;
static CGFloat      tempCellWidth;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    WildcardGestureRecognizer *panRecognizer = [[WildcardGestureRecognizer alloc] initWithTarget:self action:@selector(detectGesture:)];
    [self.collectionView setGestureRecognizers:@[panRecognizer]];
    _cellCount = 10;
    self.reflectionView.reflectionAlpha = 1;
    self.reflectionView.reflectionGap = 0;
}

- (void) detectGesture:(WildcardGestureRecognizer *) uiGestureRecognizer
{
    if([uiGestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        tempFrame  = [uiGestureRecognizer view].frame;
        tempCenter = [uiGestureRecognizer view].center;
        tempContentOffset = self.collectionView.contentOffset;
        tempPath = nil;
        tempContentSize = self.collectionView.contentSize;
        
        NSArray *cellAry = [self.collectionView visibleCells];
        for(UICollectionViewCell *cell in cellAry)
        {
            //取得點擊cell的indexpath
            BOOL isInside = CGRectContainsPoint(cell.frame, [uiGestureRecognizer startPoint]);
            if(isInside)
            {
                tempPath = [self.collectionView indexPathForCell:cell];
                tempCellWidth = cell.frame.size.width;
            }
        }
    }
    [self.collectionView pop_removeAllAnimations];
    
    GESTURE_STATE act = [uiGestureRecognizer actState];
    if(act == GESTURE_STATE_SINGLE_TOUCH_DRAG)
    {
        CGRect frame = [uiGestureRecognizer view].frame;
        frame.size.height = tempFrame.size.height * [uiGestureRecognizer scale] ;
        frame.origin.y = uiGestureRecognizer.view.superview.frame.size.height - frame.size.height;
        uiGestureRecognizer.view.frame = frame;
        
        CGPoint newOffset = CGPointMake( (tempContentOffset.x + [uiGestureRecognizer startPointInParent].x) * [uiGestureRecognizer scale]
                                        - [uiGestureRecognizer startPointInParent ].x
                                        - ([uiGestureRecognizer locationInView:self.view].x - [uiGestureRecognizer startPointInParent].x)
                                        ,
                                        tempContentOffset.y);
        
        //設定前後inset  如果拉超過前後就設定inset以避免強制將contentsetX設為0
        CGFloat leftInset = 0, rightInset = 0;
        if(newOffset.x < 0)
            leftInset = abs(newOffset.x);
        
        float rightOverSpace = tempContentSize.width *[uiGestureRecognizer scale]  - (newOffset.x + frame.size.width);
        if(rightOverSpace < 0)
            rightInset = abs(rightOverSpace);
        
        if((leftInset + rightInset) != 0)
        {
            [self.collectionView setContentInset:UIEdgeInsetsMake(0, leftInset, 0, rightInset)];
        }
        [self.collectionView  setContentOffset:newOffset];
        
    }
    else if(act == GESTURE_STATE_SINGLE_TOUCH_SWIPE){
        
        CGRect frame = [uiGestureRecognizer view].frame;
        CGPoint fp = [uiGestureRecognizer firstTouchPointInParent];
        CGPoint startPointInParent = [uiGestureRecognizer startPointInParent];
        CGPoint newOffset = CGPointMake(tempContentOffset.x - fp.x + startPointInParent.x, tempContentOffset.y);
        
        CGFloat leftInset = 0, rightInset = 0;
        if(newOffset.x < 0)
            leftInset = abs(newOffset.x);
        
        float rightOverSpace = tempContentSize.width  - (newOffset.x + frame.size.width);
        if(rightOverSpace < 0)
            rightInset = abs(rightOverSpace);
        
        if((leftInset + rightInset) != 0)
        {
            [self.collectionView setContentInset:UIEdgeInsetsMake(0, leftInset, 0, rightInset)];
        }
        
        [self.collectionView  setContentOffset:newOffset];
    }
    else if(act == GESTURE_STATE_SINGLE_TOUCH_UD_END)
    {
        if (uiGestureRecognizer.view.frame.size.height > self.view.frame.size.height/2)
        {
            POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim.duration = 0.3;
            anim.fromValue = [NSValue valueWithCGRect:self.collectionView.frame];
            anim.toValue = [NSValue valueWithCGRect:self.view.frame];
            anim.delegate = self;
            anim.name = @"test1";
            [self.collectionView pop_addAnimation:anim forKey:@"size"];
            
            [self.collectionView pop_removeAnimationForKey:@"offset"];
            POPBasicAnimation *anim2 = [POPBasicAnimation animationWithPropertyNamed:kPOPScrollViewContentOffset];
            anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim2.duration = 0.3;
            anim2.fromValue = [NSValue valueWithCGPoint:self.collectionView.contentOffset];
            anim2.toValue = [NSValue valueWithCGPoint:CGPointMake( tempPath.row * [FlowViewLayout getWidthWithHeight:self.view.frame.size.height] , 0)];
            [self.collectionView  pop_addAnimation:anim2 forKey:@"offset"];
            
            self.collectionView.pagingEnabled = YES;
        }
        else{
            CGRect smallRect = CGRectMake(0, self.view.frame.size.height - 240, 320, 240);
            
            POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim.duration = 0.3;
            anim.fromValue = [NSValue valueWithCGRect:self.collectionView.frame];
            anim.toValue = [NSValue valueWithCGRect:smallRect];
            anim.delegate = self;
            [self.collectionView pop_addAnimation:anim forKey:@"size"];
            
            self.collectionView.pagingEnabled = NO;
            [self setToListRange:0 height:240];
        }
    }
    else if(act == GESTURE_STATE_SINGLE_TOUCH_LR_END)
    {
        NSInteger drag = [uiGestureRecognizer dragX];
        
        if(self.collectionView.frame.size.height > 240)
        {
            NSInteger idx;
            if(drag != 0)
            {
                idx = tempPath.row + (drag > 0?1:-1) ;
            }
            else
            {
                idx = tempPath.row;
                CGPoint curPoint = self.collectionView.contentOffset;
                CGPoint startPoint = tempContentOffset;
                if(curPoint.x - startPoint.x > 160) idx++;
                if(curPoint.x - startPoint.x < -160) idx--;
            }
            if(idx < 0)    idx = 0;
            if(idx >= _cellCount)    idx = _cellCount -1;
            
            POPBasicAnimation *anim2 = [POPBasicAnimation animationWithPropertyNamed:kPOPScrollViewContentOffset];
            anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            anim2.duration = 0.2;
            anim2.fromValue = [NSValue valueWithCGPoint:self.collectionView.contentOffset];
            anim2.toValue = [NSValue valueWithCGPoint:CGPointMake(idx * [FlowViewLayout getWidthWithHeight:self.view.frame.size.height] , 0)];
            [self.collectionView  pop_addAnimation:anim2 forKey:@"offset"];
        }
        else
        {
            if(drag != 0)
            {
                POPDecayAnimation *anim2 = [POPDecayAnimation animationWithPropertyNamed:kPOPScrollViewContentOffset];
                anim2.velocity = [NSValue valueWithCGPoint:CGPointMake( drag*  80, 0)];
                anim2.name = @"drag";
                anim2.delegate = self;
                [self.collectionView  pop_addAnimation:anim2 forKey:@"offset"];
            }
            else{
                [self setToListRange:0 height:self.collectionView.frame.size.height];
            }
        }
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _cellCount;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor colorWithRed:(indexPath.row %4)/4.0f green:1 blue:(indexPath.row %4)/4.0f alpha:1]];
    
    return cell;
}

- (void)pop_animationDidReachToValue:(POPAnimation *)anim
{
    [self.collectionView flashScrollIndicators];

    if([anim.name isEqualToString:@"drag"])
    {
        [self setToListRange:0 height:self.collectionView.frame.size.height];
    }
}

- (void)pop_animationDidApply:(POPAnimation *)anim
{
    [self.collectionView flashScrollIndicators];
    if([anim.name isEqualToString:@"drag"])
    {
        [self setToListRange:50 height:self.collectionView.frame.size.height];
    }
}

-(void) setToListRange:(CGFloat) limit height:(CGFloat) height
{
    //超出左邊邊界
    if(self.collectionView.contentOffset.x < -limit)
    {
        [self.collectionView pop_removeAnimationForKey:@"offset"];
        POPBasicAnimation *anim2 = [POPBasicAnimation animationWithPropertyNamed:kPOPScrollViewContentOffset];
        anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim2.duration = 0.3;
        anim2.fromValue = [NSValue valueWithCGPoint:self.collectionView.contentOffset];
        anim2.toValue = [NSValue valueWithCGPoint:CGPointMake( 0, 0)];
        [self.collectionView  pop_addAnimation:anim2 forKey:@"offset"];
    }
    //超出右邊邊界
    if((self.collectionView.contentOffset.x + self.collectionView.frame.size.width - self.collectionView.contentSize.width) > limit)
    {
        [self.collectionView pop_removeAnimationForKey:@"offset"];
        POPBasicAnimation *anim2 = [POPBasicAnimation animationWithPropertyNamed:kPOPScrollViewContentOffset];
        anim2.duration = 0.3;
        anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim2.fromValue = [NSValue valueWithCGPoint:self.collectionView.contentOffset];
        anim2.toValue = [NSValue valueWithCGPoint:CGPointMake( _cellCount* [FlowViewLayout getWidthWithHeight:height] - 320 , 0)];
        [self.collectionView  pop_addAnimation:anim2 forKey:@"offset"];
    }
}

@end
