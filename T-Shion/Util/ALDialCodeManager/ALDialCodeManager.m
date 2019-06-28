//
//  ALDialCodeManager.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/9.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALDialCodeManager.h"

@interface ALDialCodeManager ()

@property (nonatomic) dispatch_queue_t queue;

@end


@implementation ALDialCodeManager

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_queue_create("com.dialCode.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (instancetype)sharedInstance {
    static id shared_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared_instance = [[self alloc] init];
    });
    return shared_instance;
}

#pragma mark - private
- (NSMutableArray *)readLocalFileWithName {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tel_code" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (NSString *)al_firstCharacterWithString:(NSString *)string {
    if (string.length == 0)
    {
        return @"#";
    }
    
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    
    NSMutableString *pinyinString = [[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]] mutableCopy];
    NSString *str = [string substringToIndex:1];
    
    // 多音字处理
    if ([str isEqualToString:@"长"])
    {
        [pinyinString replaceCharactersInRange:NSMakeRange(0, 5) withString:@"chang"];
    }
    if ([str isEqualToString:@"沈"])
    {
        [pinyinString replaceCharactersInRange:NSMakeRange(0, 4) withString:@"shen"];
    }
    if ([str isEqualToString:@"厦"])
    {
        [pinyinString replaceCharactersInRange:NSMakeRange(0, 3) withString:@"xia"];
    }
    if ([str isEqualToString:@"地"])
    {
        [pinyinString replaceCharactersInRange:NSMakeRange(0, 2) withString:@"di"];
    }
    if ([str isEqualToString:@"重"])
    {
        [pinyinString replaceCharactersInRange:NSMakeRange(0, 5) withString:@"chong"];
    }
    
    NSString *upperStr = [[pinyinString substringToIndex:1] uppercaseString];
    
    NSString *regex = @"^[A-Z]$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    NSString *firstCharacter = [predicate evaluateWithObject:upperStr] ? upperStr : @"#";
    
    return firstCharacter;
}


#pragma mark - public
- (void)al_dialCodeSectionWithEnglish:(BOOL)isEnglish complection:(void (^)(NSArray<ALDialCodeSectionModel *> *, NSArray<NSString *> *, NSArray<ALDialCodeModel *> *))completcion {
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        NSMutableArray *modelArray = [ALDialCodeModel mj_objectArrayWithKeyValuesArray:[self readLocalFileWithName]];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        for (ALDialCodeModel *dialModel in modelArray) {
            NSString *firstLetter = [self al_firstCharacterWithString:isEnglish?dialModel.en_name:dialModel.cn_name];
            
            if (dict[firstLetter]) {
                [dict[firstLetter] addObject:dialModel];
            } else {
                NSMutableArray *arr = [NSMutableArray arrayWithObjects:dialModel, nil];
                [dict setValue:arr forKey:firstLetter];
            }
        }
        
        NSMutableArray *keys = [[[dict allKeys] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
        
        if ([keys.firstObject isEqualToString:@"#"])
        {
            [keys addObject:keys.firstObject];
            [keys removeObjectAtIndex:0];
        }
        
        NSMutableArray *sections = [NSMutableArray array];
        
        [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
            
            ALDialCodeSectionModel *sectionModel = [ALDialCodeSectionModel new];
            sectionModel.key = key;
            sectionModel.dialArray = dict[key];
            
            [sections addObject:sectionModel];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (completcion)
            {
                completcion(sections, keys, modelArray);
            }
        });
    });
}

- (NSString *)al_selectDialCodeWithCountryCode:(NSString *)countryCode {
    NSMutableArray *modelArray = [ALDialCodeModel mj_objectArrayWithKeyValuesArray:[self readLocalFileWithName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"countryCode == %@", countryCode];
    NSArray *filteredArray = [modelArray filteredArrayUsingPredicate:predicate];
    if (filteredArray.count > 0) {
        ALDialCodeModel *model = filteredArray[0];
        return model.dialCode;
    }
    
    return nil;
}

@end
