// Playground - noun: a place where people can play

import Cocoa
import Foundation


var str = "Hello, playground"
//var array = [1,2,3,4,5,6,7]
//let index = find(array, 5)
//let abc: Array = sorted(array)
//array.sort({ $0 > $1 })
//array
//var cba = sorted(array, {$0 > $1 })
//sort(&array, {$0 < $1})
//array

//abc
//cba




let lastName = "SA"
let firstName = "Momoko"
let char = String(lastName[lastName.startIndex])

var displayName = firstName + " " + char




enum MembershipType: String {
    case oneMonth = "One Month", sixMonth = "Six Month", oneYear = "One Year", lifeTime = "Life Time", noMembership = "No Membership"
}

struct People {
    var name : String
    var lastName = ""
    var pin : Int
    var emailAddress = ""
    var membershipType : MembershipType
    
    func printNameWithFormate(handler: (String, String) -> String)
    {
//        println(handler(name, lastName))
    }
}

var momoko = People(name: "Momoko", lastName: "S", pin: 1234, emailAddress: " ", membershipType: .oneMonth)
let evan = People(name: "Evan", lastName: "DeLaney", pin: 2345, emailAddress: " ", membershipType: .noMembership)
let alan = People(name: "Alan", lastName: " ", pin: 3456, emailAddress: " ", membershipType: .noMembership)

evan.printNameWithFormate { (firstName, lastName) -> String in
    return "\(firstName) \(lastName)"
}

evan.printNameWithFormate {"\($0) \($1)"}

momoko.printNameWithFormate { (firstName, lastName) -> String in
    "\(lastName) \(firstName)"
}

let membershipNumber = alan.membershipType.hashValue
membershipNumber

func evanStinks(s1: String, s2: String) -> Bool {
    return true
}

let log = [momoko, evan, alan]

//let otherSortedLog = sorted(log, { (s1: People, s2: People) -> Bool in
//    return s1.name < s2.name })
//
//let otherSortedLog1 = sorted(log, { (s1, s2) -> Bool in
//    s1.name < s2.name })
//
//let otherSortedLog2 = sorted(log, { $0.name < $1.name })
//
//let sortedLog = sorted(log, {$0.membershipType.rawValue > $1.membershipType.rawValue})
//let aSortedLog = log.sorted({$0.name < $1.name})
//sortedLog
//otherSortedLog
//aSortedLog

momoko.membershipType.rawValue
momoko.membershipType.hashValue

momoko.membershipType.rawValue

let contacts = ["Alec", "Annalee", "Anya", "Arlie", "Blaine", "Burton", "Cecily", "Deana",
    "Deirdre", "Elena", "Elodia", "Francina", "Freeman", "Herbert", "Iona", "Jacqui", "Janna",
    "Jeneva", "Karla", "Katelin", "Kathaleen", "Kesha", "Kum", "Lilliam", "Mardell", "Margarite",
    "Margy", "Marta", "Maryalice", "Mellisa", "Melodee", "Miguel", "Millie", "Myong", "Nakita",
    "Nancy", "Nicolasa", "Noemi", "Roselia", "Sade", "Shalonda", "Shawn", "Siobhan", "Tanna",
    "Thu", "Vanesa", "Vonnie", "Wade", "Winford", "Xiomara"]

let prefix = "ma"

// Case sensitive
contacts.filter({ contact in
    contact.hasPrefix(prefix)
})
// has 0 matches

// Case unsensitive
let lowercasePrefix = prefix.lowercaseString

contacts.filter({ contact in
    contact.lowercaseString.hasPrefix(lowercasePrefix)
})
// has 5 matches -> "Mardell", "Margarite", "Margy", "Marta", "Maryalice"

let arrayWithMultipleThings = [8, "hi", NSDate()]
arrayWithMultipleThings

var alphaSortArray = contacts.sort({ $0 > $1})
alphaSortArray.removeRange(Range(start: 0, end: 7))



let now = NSDate()
var later = now

now == later

let nowTime = now.timeIntervalSinceNow
let laterTime = later.timeIntervalSinceNow

nowTime == laterTime

let difference = now.timeIntervalSinceNow - later.timeIntervalSinceNow






