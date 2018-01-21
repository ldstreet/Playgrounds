//: Playground - noun: a place where people can play

//Quicksort
func quickSort<T: Comparable>(_ array: [T]) -> [T] {
    
    var returnArr = array
    quickSortHelp(&returnArr, start: 0, end: array.count)
    
    return returnArr
}

func quickSortHelp<T: Comparable>(_ array: inout [T], start: Int, end: Int) {
    
    guard start < end else {
        return
    }
    
    var pivot = start
    
    for i in (start + 1)..<end {
        
        // if value is less than pivot, move to left side of pivot
        if array[i] < array[pivot] {
            
            //swap val at i with element to right of pivot
            let tmp = array[pivot + 1]
            array[pivot + 1] = array[i]
            array[i] = tmp
            
            //swap pivot val with item to right
            let pivotVal = array[pivot]
            array[pivot] = array[pivot + 1]
            array[pivot + 1] = pivotVal
            
            pivot += 1
        }
    }
    
    //recurr
    quickSortHelp(&array, start: start, end: pivot)
    quickSortHelp(&array, start: pivot + 1, end: end)
}

quickSort([0, 1, 5, -20, 3, 66, 2, 9, 7, 22, 11, -33, 100])

