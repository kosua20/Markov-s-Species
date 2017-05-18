//
//  LettersGenerator.swift
//  MarkovLetters
//
//  Created by Simon Rodriguez on 13/11/2015.
//  Copyright © 2015 Simon Rodriguez. All rights reserved.
//

import Foundation

let kGridFileExtension = ".grid"

enum GridError: ErrorType {
    case Input
    case Size
    case SquareSize
}


struct Grid {
    let height : Int
    let width : Int
    
    //row by row
    var coeffs : [Int]
    
    init(height: Int, width: Int, fill : Int = 0) {
        self.height = height
        self.width = width
        coeffs = Array(count: height * width, repeatedValue: fill)
    }
    
    mutating func shuffle(){
        for i in 0..<height {
            for j in 0..<width {
                self[i,j] = drand48() < 0.5 ? 0 : 1
            }
        }
    }
    
    func isIndexValid(i : Int, j:Int) -> Bool {
        return (i >= 0) && (j >= 0) && (i < height) && (j < width)
    }
    
    subscript(i: Int, j:Int) -> Int {
        get {
            assert(isIndexValid(i, j: j), "Out of bounds")
            return coeffs[i*width+j]
        }
        set {
            assert(isIndexValid(i, j: j), "Out of bounds")
            coeffs[i*width+j] = newValue
        }
    }
    
    func squareCenteredOn(i : Int,_ j : Int, radius : Int) throws -> (Square,Int) {
        if(i-radius < 0 || j-radius < 0 || i+radius >= self.height || j+radius >= self.width){
            throw GridError.SquareSize
        }
        let lowerRow = i-radius
        let higherRow = i+radius
        let lowerCol = j-radius
        let higherCol = j+radius
        
        var coeffs : [Int] = []
        for k in lowerRow..<(higherRow+1) {
            for l in lowerCol..<(higherCol+1) {
                if(k==i && l==j){
                    continue
                }
                coeffs.append(self[k,l])
            }
        }
        //Square3(upperLeft: self[i-1,j-1], upper: self[i-1,j], upperRight: self[i-1,j+1], lowerLeft: self[i+1,j-1], lower: self[i+1,j], lowerRight: self[i+1,j+1], right: self[i,j+1], left: self[i,j-1])
        return (Square(radius: radius, coeffs: coeffs),self[i,j])
    }
    
    func print(){
        Swift.print("Grid (\(height)x\(width))")
        Swift.print(self.string("  ", full: "██"))
    }
    
    func rawPrint(){
        for i in 0..<height {
            for j in 0..<width {
                Swift.print(self[i,j]<0 ? self[i,j] : " \(self[i,j])", terminator: ",")
            }
            Swift.print()
        }

    }
    
    func string(empty : String, full: String, separator : String = "") -> String {
        var str = ""
        for i in 0..<height {
            for j in 0..<width {
                str = str +  (self[i,j] == 0 ? empty : full) + separator
            }
            str = str + "\n"
        }
        return str
    }
    
    func save(path : String, name:String = ""){
        let fullPath = path + (path.hasSuffix("/") ? "" : "/") + name + "_\(height)x\(width)" + kGridFileExtension
        //File structure : height,width\ndata (csv)
        let fullString = "\(height),\(width)" + "\n" + self.string("  ", full: "██", separator: "")
        guard NSFileManager.defaultManager().createFileAtPath(fullPath, contents: fullString.dataUsingEncoding(NSUTF8StringEncoding), attributes: nil) else {
            Swift.print("Error while saving at path \(fullPath)")
            return
        }
    }
    
    static func load(path : String) throws -> Grid {
        let stringRaw = try String(contentsOfFile: path)
        let dims = stringRaw.componentsSeparatedByString("\n").first!.componentsSeparatedByString(",").map({Int($0)})
        guard let height = dims[0], width = dims[1] else {
            Swift.print("Error reading the header")
            throw GridError.Input
        }
        var gr = Grid(height: height, width: width)
        var fullStrings = stringRaw.componentsSeparatedByString("\n")
        
        fullStrings.removeFirst()
        let arr = fullStrings.map({
            $0.characters.map({String($0)})
        })
        for i in 0..<height {
            for j in 0..<width {
                gr[i,j] = (arr[i][j*2] != " ") ? 1 : 0
            }
        }
        return gr
    }
}

