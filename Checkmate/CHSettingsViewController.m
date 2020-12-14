//
//  CHSettingsViewController.m
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHSettingsViewController.h"
#import "CHPickerCell.h"
#import "UIPickerView+SeparatorLines.h"
#import "TBAlertController.h"
#import <MessageUI/MessageUI.h>


@interface CHSettingsViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic, readonly) NSArray *reuseIdentifiers;

@property (nonatomic, readonly) NSTimeInterval timeLimit;
@property (nonatomic, readonly) NSTimeInterval delayAmount;
@property (nonatomic, readonly) CHTimerType delayType;
@end

@implementation CHSettingsViewController

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    
    // Load mutable value from preferences
    self.timerType = self.delayType;
    
    // Reuse identifiers per cell, accessed by [section][row]
    _reuseIdentifiers = @[@[kTimeLimitReuse], @[kCheckboxReuse, kCheckboxReuse], @[kIncrementReuse], @[kCheckboxReuse]];
    [self.tableView registerClass:[CHPickerCell class] forCellReuseIdentifier:kTimeLimitReuse];
    [self.tableView registerClass:[CHPickerCell class] forCellReuseIdentifier:kIncrementReuse];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCheckboxReuse];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath.section == 1 || indexPath.section == 3);
    
    // The only selectable rows are in the second and fourth sections
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType    = UITableViewCellAccessoryCheckmark;
        self.timerType        = indexPath.row;
        [tableView reloadSection:1];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self composeEmail];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1 || indexPath.section == 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        case 2:
            return 120;
        default:
            return 44;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 2) {
        // Dispatched because the picker views did not have their
        // separator lines created at this point.
        dispatch_async(dispatch_get_main_queue(), ^{
            CHPickerCell *celll = (id)cell;
            celll.picker.pickerView.bottomLineView_.backgroundColor = [UITableView appearance].separatorColor;
            celll.picker.pickerView.topLineView_.backgroundColor    = [UITableView appearance].separatorColor;
        });
    }
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.reuseIdentifiers[indexPath.section][indexPath.row]];
    CHPickerCell *pickerCell = (id)cell;
    
    switch (indexPath.section) {
        case 0: {
            // Obtain a reference to the time interval picker
            _timerPicker = pickerCell.picker;
            _timerPicker.timeInterval = self.timeLimit;
            break;
        }
        case 1: {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font      = [cell.textLabel.font fontWithSize:17];
            if (indexPath.row == self.timerType) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Fischer";
                    break;
                case 1:
                    cell.textLabel.text = @"Bronstein";
                    break;
            }
            break;
        }
        case 2: {
            // Obtain a reference to the delay picker
            _incrementPicker = pickerCell.picker;
            _incrementPicker.timeInterval = self.delayAmount;
            break;
        }
        case 3: {
            cell.textLabel.text = @"Send feedback";
            cell.textLabel.textColor = [UIColor colorWithRed:0.000 green:0.400 blue:1.000 alpha:1.000];
            cell.textLabel.font      = [cell.textLabel.font fontWithSize:17];
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Player time limit";
        case 1:
            return @"Increment scheme";
        case 2:
            return @"Increment amount";
        case 3:
            return @"Feedback";
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return @"Fischer: players recieve the full increment.\nBronstein: players recieve the used portion of the increment.";
        case 2:
            return @"Made by Tanner Bennett. Find me on Twitter at @NSExceptional. I appreciate your purchase!";
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 1 ? 2 : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

#pragma mark Feedback

- (void)composeEmail {
    NSString *body = [NSString stringWithFormat:@"%@, %@\n\n", [UIDevice currentDevice].model, [UIDevice currentDevice].systemVersion];
    MFMailComposeViewController *mail = [MFMailComposeViewController new];
    if (mail) {
        mail.mailComposeDelegate = self;
        mail.view.tintColor = [UIColor colorWithRed:0.000 green:0.400 blue:1.000 alpha:1.000];
        [mail setSubject:@"Checkmate Feedback"];
        [mail setMessageBody:body isHTML:NO];
        [mail setToRecipients:@[@"tannerbennett@icloud.com"]];
        [self presentViewController:mail animated:YES completion:nil];
    } else {
        TBAlertController *alert = [TBAlertController
            simpleOKAlertWithTitle:@"Cannot send Email"
            message:@"Configure an email account in the Settings app."
        ];
        [alert showFromViewController:self];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Preference accessors

- (NSTimeInterval)timeLimit {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kPref_TimerTime];
}

- (NSTimeInterval)delayAmount {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kPref_TimerIncrement];
}

- (CHTimerType)delayType {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kPref_TimerStyle];
}

@end
