//
//  ALToastView.h
//
//  Created by Alex Leutgöb on 17.07.11.
//  Copyright 2011 alexleutgoeb.com. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "ALToastView.h"


// Set visibility duration
static const CGFloat kDuration = 2;


// Static toastview queue variable
static NSMutableArray *toasts;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface ALToastView ()

@property (nonatomic, readonly) UILabel *textLabel;

- (void)fadeToastOut;
+ (void)nextToastInView:(UIView *)parentView;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation ALToastView

@synthesize textLabel = _textLabel;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithText:(NSString *)text {
	if ((self = [self initWithFrame:CGRectZero])) {
		// Add corner radius
		self.backgroundColor = [UIColor clearColor];
		self.layer.cornerRadius = 5;
		self.autoresizingMask = UIViewAutoresizingNone;
		self.autoresizesSubviews = NO;
		
		// Init and add label
		_textLabel = [[UILabel alloc] init];
		_textLabel.text = text;
		_textLabel.font = [UIFont systemFontOfSize:14];
		_textLabel.textColor = [UIColor whiteColor];
		_textLabel.adjustsFontSizeToFitWidth = NO;
		_textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.numberOfLines = 0;
        CGRect frame = _textLabel.frame;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        frame.size.width = width-20;
        frame.origin.x = 10;
        _textLabel.frame = frame;
		[_textLabel sizeToFit];
		
		[self addSubview:_textLabel];
		//_textLabel.frame = CGRectOffset(_textLabel.frame, 10, 5);
	}
	
	return self;
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

+ (void)toastInView:(UIView *)parentView withText:(NSString *)text {
	// Add new instance to queue
	ALToastView *view = [[ALToastView alloc] initWithText:text];
  
	CGFloat lWidth = view.textLabel.frame.size.width;
	CGFloat lHeight = view.textLabel.frame.size.height;
	CGFloat pWidth = parentView.bounds.size.width;
	CGFloat pHeight = parentView.bounds.size.height;
	
	// Change toastview frame
	view.frame = CGRectMake((pWidth - lWidth - 20) / 2., pHeight - lHeight - 60, lWidth + 20, lHeight + 10);
	view.alpha = 0.0f;
	
	if (toasts == nil) {
		toasts = [[NSMutableArray alloc] initWithCapacity:1];
		[toasts addObject:view];
		[ALToastView nextToastInView:parentView];
	}
	else {
		[toasts addObject:view];
	}

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)fadeToastOut {
	// Fade in parent view
  [UIView animateWithDuration:.8 delay:0 options:UIViewAnimationOptionAllowUserInteraction
   
                   animations:^{
                     self.alpha = 0.f;
                   } 
                   completion:^(BOOL finished){
                     UIView *parentView = self.superview;
                     [self removeFromSuperview];
                     
                     // Remove current view from array
                     [toasts removeObject:self];
                     if ([toasts count] == 0) {
                      
                       toasts = nil;
                     }
                     else
                       [ALToastView nextToastInView:parentView];
                   }];
}


+ (void)nextToastInView:(UIView *)parentView {
	if ([toasts count] > 0) {
    ALToastView *view = [toasts objectAtIndex:0];
    
    //    NSLog(@"Showing toast with text: %@", view.textLabel.text);
        
        CGFloat lWidth = view.textLabel.frame.size.width;
        CGFloat lHeight = view.textLabel.frame.size.height;
        CGFloat pWidth = parentView.frame.size.width;
        CGFloat pHeight = parentView.frame.size.height;
        
        // Change toastview frame
        view.frame = CGRectMake((pWidth - lWidth - 20) / 2., pHeight - lHeight - 60, lWidth + 20, lHeight + 10);

		// Fade into parent view
		[parentView addSubview:view];
    [UIView animateWithDuration:.1  delay:0 options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.alpha = 1.0;
                         [parentView updateConstraints];
                         [parentView layoutIfNeeded];
                         
                     } completion:^(BOOL finished){}];
    
    // Start timer for fade out
    [view performSelector:@selector(fadeToastOut) withObject:nil afterDelay:kDuration];
  }
}

@end
