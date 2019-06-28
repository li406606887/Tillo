//
//  ALSysPerson.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/9.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "ALSysPerson.h"

@implementation ALSysPerson

- (instancetype)initWithCNContact:(CNContact *)contact {
    if (self = [super init]) {
        self.contactType = contact.contactType == CNContactTypePerson ? ALContactTypePerson : ALContactTypeOrigination;
        
        self.fullName = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
        self.familyName = contact.familyName;
        self.givenName = contact.givenName;
        self.nameSuffix = contact.nameSuffix;
        self.namePrefix = contact.namePrefix;
        self.nickname = contact.nickname;
        self.middleName = contact.middleName;
        
        if ([contact isKeyAvailable:CNContactOrganizationNameKey])
        {
            self.organizationName = contact.organizationName;
        }
        
        if ([contact isKeyAvailable:CNContactDepartmentNameKey])
        {
            self.departmentName = contact.departmentName;
        }
        
        if ([contact isKeyAvailable:CNContactJobTitleKey])
        {
            self.jobTitle = contact.jobTitle;
        }
        
        if ([contact isKeyAvailable:CNContactNoteKey])
        {
            self.note = contact.note;
        }
        
        if ([contact isKeyAvailable:CNContactPhoneticFamilyNameKey])
        {
            self.phoneticFamilyName = contact.phoneticFamilyName;
        }
        if ([contact isKeyAvailable:CNContactPhoneticGivenNameKey])
        {
            self.phoneticGivenName = contact.phoneticGivenName;
        }
        
        if ([contact isKeyAvailable:CNContactPhoneticMiddleNameKey])
        {
            self.phoneticMiddleName = contact.phoneticMiddleName;
        }
        
        if ([contact isKeyAvailable:CNContactImageDataKey])
        {
            self.imageData = contact.imageData;
            self.image = [UIImage imageWithData:contact.imageData];
        }
        
        if ([contact isKeyAvailable:CNContactThumbnailImageDataKey])
        {
            self.thumbnailImageData = contact.thumbnailImageData;
            self.thumbnailImage = [UIImage imageWithData:contact.thumbnailImageData];
        }
        
        if ([contact isKeyAvailable:CNContactPhoneNumbersKey])
        {
            // 号码
            NSMutableArray *phones = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.phoneNumbers)
            {
                ALSysPhone *phoneModel = [[ALSysPhone alloc] initWithLabeledValue:labeledValue];
                [phones addObject:phoneModel];
            }
            self.phones = phones;
        }
        
        if ([contact isKeyAvailable:CNContactEmailAddressesKey])
        {
            // 电子邮件
            NSMutableArray *emails = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.emailAddresses)
            {
                ALSysEmail *emailModel = [[ALSysEmail alloc] initWithLabeledValue:labeledValue];
                [emails addObject:emailModel];
            }
            self.emails = emails;
        }
        
        if ([contact isKeyAvailable:CNContactPostalAddressesKey])
        {
            // 地址
            NSMutableArray *addresses = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.postalAddresses)
            {
                ALSysAddress *addressModel = [[ALSysAddress alloc] initWithLabeledValue:labeledValue];
                [addresses addObject:addressModel];
            }
            self.addresses = addresses;
        }
        
        // 生日
        ALSysBirthday *birthday = [[ALSysBirthday alloc] initWithCNContact:contact];
        self.birthday = birthday;
        
        if ([contact isKeyAvailable:CNContactInstantMessageAddressesKey])
        {
            // 即时通讯
            NSMutableArray *messages = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.instantMessageAddresses)
            {
                ALSysMessage *messageModel = [[ALSysMessage alloc] initWithLabeledValue:labeledValue];
                [messages addObject:messageModel];
            }
            self.messages = messages;
        }
        
        if ([contact isKeyAvailable:CNContactSocialProfilesKey])
        {
            // 社交
            NSMutableArray *socials = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.socialProfiles)
            {
                ALSysSocialProfile *socialModel = [[ALSysSocialProfile alloc] initWithLabeledValue:labeledValue];
                [socials addObject:socialModel];
            }
            self.socials = socials;
        }
        
        if ([contact isKeyAvailable:CNContactRelationsKey])
        {
            // 关联人
            NSMutableArray *relations = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.contactRelations)
            {
                ALSysContactRelation *relationModel = [[ALSysContactRelation alloc] initWithLabeledValue:labeledValue];
                [relations addObject:relationModel];
            }
            self.relations = relations;
        }
        
        if ([contact isKeyAvailable:CNContactUrlAddressesKey])
        {
            // URL
            NSMutableArray *urlAddresses = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.urlAddresses)
            {
                ALSysUrlAddress *urlModel = [[ALSysUrlAddress alloc] initWithLabeledValue:labeledValue];
                [urlAddresses addObject:urlModel];
            }
            self.urls = urlAddresses;
        }

    }
    return self;
}

