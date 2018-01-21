//: Playground - noun: a place where people can play

//Merge sort in swift using generics
func mergeSort<T: Comparable>(_ array: [T]) -> [T] {
    
    //base case
    if array.count <= 1 { return array }

    //split in half and sort
    let sortedFirstHalf = mergeSort(Array(array[0..<(array.count / 2)]))
    let sortedSecondHalf = mergeSort(Array(array[(array.count / 2)..<array.count]))
    
    //merge sorted arrays back together, keeping sorted
    return merge(sortedFirstHalf, sortedSecondHalf)
}

//merge implementation
func merge<T: Comparable>(_ arr1: [T], _ arr2: [T]) -> [T] {
    
    var newArr = [T]()
    
    var i = 0
    var j = 0
    while newArr.count < arr1.count + arr2.count {
        if i >= arr1.count { // reached end or arr1
            return newArr + arr2[j...]
        }
        if j >= arr2.count { // reached end of arr2
            return newArr + arr1[i...]
        }
        if arr1[i] < arr2[j] {
            newArr.append(arr1[i])
            i += 1
        } else {
            newArr.append(arr2[j])
            j += 1
        }
    }
    
    return newArr // just to be safe
}

mergeSort([0, 43, 2, 5, 2, 4, 7, 4, 9, -10])
