//
//  DateTableViewController.m
//  hangouts
//
//  Created by sroman98 on 8/8/19.
//  Copyright © 2019 nev. All rights reserved.
//

#import "DateTableViewController.h"

@interface DateTableViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;

@end

@implementation DateTableViewController {
    BOOL _startDateVisible;
    BOOL _endDateVisible;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _startDateVisible = NO;
    _endDateVisible = NO;
    if(_date) {
        _startDatePicker.date = _date;
        _startDateLabel.text = [NSDateFormatter localizedStringFromDate:_startDatePicker.date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
        
        /*_endDatePicker.date = _endDate;
        _endDateLabel.text = [NSDateFormatter localizedStringFromDate:_endDatePicker.date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];*/
    }
}

- (IBAction)showStartDate:(id)sender {
    [self startDateChanged];
}

- (IBAction)showEndDate:(id)sender {
    [self endDateChanged];
}

- (void)startDateChanged {
    _startDateLabel.text = [NSDateFormatter localizedStringFromDate:_startDatePicker.date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
    [_delegate changedStartDateTo:_startDatePicker.date];
}

- (void)endDateChanged {
    _endDateLabel.text = [NSDateFormatter localizedStringFromDate:_endDatePicker.date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
    //[_delegate changedEndDateTo:_endDatePicker.date];
}

- (void)toggleStartDateDatepicker {
    _startDateVisible = !_startDateVisible;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)toggleEndDateDatepicker {
    _endDateVisible = !_endDateVisible;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 1) {
        [self toggleStartDateDatepicker];
        [self startDateChanged];
    } else if (indexPath.row == 3) {
        [self toggleEndDateDatepicker];
        [self endDateChanged];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((_startDateVisible || _endDateVisible) && indexPath.row == 0) {
        return 0;
    } else if (!_startDateVisible && indexPath.row == 2) {
        return 0;
    } else if (!_endDateVisible && indexPath.row == 4) {
        return 0;
    } else {
        return [super tableView:self.tableView heightForRowAtIndexPath:indexPath];
    }
}

@end
