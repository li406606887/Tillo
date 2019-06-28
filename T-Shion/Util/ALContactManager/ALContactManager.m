//
//  ALContactManager.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/9.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALContactManager.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>


@interface ALContactManager ()

@property (nonatomic, copy) void (^handler) (NSString *, NSString *);
@property (nonatomic, assign) BOOL isAdd;
@property (nonatomic, copy) NSArray *keys;

@property (nonatomic, strong) CNContactStore *contactStore;
@property (nonatomic) dispatch_queue_t queue;


@end


@implementation ALContactManager

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_queue_create("com.addressBook.queue", DISPATCH_QUEUE_SERIAL);
        _contactStore = [CNContactStore new];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(al_contactStoreDidChange)
                                                     name:CNContactStoreDidChangeNotification
                                                   object:nil];
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
- (void)al_contactStoreDidChange {
    if ([ALContactManager sharedInstance].contactChangeHandler) {
        [ALContactManager sharedInstance].contactChangeHandler();
    }
}

- (void)al_authorizationAddressBook:(void (^) (BOOL succeed))completion {
    [_contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (completion)
        {
            completion(granted);
        }
    }];
}

void al_blockExecute(void (^completion)(BOOL authorizationA), BOOL authorizationB)
{
    if (completion)
    {
        if ([NSThread isMainThread])
        {
            completion(authorizationB);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(authorizationB);
            });
        }
    }
}

- (void)al_asynAccessContactStoreWithSort:(BOOL)isSort completcion:(void (^)(NSArray *, NSArray *))completcion {
    
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        NSMutableArray *datas = [NSMutableArray array];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:self.keys];
        
        [self.contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            
            ALSysPerson *person = [[ALSysPerson alloc] initWithCNContact:contact];
            if (person.phones.count > 0) {
                [datas addObject:person];
            }
        }];
        
        if (!isSort) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (completcion) completcion(datas, nil);
                
            });
            
            return ;
        }
        
        [self al_sortNameWithDatas:datas completcion:^(NSArray *persons, NSArray *keys) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (completcion)
                {
                    completcion(persons, keys);
                }
            });
        }];
        
    });
}

- (void)al_sortNameWithDatas:(NSArray *)datas completcion:(void (^)(NSArray *, NSArray *))completcion {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (ALSysPerson *person in datas) {
        NSString *firstLetter = [self al_firstCharacterWithString:person.fullName];
        
        if (dict[firstLetter]) {
            [dict[firstLetter] addObject:person];
        } else {
            NSMutableArray *arr = [NSMutableArray arrayWithObjects:person, nil];
            [dict setValue:arr forKey:firstLetter];
        }
    }
    
    NSMutableArray *keys = [[[dict allKeys] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    
    if ([keys.firstObject isEqualToString:@"#"])
    {
        [keys addObject:keys.firstObject];
        [keys removeObjectAtIndex:0];
    }
    
    NSMutableArray *persons = [NSMutableArray array];
    
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        
        ALSectionPerson *person = [ALSectionPerson new];
        person.key = key;
        person.persons = dict[key];
        
        [persons addObject:person];
    }];
    
    if (completcion)
    {
        completcion(persons, keys);
    }
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
- (void)requestAddressBookAuthorization:(void (^)(BOOL))completion {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    if (status == CNAuthorizationStatusNotDetermined) {
        [self al_authorizationAddressBook:^(BOOL succeed) {
            al_blockExecute(completion, succeed);
        }];
    } else {
        al_blockExecute(completion, status == CNAuthorizationStatusAuthorized);
    }
}

- (void)al_accessContactsComplection:(void (^)(BOOL, NSArray<ALSysPerson *> *))completcion {
    [self requestAddressBookAuthorization:^(BOOL authorization) {
        
        if (authorization) {
            [self al_asynAccessContactStoreWithSort:NO completcion:^(NSArray *datas, NSArray *keys) {
                if (completcion)
                {
                    completcion(YES, datas);
                }
            }];
            
        } else {
            if (completcion) {
                completcion(NO, nil);
            }
        }
    }];
}

- (void)al_accessSectionContactsComplection:(void (^)(BOOL, NSArray<ALSectionPerson *> *, NSArray<NSString *> *))completcion {
    
    [self requestAddressBookAuthorization:^(BOOL authorization) {
        if (authorization) {
            [self al_asynAccessContactStoreWithSort:YES completcion:^(NSArray *datas, NSArray *keys) {
                if (completcion)
                {
                    completcion(YES, datas, keys);
                }
            }];
            
        } else {
            if (completcion)
            {
                completcion(NO, nil, nil);
            }
        }
    }];
}


#pragma mark - 自己传数据进行塞选
- (void)al_accessSectionContactsWithDataSource:(NSArray *)dataArray Complection:(void (^)(BOOL, NSArray<ALSectionPerson *> *, NSArray<NSString *> *))completcion {
    
    [self al_asynAccessContactStoreWithDataSource:dataArray completcion:^(NSArray *datas, NSArray *keys) {
        if (completcion)
        {
            completcion(YES, datas, keys);
        }
    }];
    
}

- (void)al_asynAccessContactStoreWithDataSource:(NSArray *)dataArray completcion:(void (^)(NSArray *, NSArray *))completcion {
    
    @weakify(self);
    dispatch_async(_queue, ^{
        @strongify(self);
        NSMutableArray *datas = [NSMutableArray arrayWithArray:dataArray];
       
        [self al_sortNameWithDatas:datas completcion:^(NSArray *persons, NSArray *keys) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (completcion)
                {
                    completcion(persons, keys);
                }
            });
        }];
        
    });
    
}



#pragma mark - getter
- (NSArray *)keys {
    if (!_keys) {
        _keys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],
                  CNContactPhoneNumbersKey,
                  CNContactOrganizationNameKey,
                  CNContactDepartmentNameKey,
                  CNContactJobTitleKey,
                  CNContactNoteKey,
                  CNContactPhoneticGivenNameKey,
                  CNContactPhoneticFamilyNameKey,
                  CNContactPhoneticMiddleNameKey,
                  CNContactImageDataKey,
                  CNContactThumbnailImageDataKey,
                  CNContactEmailAddressesKey,
                  CNContactPostalAddressesKey,
                  CNContactBirthdayKey,
                  CNContactNonGregorianBirthdayKey,
                  CNContactInstantMessageAddressesKey,
                  CNContactSocialProfilesKey,
                  CNContactRelationsKey,
                  CNContactUrlAddressesKey];
        
    }
    return _keys;
}

@end
