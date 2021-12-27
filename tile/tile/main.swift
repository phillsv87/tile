//
//  main.swift
//  tile
//
//  Created by Phillip Vance on 12/26/21.
//

import Foundation
import Carbon
import Cocoa


func runCommands()
{
    var i = 1
    while i < CommandLine.arguments.count {
        
        let arg=CommandLine.arguments[i].lowercased()
        let next=i < CommandLine.arguments.count-1 ? CommandLine.arguments[i+1] : ""
        
        do {
            switch arg {
                
            case "-move":
                i += try Commands.move(argI: i, nextArg: next, args: CommandLine.arguments)
                
            case "-auto-layout":
                i += try Commands.autoLayout(argI: i, nextArg: next, args: CommandLine.arguments)
                
            default:
                print("Invalid arg \(arg)")
                exit(1)
                    
                
            }
        }catch{
            print("Exiting due to error")
            exit(1)
        }
        
        i += 1
    }
}

runCommands()






