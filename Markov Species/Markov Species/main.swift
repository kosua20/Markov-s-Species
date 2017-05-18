//
//  main.swift
//  Markov Species
//
//  Created by Simon Rodriguez on 06/08/2015.
//  Copyright © 2015 Simon Rodriguez. All rights reserved.
//

import Foundation

var dictionnary : [String:[String]] = [:]

//List of args
//
// - build markov chain:
//
//      build --size=2 path/to/file
//
// - generate a species:
//
//      generate --species=1 --words=1 --seed=5678 path/to/file
//


func main(all_args : [String] = []){
    var args = all_args
    args.removeAtIndex(0)
    if(args.count < 2){
        print("Missing argument")
        return
    }
    switch args[0] {
        case "build":
            var size = 2
            //var upto = false
            
            for i in 1..<args.count - 1 {
                if args[i].hasPrefix("--size="), let number = Int(args[i].substringFromIndex(args[i].startIndex.advancedBy(7))){
                    size = number
                /*} else if args[i].hasPrefix("--upto="), let number = Int(args[i].substringFromIndex(args[i].startIndex.advancedBy(7))) {
                    upto = (number != 0)
                    */
                } else {
                    print("Error with the argument \(args[i])")
                }
            }
            
            for i in 2..<size+1 {
                print("Generating dictionnary with ngrams of size \(i)...")
                computeMarkov(args.last!, size: i)
            }
        
        case "generate":
            var species = 1
            var words = 1
            var seed = -1
            for i in 1..<args.count - 1 {
                if args[i].hasPrefix("--species="), let number = Int(args[i].substringFromIndex(args[i].startIndex.advancedBy(10))){
                    species = number
                } else if args[i].hasPrefix("--words="), let number = Int(args[i].substringFromIndex(args[i].startIndex.advancedBy(8))){
                    words = number
                } else if args[i].hasPrefix("--seed="), let number = Int(args[i].substringFromIndex(args[i].startIndex.advancedBy(7))){
                    seed = number
                }else {
                    print("Error with the argument \(args[i])")
                }
            }
            print("Generating \(species) species names with a length of \(words) word" + (words>1 ? "s." : "."))
            loadDictionnary(args.last!)
            generate(species, words: words, seed: seed)
    default:
        print("Unknown argument")
    }
    
}

func loadDictionnary(path : String) -> Bool {
    do {
        let content = try String(contentsOfFile: path)
        let lines = content.componentsSeparatedByString("\n")
        for line in lines {
            let splitLine = line.componentsSeparatedByString(":")
            if (splitLine.count < 2){ return false }
            let key = splitLine[0]
            let values = splitLine[1].componentsSeparatedByString(",")
            dictionnary[key] = values
        }
        return true
    } catch _ {
    }
    return false
}

func computeMarkov(path : String, size : Int){
    do {
        let content = try String(contentsOfFile: path)
        dictionnary = [:]
        let species = content.stringByReplacingOccurrencesOfString(" ", withString: ".").componentsSeparatedByString("\n").map({"." + $0.lowercaseString + "."})
        for animal in species {
            let nsAnimal = NSString(string: animal)
        
            var ngram = ""
            
            for i in 0..<(max(0,nsAnimal.length - size)) {
                ngram = nsAnimal.substringWithRange(NSMakeRange(i, size))
               
                let letter = String(animal[animal.startIndex.advancedBy(i+size)])
                if let _ = dictionnary[ngram as String] {
                    dictionnary[ngram as String]!.append(letter)
                } else {
                    dictionnary[ngram as String] = [letter]
                }
            }
           
        }
        
        //We rewrite the dictionnary as a string
        //Format : key:value1,value2,value3\n
        var fileString = ""
        for (key,value) in dictionnary {
            fileString += (key + ":" + value.joinWithSeparator(",") + "\n")
        }
        //And we save it on disk, in the same directory as the source
        let filePath = (path as NSString).stringByDeletingLastPathComponent + "/export_" + ((path as NSString).lastPathComponent as NSString).stringByDeletingPathExtension + "_\(size).txt"
        let result: Bool
        do {
            try fileString.writeToFile(filePath, atomically: false, encoding: NSUTF8StringEncoding)
            result = true
        } catch _ {
            result = false
        }
        print("Operation success: \(result). Dictionnary saved at path \(filePath)")
    } catch _ {
        print("Couldn't load file at path \(path)")
    }
}

func generate(iterations : Int, words : Int, seed: Int){
    
    //First check
    if(dictionnary.isEmpty){ print("No dictionnary loaded"); return }
    
    //We need to know on how many previous letters our markov chain is based:
    //We read a key from the dictionnary and get its length
    var keys = Array(dictionnary.keys)
    let ngramLength = (keys.first!).characters.count
    print("Detected ngrams of length \(ngramLength).")
    keys = keys.filter({$0.hasPrefix(".")})
    
    var names : [String] = []
    let realSeed = seed == -1 ? Int(NSDate().timeIntervalSince1970) : seed
    srand48(realSeed)
    print("Seed: \(realSeed)")
    
    
    for _ in 0..<words*iterations {
        
        var iter = 0
        var name = keys[randomIntLowerThan(keys.count)]
        
        var newCharacter = ""
        
        while (newCharacter != "." || iter < 4){
            let nsName = NSString(string:name)
            if let value = dictionnary[nsName.substringFromIndex(nsName.length - ngramLength) as String] {
                newCharacter = value[randomIntLowerThan(value.count)]
                name = name + newCharacter
            } else {
                name = name + keys[randomIntLowerThan(keys.count)]
                newCharacter = String(name[name.endIndex.predecessor()])
            }
            iter++
        }
        
        name = name.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ". "))
        name = name.stringByReplacingOccurrencesOfString(".", withString: "")
        name = name.capitalizedString
        names.append(name)
    }
    for i in 0..<iterations {
        var fullName = ""
        for j in 0..<words {
            fullName += (" " + names[i*words + j])
        }
        print("New species:" + fullName)
    }
}

func randomIntLowerThan(max: Int) -> Int {
    return Int(floor(drand48()*Double(max)))
}


main(Process.arguments)
