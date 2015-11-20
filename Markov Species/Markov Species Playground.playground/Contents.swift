//: Playground - noun: a place where people can play

import Cocoa
import XCPlayground
import Quartz
import CoreGraphics

var arr : [Double] = []
var min = 1.0
var max = 0.0
srand48(Int(NSDate().timeIntervalSince1970))
let kItems = 1000
for i in 0..<kItems {
    
    let alea = drand48()
    let alea2 = drand48()
    let random = sin(2*M_PI*alea)*sqrt(-2.0*log(alea2))
    arr.append(random)
    if(random<min){
        min = random
    }
    if(random>max){
        max = random
    }
}



arr.sortInPlace({$0<$1})

let kStep = 0.5
var dico : [Double:Int] = [:]
var startIndex = 0
for j in -Int(1.0/kStep)*4..<Int(1.0/kStep)*4{
    var count = 0
    while(startIndex<arr.count && arr[startIndex] < Double(j)*kStep){
        startIndex++
        count++
    }
    dico[Double(j)*kStep] = count
}

var keys = dico.keys.array.sort({$0<$1})
for key in keys {
    print("\(key): \(dico[key])")
}

let view = NSView(frame: CGRectMake(0.0, 0.0, 800.0, 600.0))
XCPShowView("idhugy", view: view)
let context = NSGraphicsContext.currentContext()! as! CGContextRef
CGContextSetFillColorWithColor(context, CGColorCreateGenericRGB(1.0, 0.0, 0.0, 1.0))
CGContextAddRect(context, CGRectMake(10.0, 20.0, 100.0, 100.0))
CGContextFillRect(context, CGRectMake(30.0, 40.0, 100.0, 100.0))









/*var dico : [Double:Int] = [:]

for j in -4..<5 {
    dico[Double(j)] = 0
}
floor(-3.1)
for i in 0..<1000 {
    dico[floor(arr[i])]!++
}

var keys = dico.keys.array.sorted({$0<$1})
for key in keys {
    println("\(key): \(dico[key])")
}**/










