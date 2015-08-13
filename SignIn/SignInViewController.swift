//
//  SignInViewController.swift
//  SignIn
//
//  Created by Momoko Saunders on 7/1/15.
//  Copyright (c) 2015 Momoko Saunders. All rights reserved.
//

import Foundation

class SignInViewController: UIViewController, UITableViewDataSource {

    let contactLog = ContactLog()
    let shopUseLog = ShopUseLog()
    var currentContact : Contact!
    var filteredLog: [Contact]
    
    @IBOutlet weak var uniqueIdentifier: UITextField!
    
    @IBOutlet weak var mostRecentSignIns: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        filteredLog = contactLog.recentContactsWhoAreNotLoggedIn()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        mostRecentSignIns.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
    }
    
    override func viewDidAppear(animated: Bool) {
        filteredLog = ContactLog().recentContactsWhoAreNotLoggedIn()
        mostRecentSignIns.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "New User Segue" {
            let vc = segue.destinationViewController as! NewUserViewController
            let loggedInUser = contactLog.createUserWithIdentity(uniqueIdentifier.text)
                vc.contact = loggedInUser
            currentContact = loggedInUser

        }
        if segue.identifier == "Thank You" {
            let vc = segue.destinationViewController as! BFFThankYouForSigningIn
            vc.contact = currentContact
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLog.count + 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        cell = UITableViewCell(style: .Value1, reuseIdentifier: "Cell")
        
        if indexPath.row == 0 {
            cell.textLabel!.text = "I'm New, I don't have a login"
            cell.textLabel!.textAlignment = .Center
            // I'd like to formate this cell to look more like a button, or maybe I should put a button in it?
        } else {
            let contact = filteredLog[indexPath.row - 1]
            cell.textLabel!.text = contact.valueForKey("firstName") as? String
            let membership = contact.valueForKey("membership") as? Membership
            let membershipType = membership?.membershipType
            cell.detailTextLabel!.text = membershipType
            cell.backgroundColor = contactLog.colourOfContact(contact)
        }
        return cell
    }
    
    func tableView( tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            performSegueWithIdentifier("New User Segue", sender: self)
        } else {
            currentContact = filteredLog[indexPath.row - 1]
            performSegueWithIdentifier("Thank You", sender: self)
        }
        showAlertForCompleteForm()
    }
    
    func textField( textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
//        if count(uniqueIdentifier.text) == 1 && string == "" {
//            filteredLog = contactLog.recentUsersWhoAreNotLoggedIn
//        } else {
            _searchContactsWithSubstring(string)
 //       }
        return true
    }
    
    func showAlertForCompleteForm () {
        let alert = UIAlertController(title: "Are you here to work on your bike or volunteer", message: nil, preferredStyle: .Alert)
        let shopUse = UIAlertAction(title: "Use the Shop", style: .Default, handler: { alert in self.shopUseLog.createShopUseWithContact(self.currentContact)
        })
        alert.addAction(shopUse)
        let volunteer = UIAlertAction(title: "Volunteer", style: .Default, handler: { alert in self.shopUseLog.createVolunteerUseWithContact(self.currentContact)
        })
        alert.addAction(volunteer)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func _searchContactsWithSubstring(substring: String) {
        let prefix = uniqueIdentifier.text.lowercaseString
        var fullContactList = contactLog.allContacts
        let predicate = NSPredicate(format: "firstName BEGINSWITH %@ OR lastName BEGINSWITH %@ OR pin BEGINSWITH %@ OR emailAddress BEGINSWITH %@", prefix, prefix, prefix, prefix)
//        let predicate = NSPredicate(format:"firstName BEGINSWITH %@", prefix)
        
        filteredLog = (fullContactList as NSArray).filteredArrayUsingPredicate(predicate) as! [Contact]
        if filteredLog == [] {filteredLog = fullContactList}
        mostRecentSignIns.reloadData()
    }
}
