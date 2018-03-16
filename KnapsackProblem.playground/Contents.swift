//: Playground - noun: a place where people can play

import Foundation

//Given a knapsack that can hold W weight and a collection of Items that have a value and a weight, choose the subset of Items which maximize value while having lest cumulative weight than that which the knapsack can hold.
typealias Item = (value: Int, weight: Int)
func knapsack(W: Int, items: [Item]) -> [Item] {
    
    //bottom up dp array holding both a totalValue and the list of items to be returned later
    var dpArr: [[(totalValue: Int, items: [Item])]] = Array(repeating: Array(repeating: (0, []), count: W + 1), count: items.count)
    
    for itemIndex in 0..<items.count {
        for weight in 1...W { // start at 1 since no item with weight can be less than one

            if itemIndex == 0 { //first item, if fits than mark in dp array
                if items[itemIndex].weight <= weight {
                    dpArr[itemIndex][weight] = (items[itemIndex].value, [items[itemIndex]])
                } else {
                    //do nothing
                }
            } else if items[itemIndex].weight > weight { //can't fit this item in knapsack
                dpArr[itemIndex][weight] = dpArr[itemIndex - 1][weight] //take maximum when excluding this item
            } else { //item can fit
                let currentItemValue = items[itemIndex].value
                let maxValueOfRemainingItemsWithoutCurrentWeight = dpArr[itemIndex - 1][weight - items[itemIndex].weight].totalValue
                let maxValueOfRemainingItemsWithCurrentWeight = dpArr[itemIndex - 1][weight].totalValue
                if currentItemValue + maxValueOfRemainingItemsWithoutCurrentWeight > maxValueOfRemainingItemsWithCurrentWeight { //if picking this item is better
                    dpArr[itemIndex][weight] = (totalValue: currentItemValue + maxValueOfRemainingItemsWithoutCurrentWeight, items: dpArr[itemIndex - 1][weight - items[itemIndex].weight].items + [items[itemIndex]])
                } else { //if not picking is better
                    dpArr[itemIndex][weight] = dpArr[itemIndex - 1][weight]
                }
            }
        }
    }
    
    return dpArr[items.count - 1][W].items
}

knapsack(W: 10, items: [(value: 9, weight: 9), (value: 5, weight: 5), (value: 5, weight: 5), (value: 9, weight: 9)])