struct Square : Hashable {
    var coeffs : [Int] = []
    let radius : Int!
    
    init(radius : Int){
        self.radius = radius
        self.coeffs = Array(count: (radius*2+1)*(radius*2+1)-1, repeatedValue: 0)
    }
    
    init(radius : Int, coeffs : [Int]){
        self.radius = radius
        self.coeffs = coeffs
    }
    
    var hashValue : Int {
        return coeffs.map({"\($0)"}).joinWithSeparator(",").hashValue
    }
    
    func looselyEqualTo(rhs : Square) -> Bool {
        if self.radius != rhs.radius {
            return false
        }
        for (n,c) in self.coeffs.enumerate() {
            if(c != -1 && rhs.coeffs[n] != -1 && c != rhs.coeffs[n]){
                return false
            }
        }
        return true
    }
    
    func rawPrint(){
        Swift.print(coeffs.map({"\($0)"}).joinWithSeparator(","))
    }
}

func ==(lhs : Square, rhs : Square) -> Bool {
    if lhs.radius != rhs.radius {
        return false
    }
    for (n,c) in lhs.coeffs.enumerate() {
        if(c != rhs.coeffs[n]){
            return false
        }
    }
    return true
}
/*
//TODO: Generalize Square as a protocol and implement the extraction method in another way
struct Square3 : Hashable {
    //TODO: better internal representation
    let upperLeft : Int
    let upper: Int
    let upperRight : Int
    let lowerLeft : Int
    let lower: Int
    let lowerRight : Int
    let right : Int
    let left : Int
    //let center : Int
    
    var hashValue : Int {
        return "\(upperLeft)\(upperRight)\(upper)\(left)\(right)\(lowerLeft)\(lowerRight)\(lower)".hashValue
    }
    
    func looselyEqualTo(rhs : Square3) -> Bool {
        
        let topRow = (self.upperLeft == -1 || rhs.upperLeft == -1 || self.upperLeft == rhs.upperLeft) && (self.upper == -1 || rhs.upper == -1 || self.upper == rhs.upper) && (self.upperRight == -1 || rhs.upperRight == -1 || self.upperRight == rhs.upperRight)
        let bottomRow = (self.lowerLeft == -1 || rhs.lowerLeft == -1 || self.lowerLeft == rhs.lowerLeft) && (self.lower == -1 || rhs.lower == -1 || self.lower == rhs.lower) && (self.lowerRight == -1 || rhs.lowerRight == -1 || self.lowerRight == rhs.lowerRight)
        let middleRow = (self.left == -1 || rhs.left == -1 || self.left == rhs.left) && (self.right == -1 || rhs.right == -1 || self.right == rhs.right)
        return topRow && middleRow && bottomRow
    }
    
    func rawPrint(){
        Swift.print("\(upperLeft),\(upper),\(upperRight)\n\(left),  ,\(right)\n\(lowerLeft),\(lower),\(lowerRight)\n")
    }
    
}

func ==(lhs : Square3, rhs : Square3) -> Bool {
    return lhs.upperLeft==rhs.upperLeft && lhs.upperRight==rhs.upperRight && lhs.upper==rhs.upper && lhs.lower==rhs.lower && lhs.lowerLeft==rhs.lowerLeft && lhs.lowerRight==rhs.lowerRight && lhs.right==rhs.right && lhs.left==rhs.left //&& lhs.center==rhs.center
}
*/

