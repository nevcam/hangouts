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

@end

@implementation DateTableViewController {
    BOOL _startDateVisible;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _startDateVisible = NO;
    if(_date) {
        _startDatePicker.date = _date;
        _startDateLabel.text = [NSDateFormatter localizedStringFromDate:_startDatePicker.date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
    }
}

- (IBAction)showStartDate:(id)sender {
    [self startDateChanged];
}

- (void)startDateChanged {
    _startDateLabel.text = [NSDateFormatter localizedStringFromDate:_startDatePicker.date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
    [_delegate changedStartDateTo:_startDatePicker.date];
}

- (void)toggleStartDateDatepicker {
    _startDateVisible = !_startDateVisible;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        [self toggleStartDateDatepicker];
        [self startDateChanged];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_startDateVisible && indexPath.row == 1) {
        return 0;
    } else {
        return [super tableView:self.tableView heightForRowAtIndexPath:indexPath];
    }
}

@end
