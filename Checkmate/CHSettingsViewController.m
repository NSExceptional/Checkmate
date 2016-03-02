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


@interface CHSettingsViewController ()
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
    
    // Reuse identifiers per cell, accessed by [section][row]
    _reuseIdentifiers = @[@[kTimeLimitReuse], @[kCheckboxReuse, kCheckboxReuse], @[kIncrementReuse]];
    [self.tableView registerClass:[CHPickerCell class] forCellReuseIdentifier:kTimeLimitReuse];
    [self.tableView registerClass:[CHPickerCell class] forCellReuseIdentifier:kIncrementReuse];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCheckboxReuse];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath.section == 1);
    
    // The only selectable rows are in the second section
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType    = UITableViewCellAccessoryCheckmark;
    self.timerType        = indexPath.row;
    [tableView reloadSection:1];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1 ? 44 : 120;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1) {
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
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return @"Fischer: players recieve the full increment.\nBronstein: players recieve the used portion of the increment.";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 1 ? 2 : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
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
