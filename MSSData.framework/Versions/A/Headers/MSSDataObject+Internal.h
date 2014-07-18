//
//  MSSDataObject+Internal.h
//  
//
//  Created by Elliott Garcea on 2014-06-12.
//
//

#import "MSSDataObject.h"

typedef void (^HTTPSuccessBlock)(AFHTTPRequestOperation *, id);
typedef void (^HTTPFailureBlock)(AFHTTPRequestOperation *, NSError *);

@interface MSSDataObject (Internal)

@property (nonatomic, readonly) NSMutableDictionary *contentsDictionary;

@end
