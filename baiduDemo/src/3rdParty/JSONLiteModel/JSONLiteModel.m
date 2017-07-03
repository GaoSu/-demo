//
//  JSONLiteModel.m
//  StreetScapeFramework
//
//  Created by Captain Stanley on 16/3/10.
//  Copyright © 2016年 map.baidu. All rights reserved.
//

#import "JSONLiteModel.h"
#import <objc/runtime.h>
#import <objc/message.h>

static NSArray *allowedJSONTypes = nil;
static NSDictionary *allowedPrimitiveTypesMap = nil;

@implementation JSONLiteModel

+ (void)initialize {
    if (self == [JSONLiteModel self]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            allowedJSONTypes = @[
                                 [NSString class], [NSNumber class], [NSDecimalNumber class], [NSArray class], [NSDictionary class], [NSNull class], //immutable JSON classes
                                 [NSMutableString class], [NSMutableArray class], [NSMutableDictionary class] //mutable JSON classes
                                 ];
            
            allowedPrimitiveTypesMap = @{@"f":@"float", @"i":@"int", @"d":@"double", @"l":@"long", @"c":@"BOOL", @"s":@"short", @"q":@"long",
                                         //and some famos aliases of primitive types
                                         // BOOL is now "B" on iOS __LP64 builds
                                         @"I":@"NSInteger", @"Q":@"NSUInteger", @"B":@"BOOL",
                                         
                                         @"@?":@"Block"};
        });
    }
}

- (id)initWithString:(NSString *)string error:(NSError **)error {
    if (!string || string.length <= 0) {
        return nil;
    }
    
    id object = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                                options:kNilOptions
                                                  error:error];
    
    if (error) {
        NSLog(@"%@", (*error).domain);
        return nil;
    }
    
    id model = [self initWithDictionary:object error:error];
    return model;
}

- (id)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error {
    if (!dictionary) {
        return nil;
    }
    
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Attempt to initialize from a dictionary but actually it's not a dictionary!");
        return nil;
    }
    
    if (![self init]) {
        return nil;
    }
    
    unsigned int propertyCount = 0;
    NSScanner *scanner = nil;
    NSString *propertyType = nil;   //保存属性类型名
    NSString *protocolType = nil;   //保存属性协议名，仅对数组有效
    
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for (unsigned int i=0; i<propertyCount; i++) {
        objc_property_t property = properties[i];
        //属性名
        NSString *propertyName = @(property_getName(property));
        id value;
        @try {
            value = [dictionary objectForKey:propertyName];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        if (!value || [value isKindOfClass:[NSNull class]]) {
            continue;
        }
        
        //属性类型，形如：T@"类名",&,N,V_属性名 或者 T?,&,N,V_属性名，?代表基本类型
        NSString *attributeName = @(property_getAttributes(property));
        //跳过无用字符
        scanner = [NSScanner scannerWithString:attributeName];
        [scanner scanUpToString:@"T" intoString:nil];
        [scanner scanString:@"T" intoString:nil];
        
        if ([scanner scanString:@"@\"" intoString:nil]) {
            //the property is an instance of cocoa class
            [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&propertyType];
            if ([scanner scanString:@"<" intoString:nil]) {
                [scanner scanUpToString:@">" intoString:&protocolType];
            }
        } else if ([scanner scanString:@"{" intoString: &propertyType]) {
            //the property is an instance of struct， do nothing
            [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:nil];
            continue;
        } else {
            //the property is a primitive type
            [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                    intoString:&propertyType];
            //映射为真实数据类型
            propertyType = allowedPrimitiveTypesMap[propertyType];
        }
        
        NSString *selectorName = [NSString stringWithFormat:@"set%@%@:", [[propertyName substringToIndex:1] uppercaseString], [propertyName substringFromIndex:1]];
        SEL selector = NSSelectorFromString(selectorName);
        
        if ([[allowedPrimitiveTypesMap allValues] containsObject:propertyType]) {
            //基本数据类型，不要使用setter而应该使用setValue
            [self setValue:value forKey: propertyName];
//            ((void (*) (id, SEL, id))objc_msgSend)(self, selector, value);
            continue;
        }
        
        Class propertyClass = NSClassFromString(propertyType);
        
        if ([allowedJSONTypes containsObject:propertyClass]) {
            if ([propertyType rangeOfString:@"NSArray"].location != NSNotFound) {
                //数组类型
                id objArray = [NSClassFromString(protocolType) arrayFromDictionaries:value error:error];
                ((void (*) (id, SEL, id))objc_msgSend)(self, selector, objArray);
                
            } else if ([propertyType rangeOfString:@"NSDictionary"].location != NSNotFound) {
                //字典类型，暂不支持NSDictionary<Key, Value>这种类型的解析
                
            } else {
                //普通类型
                ((void (*) (id, SEL, id))objc_msgSend)(self, selector, value);
            }
        } else if ([propertyClass isSubclassOfClass:[JSONLiteModel class]]) {
            //自定义的类型
            id obj = [[propertyClass alloc] initWithDictionary:value error:error];
            if (self) {
                ((void (*) (id, SEL, id))objc_msgSend)(self, selector, obj);
            }
            
        }
        
    }
    
    return self;
}

+ (NSMutableArray *)arrayFromDictionaries:(NSArray *)array error:(NSError **)error{
    
    NSMutableArray* list = [NSMutableArray arrayWithCapacity: [array count]];
    
    for (NSDictionary* d in array) {
        id obj = [[self alloc] initWithDictionary:d error:error];
        
        [list addObject: obj];
    }
    
    return list;
}

@end
