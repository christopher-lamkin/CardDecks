//
//
// CDXCardDeck.h
//
//
// Copyright (c) 2009-2010 Arne Harren <ah@0xc0.de>
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

#import "CDXCard.h"


typedef enum {
    CDXCardDeckDisplayStyleSideBySide,
    CDXCardDeckDisplayStyleStack
} CDXCardDeckDisplayStyle;


@interface CDXCardDeck : NSObject {
    
@protected
    NSString *name;
    
    CDXColor *defaultCardTextColor;
    CDXColor *defaultCardBackgroundColor;
    CDXCardOrientation defaultCardOrientation;
    
    NSMutableArray *cards;
    
    CDXCardDeckDisplayStyle displayStyle;
    BOOL showPageControl;
    CDXCardCornerStyle cornerStyle;
    CGFloat fontSize;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) CDXColor *defaultCardTextColor;
@property (nonatomic, retain) CDXColor *defaultCardBackgroundColor;
@property (nonatomic, assign) CDXCardOrientation defaultCardOrientation;

- (NSUInteger)cardsCount;
- (CDXCard *)cardAtIndex:(NSUInteger)index;
- (void)addCard:(CDXCard *)card;
- (void)insertCard:(CDXCard *)card atIndex:(NSUInteger)index;
- (void)removeCardAtIndex:(NSUInteger)index;

@property (nonatomic, assign) CDXCardDeckDisplayStyle displayStyle;
@property (nonatomic, assign) BOOL showPageControl;
@property (nonatomic, assign) CDXCardCornerStyle cornerStyle;
@property (nonatomic, assign) CGFloat fontSize;

- (CDXCard *)cardWithDefaults;

@end

