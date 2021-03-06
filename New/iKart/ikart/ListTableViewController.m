//
//  ListTableViewController.m
//  indoor map
//
//  Created by SANJIT SHAW on 08/04/15.
//  Copyright (c) 2015 SANJIT SHAW. All rights reserved.
//

#import "ListTableViewController.h"

@interface ListTableViewController ()

@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [_dataSourceArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSInteger rowCount = 0;
    
    rowCount = [[_dataSourceArray objectAtIndex:section] count];
    
    return rowCount;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *rowDataSource = [_dataSourceArray objectAtIndex:indexPath.section];
    NSDictionary *productInfo = [rowDataSource objectAtIndex:indexPath.row];
    NSString *textToDisplay = [productInfo objectForKey:@"Name"];
    CGFloat cellHeight = 0;
    
    CGSize textSize = { tableView.frame.size.width, CGFLOAT_MAX };
    CGRect cellframe = [textToDisplay boundingRectWithSize:textSize
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:14.0] }
                                    context:nil];
    cellHeight = cellframe.size.height;
    
    UIImage *image = [UIImage imageNamed:[productInfo valueForKey:@"Icon"]];
    CGFloat imageheight = [image size].height;
    
    return 60;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"ReuseIdentifier";
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSArray *rowDataSource = [_dataSourceArray objectAtIndex:indexPath.section];
    NSDictionary *productInfo = [rowDataSource objectAtIndex:indexPath.row];
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = [productInfo valueForKey:@"Name"];
    cell.imageView.image = [UIImage imageNamed:[productInfo valueForKey:@"Icon"]];
    
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
