//
//  KivaLoanTableViewController.swift
//  KivaLoan
//
//  Created by Simon Ng on 20/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

import UIKit

class KivaLoanTableViewController: UITableViewController {
    
    //Fetching Loans wiht the Kiva API
    
    // define the URL of the Kiva API
    let kivaLoadURL = "https://api.kivaws.org/v1/loans/newest.json"
    // declare the loan variable for storing an array of Loan objects
    var loans = [Loan]()
    
    // These two methods form the core part of the app. Both methods work collaboratively to call the Kiva API, retrieve the latest loans in JSON format and translate the JSON-formatted data into an array of Loan objects.
    
    func getLatestLoans() {
        
        let request = NSURLRequest(URL: NSURL(string: kivaLoadURL)!)
        //create an instance of NSURLSession with the Kiva API
        let urlSession = NSURLSession.sharedSession()
        
        //to add a data task to the session, call the dataTaskWithRequest method. Like most networking APIs, the NSURLSession API is asynchronous. Once the request completes, it returns the data by calling completionhandler closure.
        let task = urlSession.dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            //In the completion handler, immediately after the data is returned, we check for an error and invoke the parseJsonData method. The data returned is in JSON format.
            if let error = error {
                print(error)
                return
            }
            
            //Parse JSON data
            if let data = data {
                self.loans = self.parseJsonData(data)
                
                //Reload table view
                
                //Why we need to call NSOperationQueue.mainQueue().addOperationWithBlock and execute the data reload in the main thread? The block of code in the completion handler of the data task is executed in the background thread. If you just call the reloadData method in a background thread, the data reload will not happen immediately. To ensure a responsive GUI update, this operation should be performed in the main thread.
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.tableView.reloadData()
            })
                
            }
        
        })
        //to initiate the data task, call the resume method
        task.resume()
    }
    
    //Convert the given JSON-formatted data into an array of Loan objects.
    func parseJsonData(data: NSData) -> [Loan] {
        
        var loans = [Loan]()
        
        //The foundation framework provides the NSJSONSerialization class, whihc is capable of converting JSON to Foundation objects and converting Foundation objects to JSON. we call JSONObjectWithData method with the given JSON data to perfom the conversation.
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            
            // Parse JSON data
            // // access the array of loans using the key loans.
            let jsonLoans = jsonResult?["loans"] as! [AnyObject]
            
            //loop through the array, each of the array items is converted into a dictionary.
            for jsonLoan in jsonLoans {
                
               // in the loop, we extract the loan data from each o fthe dictionaries and save them in a loan object.
                let loan = Loan()
                loan.name = jsonLoan["name"] as! String
                loan.amount = jsonLoan["loan_amount"] as! Int
                loan.use = jsonLoan["use"] as! String
                let location = jsonLoan["location"] as! [String: AnyObject] //AnyObject is used because a JSON value could be a String, Double, Boolean, Array, Dictionary or null. This is why we have to downcast the value to a specific type such as String and Int.
                loan.country = location["country"] as! String
                // put the loan object into the loans array, which is the return value of the method
                loans.append(loan)
            }
        } catch {
            print(error)
        }
        
        return loans
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to start fetching the loan data
        getLatestLoans()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Displaying Loans in a Table View
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return loans.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! KivaLoanTableViewCell

        // Configure the cell...
        
        cell.nameLabel.text = loans[indexPath.row].name
        cell.countryLabel.text = loans[indexPath.row].country
        cell.useLabel.text = loans[indexPath.row].use
        cell.amountLabel.text = "$\(loans[indexPath.row].amount)"

        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
