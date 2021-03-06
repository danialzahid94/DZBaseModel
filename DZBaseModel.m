//
//  BaseEntity.m
//  SDaringGame
//
//  Created by Faheem Ziker on 24/03/2014.
//  Copyright (c) 2014 Appostrophic. All rights reserved.
//

#import "BaseEntity.h"
#import <objc/runtime.h>
@implementation BaseEntity

-(id)initWithDictionary:(NSDictionary *)dictionary {
    self=[super init];
    if(self){
        
    }
    return self;
}

- (void)setValuesForKeysWithJSONDictionary:(NSDictionary *)keyedValues dateFormatter:(NSDateFormatter *)dateFormatter
{
	unsigned int propertyCount;
	objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
	
	/*
	 This code iterates over self's properties instead of ivars because the backing ivar might have a different name
	 than the property, for example if the class includes something like:
	 
	 @synthesize foo = foo_;
	 
	 In this case what we really want is "foo", not "foo_", since the incoming keys in keyedValues probably
	 don't have the underscore. Looking through properties gets "foo", looking through ivars gets "foo_".
	 */
	for (int i=0; i<propertyCount; i++) {
		objc_property_t property = properties[i];
		const char *propertyName = property_getName(property);
		NSString *keyName = [NSString stringWithUTF8String:propertyName];
		
		id value = [keyedValues objectForKey:keyName];
		if (value != nil) {
			char *typeEncoding = NULL;
			typeEncoding = property_copyAttributeValue(property, "T");
			
			if (typeEncoding == NULL) {
				continue;
			}
			switch (typeEncoding[0]) {
				case '@':
				{
					// Object
					Class class = nil;
					if (strlen(typeEncoding) >= 3) {
						char *className = strndup(typeEncoding+2, strlen(typeEncoding)-3);
						class = NSClassFromString([NSString stringWithUTF8String:className]);
                        free(className);
					}
					// Check for type mismatch, attempt to compensate
					if ([class isSubclassOfClass:[NSString class]] && [value isKindOfClass:[NSNumber class]]) {
						value = [value stringValue];
					} else if ([class isSubclassOfClass:[NSNumber class]] && [value isKindOfClass:[NSString class]]) {
						// If the ivar is an NSNumber we really can't tell if it's intended as an integer, float, etc.
						NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
						[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
						value = [numberFormatter numberFromString:value];
						
					} else if ([class isSubclassOfClass:[NSDate class]] && [value isKindOfClass:[NSString class]] && (dateFormatter != nil)) {
						value = [dateFormatter dateFromString:value];
					}
					
					break;
				}
					
				case 'i': // int
				case 's': // short
				case 'l': // long
				case 'q': // long long
				case 'I': // unsigned int
				case 'S': // unsigned short
				case 'L': // unsigned long
				case 'Q': // unsigned long long
				case 'f': // float
				case 'd': // double
				case 'B': // BOOL
				{
					if ([value isKindOfClass:[NSString class]]) {
						NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
						[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
						value = [numberFormatter numberFromString:value];
						
					}
					break;
				}
					
				case 'c': // char
				case 'C': // unsigned char
				{
					if ([value isKindOfClass:[NSString class]]) {
						char firstCharacter = [value characterAtIndex:0];
						value = [NSNumber numberWithChar:firstCharacter];
					}
					break;
				}
					
				default:
				{
					break;
				}
			}
            if(value != [NSNull null]){
                [self setValue:value forKey:keyName];
            }
			
			free(typeEncoding);
		}
	}
	free(properties);
}

@end
