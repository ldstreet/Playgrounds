//: Playground - noun: a place where people can play
/*
 Given two strings str1 and str2 and below operations that can performed on str1. Find minimum number of edits (operations) required to convert ‘str1’ into ‘str2’.
 
    Insert
    Remove
    Replace
 All of the above operations are of equal cost.
 https://www.geeksforgeeks.org/dynamic-programming-set-5-edit-distance/
 */

//bottom up dynamic programming solution
func minEditDistance(from str1: String, to str2: String) -> Int {
    
    // slight optimization, no need to go further if one string is empty
    if str1.isEmpty { return str2.count }
    if str2.isEmpty { return str1.count }
    
    //Dynamic programming array
    var dpArr: [[Int]] = Array(repeating: Array(repeating: 0,
                                                count: str2.count + 1),
                               count: str1.count + 1)
    
    for i in 0...str1.count {
        for j in 0...str2.count {
            
            //When i or j is zero, that string is empty, meaning it takes the length of the other string
            //(using all inserts) to edit str1 into str2
            if i == 0 {
                dpArr[i][j] = j
                continue
            } else if j == 0 {
                dpArr[i][j] = i
                continue
            }
            
            //translate into Swift indices
            let strI = str1.index(str1.startIndex, offsetBy: i - 1)
            let strJ = str2.index(str2.startIndex, offsetBy: j - 1)
            
            // if equal, no edit necessary, just use mED from strings without these letters
            if str1[strI] == str2[strJ] {
                dpArr[i][j] = dpArr[i - 1][j - 1]
            } else {
                //minimum edit distance if you choose to change this letter
                let mEDChange = dpArr[i - 1][j - 1]
                //minimum edit distance if you choose to remove this letter
                let mEDRemove = dpArr[i - 1][j]
                //minimum edit distance if you choose to insert a new letter
                let mEDInsert = dpArr[i][j - 1]
                
                //add 1 to operation that results in the smallest minimum edit distance
                dpArr[i][j] = 1 + min(mEDChange, mEDRemove, mEDInsert)
            }
        }
    }
    // return result
    return dpArr[str1.count][str2.count]
}

// test cases
minEditDistance(from: "", to: "abc") == 3
minEditDistance(from: "sunday", to:"saturday") == 3
minEditDistance(from: "AGGCTATCACCTGACCTCCAGGCCGATGCCC", to: "TAGCTATCACGACCGCGGTCGATTTGCCCGAC") == 13


