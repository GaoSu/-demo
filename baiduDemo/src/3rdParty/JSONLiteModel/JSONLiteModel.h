//
//  JSONLiteModel.h
//  StreetScapeFramework
//
//  Created by Captain Stanley on 16/3/10.
//  Copyright © 2016年 map.baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONLiteModel : NSObject

/**
 *  @abstract 将json字符串转换为对象
 *  @params string 待解析的json字符串
 *  @return 该类型的实例对象
 */
- (id)initWithString:(NSString *)string error:(NSError **)error;

/**
 *  @abstract 将字典转换为对象
 *  @params dictionary 待解析的json字典
 *  @return 该类型的实例对象
 */
- (id)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;
@end
