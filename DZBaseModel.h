//
//  BaseEntity.h
//  SDaringGame
//
//  Created by Faheem Ziker on 24/03/2014.
//  Copyright (c) 2014 Appostrophic. All rights reserved.
//

//
//  BaseEntity.h
//  HPSmart
//
//  Created by Faheem Ziker on 14/01/2014.
//  Copyright (c) 2014 V7iTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseEntity : NSObject


- (void)setValuesForKeysWithJSONDictionary:(NSDictionary *)keyedValues dateFormatter:(NSDateFormatter *)dateFormatter;
-(id)initWithDictionary:(NSDictionary *)dictionary;

@end