@end

#pragma mark - 电话
@implementation ALSysPhone

- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue {
    if (self = [super init]) {
        CNPhoneNumber *phoneValue = labeledValue.value;
        NSString *phoneNumber = phoneValue.stringValue;
        self.phone = [self _filterSpecialString:phoneNumber];
        self.label = [CNLabeledValue localizedStringForLabel:labeledValue.label];
    }
    return self;
}

- (NSString *)_filterSpecialString:(NSString *)string
{
    if (string == nil)
    {
        return @"";
    }
    
    string = [string stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

@end


#pragma mark - 电子邮件
@implementation ALSysEmail

- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue {
    self = [super init];
    if (self) {
        self.label = [CNLabeledValue localizedStringForLabel:labeledValue.label];
        self.email = labeledValue.value;
    }
    return self;
}

@end


#pragma mark - 地址
@implementation ALSysAddress
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue {
    if (self = [super init]) {
        CNPostalAddress *addressValue = labeledValue.value;
        self.label = [CNLabeledValue localizedStringForLabel:labeledValue.label];
        self.street = addressValue.street;
        self.state = addressValue.state;
        self.city = addressValue.city;
        self.postalCode = addressValue.postalCode;
        self.country = addressValue.country;
        self.ISOCountryCode = addressValue.ISOCountryCode;
        
        self.formatterAddress = [CNPostalAddressFormatter stringFromPostalAddress:addressValue style:CNPostalAddressFormatterStyleMailingAddress];
    }
    return self;
}


@end

#pragma mark - 生日
@implementation ALSysBirthday

- (instancetype)initWithCNContact:(CNContact *)contact {
    if (self = [super init]) {
        if ([contact isKeyAvailable:CNContactBirthdayKey])
        {
            self.brithdayDate = contact.birthday.date;
        }
        
        if ([contact isKeyAvailable:CNContactNonGregorianBirthdayKey])
        {
            self.calendarIdentifier = contact.nonGregorianBirthday.calendar.calendarIdentifier;
            self.era = contact.nonGregorianBirthday.era;
            self.day = contact.nonGregorianBirthday.day;
            self.month = contact.nonGregorianBirthday.month;
            self.year = contact.nonGregorianBirthday.year;
        }
    }
    return self;
}

@end


#pragma mark - 即时通讯
@implementation ALSysMessage

- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue {
    if (self = [super init]) {
        CNInstantMessageAddress *messageValue = labeledValue.value;
        self.service = messageValue.service;
        self.userName = messageValue.username;
    }
    return self;
}

@end


#pragma mark - 社交
@implementation ALSysSocialProfile

- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue {
    if (self = [super init]) {
        CNSocialProfile *socialValue = labeledValue.value;
        self.service = socialValue.service;
        self.username = socialValue.username;
        self.urlString = socialValue.urlString;
    }
    return self;
}

@end


#pragma mark - URL
@implementation ALSysUrlAddress
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue {
    if (self = [super init]) {
        self.label = [CNLabeledValue localizedStringForLabel:labeledValue.label];
        self.urlString = labeledValue.value;
    }
    return self;
}

@end


#pragma mark - 关联人
@implementation ALSysContactRelation
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue {
    if (self = [super init]) {
        CNContactRelation *relationValue = labeledValue.value;
        self.label = [CNLabeledValue localizedStringForLabel:labeledValue.label];;
        self.name = relationValue.name;
    }
    return self;
}

@end


#pragma mark - 排序分组模型
@implementation ALSectionPerson


@end

