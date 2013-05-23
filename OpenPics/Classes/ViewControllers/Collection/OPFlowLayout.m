// OPFlowLayout.m
// 
// Copyright (c) 2013 Say Goodnight Software
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

#import "OPFlowLayout.h"

@implementation OPFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {

    NSArray* arr = [super layoutAttributesForElementsInRect:rect];
    
    // THIS CODE SEPARATES INTO ROWS
    //
    // CURRENTLY HAS BUG:  search for 'boston' in LOC
    //    seems likely something to do with when an item is a lone item on a row.
    NSMutableArray* rows = [NSMutableArray array];
    NSMutableArray* currentRow = nil;
    NSInteger currentIndex = 0;
    BOOL nextIsNewRow = YES;
    for (UICollectionViewLayoutAttributes* atts in arr) {
        if (nextIsNewRow) {
            nextIsNewRow = NO;
            if (currentRow) {
                [rows addObject:currentRow];
            }
            currentRow = [NSMutableArray array];
        }

        if (arr.count > currentIndex+1) {
            UICollectionViewLayoutAttributes* nextAtts = arr[currentIndex+1];
            if (nextAtts.frame.origin.x < atts.frame.origin.x) {
                nextIsNewRow = YES;
            }
        }
        
        [currentRow addObject:atts];
        currentIndex++;
    }

    
    // Evenly filled -- erro on iphone sim.   cell reuse maybe?
    for (NSMutableArray* thisRow in rows) {
        NSInteger rowWidth = [self getWidthOfRow:thisRow];
        CGFloat perItemWidthDifference = (rect.size.width - self.sectionInset.left - self.sectionInset.right - rowWidth) / thisRow.count;
        
        UICollectionViewLayoutAttributes* firstInRowAttrs = thisRow[0];
        NSInteger currentXOffset = firstInRowAttrs.frame.origin.x;
        for (UICollectionViewLayoutAttributes* attrs in thisRow) {
            CGRect f = attrs.frame;
            f.origin.x = currentXOffset;
            f.size.width = f.size.width + perItemWidthDifference;
            attrs.frame = f;
            
            currentXOffset +=  attrs.frame.size.width + 2;
        }
    }
    
    // Center Justified
//    for (NSMutableArray* thisRow in rows) {
//        NSInteger rowWidth = [self getWidthOfRow:thisRow];
//        NSInteger margin = (rect.size.width - rowWidth) / 2;
//        NSInteger currentXOffset = margin;
//        for (UICollectionViewLayoutAttributes* attrs in thisRow) {
//            CGRect f = attrs.frame;
//            f.origin.x = currentXOffset;
//            attrs.frame = f;
//            
//            currentXOffset +=  attrs.frame.size.width + 2;
//        }
//    }
    return arr;
}

#pragma mark - Helpers

- (NSInteger) getWidthOfRow:(NSMutableArray*) row {
    NSInteger widthTotal = 0;
    for (UICollectionViewLayoutAttributes* attrs in row) {
        widthTotal += attrs.frame.size.width;
    }
    
    widthTotal += (row.count - 1) * 2;
    
    return widthTotal;
}

@end
