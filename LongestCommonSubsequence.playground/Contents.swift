//: Playground - noun: a place where people can play

/*
 LCS Problem Statement: Given two sequences, find the longest subsequence present in both of them. A subsequence is a sequence that appears in the same relative order, but not necessarily contiguous. For example, “abc”, “abg”, “bdf”, “aeg”, ‘”acefg”, .. etc are subsequences of “abcdefg”. So a string of length n has 2^n different possible subsequences.
 https://www.geeksforgeeks.org/longest-common-subsequence/
 */

// Bottom up dynamic programming solution:
// Space complexity: O(str1 * str2) - TODO: can be reduced to O(min(str1, str2))
// Time complexity: O(str1 * str2)
func longestIncreasingSubsequence(_ str1: String, _ str2: String) -> String {
    
    let str1Length = str1.count
    let str2Length = str2.count
    
    var dpArr: [[String]] = Array(repeating: Array(repeating: "", count: str1Length + 1), count: str2Length + 1)
    
    // fill up DP array
    for j in 1...str2Length {
        for i in 1...str1Length {
            // Get string indexes, substract one to allow for padding around DP array, this way no need to check for index out of bounds
            let strIndex1 = str1.index(str1.startIndex, offsetBy: i - 1)
            let strIndex2 = str2.index(str2.startIndex, offsetBy: j - 1)
            
            if str1[strIndex1] == str2[strIndex2] {
                dpArr[j][i] = String(dpArr[j - 1][i - 1] + [str1[strIndex1]])
            } else {
                let str1Trimmed = dpArr[j][i - 1]
                let str2Trimmed = dpArr[j - 1][i]
                
                if str1Trimmed.count > str2Trimmed.count {
                    dpArr[j][i] = str1Trimmed
                } else {
                    dpArr[j][i] = str2Trimmed
                }
            }
        }
    }
    return dpArr[str2Length][str1Length]
}

longestIncreasingSubsequence("AAA", "AAAA")
longestIncreasingSubsequence("ABCDGH", "AEDFHR")
longestIncreasingSubsequence("AGGTAB", "GXTXAYB")