class Spiral {
    static func unfold(position : (Int,Int), height : Int, width : Int) -> [(Int,Int)]{
       // print("New loop with pos: \(position), height:\(height), width:\(width)")
        if(height<=0 || width<=0){
            return []
        }
        
        let initialPosition = position // saved as shift
        var currentPosition = (0,0)
        var positions : [(Int,Int)] = [currentPosition]
        if(height==1){
            for j in 1..<width {
                positions.append((0,j))
            }
            return positions.map({ (initialPosition.0 + $0.0, initialPosition.1 + $0.1)})
        }
        if(width==1){
            for i in 1..<height {
                positions.append((i,0))
            }
            return positions.map({ (initialPosition.0 + $0.0, initialPosition.1 + $0.1)})
        }
        
        while currentPosition.1 < width-1 {
            currentPosition.1 = currentPosition.1 + 1
            positions.append(currentPosition)
        }
        while currentPosition.0 < height-1 {
            currentPosition.0 = currentPosition.0 + 1
            positions.append(currentPosition)
        }
        while currentPosition.1 > 0 {
            currentPosition.1 = currentPosition.1 - 1
            positions.append(currentPosition)
        }
        while currentPosition.0 > 1 {
            currentPosition.0 = currentPosition.0 - 1
            positions.append(currentPosition)
        }
        
        positions = positions.map({ (initialPosition.0 + $0.0, initialPosition.1 + $0.1)})
        currentPosition.0 = initialPosition.0 + currentPosition.0
        currentPosition.1 = initialPosition.0 + currentPosition.1 + 1
        
        return positions + Spiral.unfold(currentPosition, height: height-2, width: width-2)

    }
}

class LettersGenerator {
    
    var alphabet : [Grid] = []
    var dictionnary : [Square : (Int,Int)] = [:]
    let height : Int!
    let width : Int!
    let seed : Int!
    let radius : Int! //2*radius+1
    
    init(height : Int, width : Int, radius : Int, seed : Int = -1){
        self.height = height
        self.width = width
        self.radius = radius
        self.seed = seed == -1 ? Int(NSDate().timeIntervalSince1970) : seed
        srand48(self.seed)
    }
    
    func randomLetter(){
        
    }
    
    func marginGrid() -> Grid{
        var grid = Grid(height: height, width: width, fill:-1)
        for j in 0..<grid.width {
            grid[0,j] = 0
            grid[grid.height-1,j] = 0
        }
        for i in 0..<grid.height {
            grid[i,0] = 0
            grid[i,grid.width-1] = 0
        }
        // grid.shuffle()
        //grid.print()
        return grid
    }
    
    func nextGrid() -> Grid {
        var grid = Grid(height: height, width: width, fill:1)
        grid.shuffle()
        grid.print()
        return grid
    }
    
    func loadAlphabet(mainPath : String){
        alphabet.removeAll(keepCapacity: true)
        for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters {
            let grid = try! Grid.load(mainPath + (mainPath.hasSuffix("/") ? "" : "/")  + String(letter) + kGridFileExtension)
             alphabet.append(grid)
        }
        
        //alphabet.map({$0.print()})
        
    }
    
    func computeDictionnary() throws{
         for letter in alphabet {
            for i in radius..<height-radius {
                for j in radius..<width-radius{
                   
                    let (localSquare, ind) = try letter.squareCenteredOn(i, j, radius: radius)
                    let tuple = (ind==0 ? 1 : 0,ind==1 ? 1 : 0)
                    if let count = dictionnary[localSquare] {
                            dictionnary[localSquare] = (count.0 + tuple.0, count.1 + tuple.1)
                    } else {
                        dictionnary[localSquare] = tuple
                    }
                }
            }
        }
        print("Dictionary built")
    }
    
    func generateLetter() throws -> Grid {
        var letter = marginGrid()
        let indices = Spiral.unfold((radius,radius), height: height-2*radius, width: width-2*radius)
        for (i,j) in indices {
                //TODO: maybe a factory method on square
                let (localSquare,_) = try letter.squareCenteredOn(i, j, radius: radius)
                var arr : [(Int,Int)] = []
                var res = (0,0)
                for key in dictionnary.keys {
                    
                    if (key.looselyEqualTo(localSquare)){
                        
                        let tt = dictionnary[key]!
                        arr.append(tt)
                        res.0 = res.0 + tt.0
                        res.1 = res.1 + tt.1
                    }
                }
                let count = res.0 + res.1
                let proba = Double(res.0)/Double(count)
                let value = (drand48() < proba) ? 0 : 1
                letter[i,j] = value
        }
        return letter
    }
    
    
}

