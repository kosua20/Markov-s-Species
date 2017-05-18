//
//  main.swift
//  MarkovLetters
//
//  Created by Simon Rodriguez on 14/11/2015.
//  Copyright © 2015 Simon Rodriguez. All rights reserved.
//

import Foundation

/*
var lett = Grid(height: 20, width:10)
lett.shuffle()
lett.save("/Users/simon/Desktop/", name:"shuffle")
*/

let letsGen = LettersGenerator(height: 10, width : 7,radius:1, seed: 0)
letsGen.loadAlphabet("/Developer/Xcode/Markov Letters/Alphabet/")
do {
    try letsGen.computeDictionnary()
    for c in 1..<40 {
        let letter = try letsGen.generateLetter()
        letter.print()
        letter.save("/Developer/Xcode/Markov Letters/10x7_r1/", name: "\(c)")
    }
} catch GridError.SquareSize {
    print("Error with the grid")
}


