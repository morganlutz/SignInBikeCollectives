//
//  Copyright (c) 2015 Momoko Saunders. All rights reserved.
//

import Foundation

class ShopUseLog: NSObject {

    var shopUseLog : [ShopUse]
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    override init(){
        shopUseLog = []
        let fetchRequest = NSFetchRequest(entityName: "ShopUse")
        
        do { if let fetchedResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [ShopUse] {
                shopUseLog = fetchedResults}
            else {
              assertionFailure("Could not executeFetchRequest")
            }
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        super.init()
    }
    
    func deleteShopUsesForContact(contact: Contact) {
        for shopUse in contact.shopUse! {
            managedObjectContext.deleteObject(shopUse as! NSManagedObject)
        }
    }
    
    func deleteSignalShopUse(shopUse: ShopUse) {
        managedObjectContext.deleteObject(shopUse as NSManagedObject)
    }
    
    func createShopUseWithContact(contact: Contact, id: Int) {
        let entity = NSEntityDescription.entityForName("ShopUse", inManagedObjectContext: managedObjectContext)
        
        let shopUse = ShopUse(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)

        shopUse.signIn = NSDate()
        let org = OrganizationLog().organizationLog.first
        let autoLogOut = NSTimeInterval((org!.defaultSignOutTime)!)
        shopUse.signOut = NSDate().dateByAddingTimeInterval(60*60*autoLogOut)
        shopUse.type = TypeLog().getType(id)

        shopUse.contact = contact
        shopUse.contact!.recentUse = shopUse.signOut
        ContactLog().saveContact(contact)

        var error: NSError?
        do {
            try managedObjectContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    func getShopUseLog() -> [ShopUse] {
        shopUseLog = []
        let fetchRequest = NSFetchRequest(entityName: "ShopUse")
        
        do { if let fetchedResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [ShopUse] {
            shopUseLog = fetchedResults}
        else {
            assertionFailure("Could not executeFetchRequest")
            }
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        return shopUseLog
    }
    
    func signOutContact(contact: Contact) {
        // Get the most recent shopUse if there is one
        if let use = ShopUseLog().getMostRecentShopUseForContact(contact) {
            // Set the signOut to now
            use.signOut = NSDate()
            // reset the recentUse time
            contact.recentUse = use.signOut
        }
    }

    func getShopUsesForContact(contact: Contact) -> [ShopUse] {
        var log = [ShopUse]()
        let FetchRequest = NSFetchRequest(entityName: "ShopUse")
        let predicate = NSPredicate(format: "contact == %@", contact)
        FetchRequest.predicate = predicate
        do { if let FetchedResults = try managedObjectContext.executeFetchRequest(FetchRequest) as? [ShopUse] {
            log = FetchedResults }
        else {
            assertionFailure("Could not executeFetchRequest")
            }
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        return log
    }
    
    func getMostRecentShopUseForContact(contact: Contact) -> ShopUse? {
        var log = getShopUsesForContact(contact)
        if log.count < 1 {
            // if somehow, there are no shopUses for the contact, 
            // then create one, and make note of this!
            createShopUseWithContact(contact, id: 1)
        }
        log.sortInPlace({ $0.signIn!.timeIntervalSinceNow > $1.signIn!.timeIntervalSinceNow})
        return log[0]
            
    }
    
    func loggedInContacts() -> [Contact] {
        let loggedInContacts = ContactLog().allContacts
        var newContacts = [Contact]()
        for user in loggedInContacts {
            if user.recentUse!.timeIntervalSinceNow > 0 {
                newContacts.append(user)
            }
        }
        return newContacts
    }
    
    func timeOfCurrentShopUseForContact(contact: Contact) -> String {
        let recentUse = getMostRecentShopUseForContact(contact)
        let signIn = -1 * recentUse!.signIn!.timeIntervalSinceNow/(60*60)
        var mySubString = ""
        if recentUse?.signOut!.timeIntervalSinceNow > 0 {
            mySubString = String(format: "%.1f", signIn)
        }
        return mySubString
    }
    
    func numberOfHoursLoggedByContact(contact: Contact, typeTitle: String) -> String {
        var totalHoursOfShopUse = 0.0
        
        //get all the shopUses of a certian type
        // the sign in will be a large negative number
        // the signout will be a slightly smaller negative number, unless the user is not logged out, then it will be a positive number
        //subtract the signIn from the sign in
        
        // maybe i should first determin if they are logged in or out?
        // if out, then it's simple. 
        // if in, we have to remove the most recent shop use from the equation, 
        // in the past, i subtracted the total, then added back the current time,
        
        // but what happens when you're logged in, and you log out, and then you log back in as a different type, it shows up negative.
        
        // how can I know the request is for the hourly time is for the type that the user is logged in for?
        for shopUseHour in contact.shopUse! {
            if shopUseHour.type!!.title! == typeTitle {
                let shopUseInstance = timeIntervalBetweenTwoDates(shopUseHour.signIn!!,date2:  shopUseHour.signOut!!)
                totalHoursOfShopUse = totalHoursOfShopUse + shopUseInstance
            }
        }
        
        totalHoursOfShopUse = totalHoursOfShopUse/(60*60)

        // if user is logged in
        if contact.recentUse?.timeIntervalSinceNow > 0 {
            let lastShopUse = getMostRecentShopUseForContact(contact)
            if typeTitle == lastShopUse?.type?.title {
            let totalTimeOfLastShopUse = timeIntervalBetweenTwoDates((lastShopUse?.signIn)!, date2: (lastShopUse?.signOut)!)/(60*60)
            totalHoursOfShopUse = totalHoursOfShopUse - totalTimeOfLastShopUse + Double(timeOfCurrentShopUseForContact(contact))!
            }
        }
        return String(format: "%.1f", totalHoursOfShopUse)
   }

    func timeIntervalBetweenTwoDates(date1: NSDate, date2: NSDate) -> Double {
        return Double(-1 * date1.timeIntervalSinceNow + date2.timeIntervalSinceNow)
    }

    func hourlyTotalForThisMonth(contact: Contact, typeTitle: String) -> String {
        var totalHoursOfShopUse = 0.0
        for shopUseHour in contact.shopUse! {
            if isDateInThisMonth(shopUseHour.signIn!!) && shopUseHour.type!!.title == typeTitle {
                let shopUseInstance = timeIntervalBetweenTwoDates(shopUseHour.signIn!!,date2:  shopUseHour.signOut!!)
                totalHoursOfShopUse = totalHoursOfShopUse + shopUseInstance
            }
        }
        
        totalHoursOfShopUse = totalHoursOfShopUse/(60*60)
        
        // if user is logged in
        if contact.recentUse?.timeIntervalSinceNow > 0 {
            let lastShopUse = getMostRecentShopUseForContact(contact)
            if typeTitle == lastShopUse?.type?.title {
            let totalTimeOfLastShopUse = timeIntervalBetweenTwoDates((lastShopUse?.signIn)!, date2: (lastShopUse?.signOut)!)/(60*60)
            let time = Double(timeOfCurrentShopUseForContact(contact))!
            totalHoursOfShopUse = totalHoursOfShopUse - totalTimeOfLastShopUse + time
            }
        }
        return String(format: "%.1f", totalHoursOfShopUse)
    }
    
    func hourlyTotalForLastMonth(contact: Contact, typeTitle: String) -> String {
        var hourlyTotalForThisMonth = 0.0
        for shopUseHour in contact.shopUse! {
            if isDateInLastMonth(shopUseHour.signIn!!) && shopUseHour.type!!.title == typeTitle {
                var shopUseInstance = Double(shopUseHour.signIn!!.timeIntervalSinceNow - shopUseHour.signOut!!.timeIntervalSinceNow)
                shopUseInstance = shopUseInstance/(60 * 60) * -1
                hourlyTotalForThisMonth = hourlyTotalForThisMonth + shopUseInstance
            }
        }
        return String(format: "%.1f", hourlyTotalForThisMonth)
    }

//    func formateNumberTo3Characters(number: Double) -> String {
//        let array = [Character](string.characters)
//        let mySubString = String("\(array[0])\(array[1])\(array[2])")
//        return mySubString
//    }
    
    func isDateInThisMonth(date: NSDate) -> Bool {
        var bool = true
        let calendar = NSCalendar.currentCalendar()
        let thisMonth = calendar.component(.Month, fromDate: NSDate())
        let dateComponets = calendar.component(.Month, fromDate: date)
        if thisMonth == dateComponets {
            bool = true
        } else {
            bool = false
        }
        return bool
    }
    
    func isDateInLastMonth(date: NSDate) -> Bool {
        var bool = true
        let calendar = NSCalendar.currentCalendar()
        let thisMonth = calendar.component(.Month, fromDate: NSDate()) - 1
        let dateComponets = calendar.component(.Month, fromDate: date)
        if thisMonth == dateComponets {
            bool = true
        } else {
            bool = false
        }
        return bool
    }
    
//    func contactsOfVolunteers() -> [Contact] {
//        var contacts = [Contact]()
//        // this is ugly, can i make it better?
//        // fetchrequest! nope, that's worse
//        let allContacts = ContactLog().allContacts
//        // creates duplicates...
//        for contact in allContacts {
//            if contact.shopUse!.count > 0 {
//                for use in contact.shopUse! {
//                    if use.type!!.title! == "Volunteer" {
//                        contacts.append(contact)
//                    }
//                }
//            }
//        }
//        return contacts
//    }
    
    func contactsOfVolunteer() -> [Contact] {
        var contacts = [Contact]()
        var shopUseArray = [ShopUse]()
        let fetchRequest = NSFetchRequest(entityName: "ShopUse")
        let predicateVolunteerType = NSPredicate(format: "type == %@", TypeLog().getType(1))
        fetchRequest.predicate = predicateVolunteerType
        
        do { if let fetchedResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [ShopUse] {
            shopUseArray = fetchedResults}
        else {
            assertionFailure("Could not executeFetchRequest")
            }
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        
        for use in shopUseArray {
            contacts.append(use.contact!)
        }
        let unique = Array(Set(contacts))
        
         return unique
    }
    
    func shopUseLogAsCommaSeporatedString() -> String {
        var stringData = "SignIn,, SignOut,, Contact First Name, Last Name, Type"  + "\r\n"
        let dateFormator = NSDateFormatter()
        dateFormator.dateStyle = .ShortStyle
        dateFormator.timeStyle = .ShortStyle
        for use in getShopUseLog() {
            if let firstName = use.contact?.firstName!, let lastName = use.contact?.lastName!, let type = use.type?.title! {
            stringData += String("\(dateFormator.stringFromDate(use.signIn!)), \(dateFormator.stringFromDate(use.signOut!)), \(firstName), \(lastName), \((type))" + "\r\n")
            }
        }
        let fileName = getDocumentsDirectory().stringByAppendingPathComponent("data.csv")
        do { try stringData.writeToFile(fileName, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print("Could not create file \(error)")
        }
        return stringData
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
