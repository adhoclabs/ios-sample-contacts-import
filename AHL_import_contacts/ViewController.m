//
//  ViewController.m
//  AHL_import_contacts
//
//  Created by William Carter on 12/1/16.
//  Copyright © 2016 Ad Hoc Labs. All rights reserved.
//

#import "ViewController.h"
#import <Contacts/Contacts.h>

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)add:(id)sender {
    [self contactScan:NO];
}

- (IBAction)remove:(id)sender {
    [self contactScan:YES];
}

- (void)contactScan:(BOOL)delete
{
    if ([CNContactStore class]) {
        //ios9 or later
        CNEntityType entityType = CNEntityTypeContacts;
        if( [CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusNotDetermined)
        {
            CNContactStore * contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if(granted){
                    [self saveContacts:delete];
                }
            }];
        }
        else if( [CNContactStore authorizationStatusForEntityType:entityType]== CNAuthorizationStatusAuthorized)
        {
            [self saveContacts:delete];
        }
    }
}

- (void)saveContacts:(BOOL)delete
{
    if(![CNContactStore class]) {
        return;
    }
    
    NSError* contactError;
    
    CNContactStore *addressBook = [[CNContactStore alloc] init];
    [addressBook containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers: @[addressBook.defaultContainerIdentifier]] error:&contactError];
    
    if (contactError) {
        NSLog(@"Error reading from address book");
        return;
    }
    
    NSString *vFilePath = [[NSBundle mainBundle] pathForResource:@"all" ofType:@"vcf"];
    NSData *myData = [NSData dataWithContentsOfFile:vFilePath];
    
    NSArray *contacts = [CNContactVCardSerialization contactsWithData:myData error:&contactError];
    
    if (contactError) {
        NSLog(@"Error reading from VCard");
        return;
    }
    
    for (CNContact *contact in contacts) {
        
        CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
        
        if (!delete) {
            [saveRequest addContact:[contact mutableCopy] toContainerWithIdentifier:[addressBook defaultContainerIdentifier]];
        } else {
            [saveRequest deleteContact:[contact mutableCopy]];
        }
        
        [addressBook executeSaveRequest:saveRequest error:nil];
    }
    
    NSLog(@"Contacts saved");
}

@end
