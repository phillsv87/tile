//
//  Commands.swift
//  tile
//
//  Created by Phillip Vance on 12/27/21.
//

import Foundation

class Commands {
    
    
    static func run()
    {
        var i = 1
        while i < CommandLine.arguments.count {
            
            let arg=CommandLine.arguments[i].lowercased()
            let next=i < CommandLine.arguments.count-1 ? CommandLine.arguments[i+1] : ""
            
            do {
                switch arg {
                    
                case "-sleep-ms":
                    i += try sleepMs(argI: i, nextArg: next, args: CommandLine.arguments)
                    
                case "-move":
                    i += try move(argI: i, nextArg: next, args: CommandLine.arguments)
                    
                case "-full-screen":
                    i += try fullScreen(argI: i, nextArg: next, args: CommandLine.arguments)
                    
                case "-auto-layout":
                    i += try autoLayout(argI: i, nextArg: next, args: CommandLine.arguments)
                    
        // Load layout JSON
        guard let layoutData=FileManager.default.contents(atPath: NSString(string:"~/.tile/layout.json").expandingTildeInPath) else {
            print("~/.tile/layout.json")
            exit(1)
                    
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
    
        var layouts: [Layout]
        
        do {
            layouts = try JSONDecoder().decode([Layout].self, from: layoutData)
        }catch{
            layouts=[]
            print("Failed to load layouts json")
        }

        // example / format layouts
        layouts=Layout.expandAry(layouts)
        let cols=Layout.joinCols(layouts)
        
        _layouts=layouts
        _cols=cols
        
    
    static func sleepMs(argI:Int, nextArg:String, args:[String]) throws -> Int
    {
        guard let v=UInt32(nextArg) else {
            print("Invalid -sleep-ms value. UInt32 expected")
            throw LayoutError.failed
        }
        
        usleep(v*1000)
        
        return 1
    }
    
    static func move(argI:Int, nextArg:String, args:[String]) throws -> Int
    {
        
        let (layouts,cols)=LayoutManager.getLayouts()
        
        var dir:MoveDirection = .Left
        
        guard let v=MoveDirection(rawValue: nextArg) else {
            print("Invalid -move value. left, right, up or down expected")
            throw LayoutError.failed
        }
        dir=v
        
        // get front window
        guard let front=AccessibilityElement.frontmostWindow() else {
            print("front window not found")
            throw LayoutError.failed
        }

        // find window position in layout
        guard let found = Layout.FindLayout(layouts, front.rectOfElement()) else {
            print("Unable to determine window position in layout")
            throw LayoutError.failed
        }

        var x = found.col.index!
        var y = found.row.index!
        var hor:Bool
        var bump=false
        switch dir {
            
        case .Left:
            if x>0 {
                x -= 1
            }
            hor=true
            
        case .Right:
            if x<cols.count-1 {
                x += 1
            }
            hor=true
            
        case .Up:
            if y>0{
                y -= 1
            }else{
                bump=true
            }
            hor=false
            
        case .Down:
            y += 1
            hor=false
            
        }


        let col=cols[x]
        if y >= col.rows!.count {
            y=col.rows!.count-1
            bump=true
        }
        let row=col.rows![y]

        var revBump = false

        if !hor && bump && found.rowSpan == col.rows!.count {
            bump=false
            revBump=true
        }

        let rect=bump ? col.getRect() : revBump ? row.getRect() : col.getRect(row.index ?? 0,found.rowSpan)

        front.setRectOf(rect)
        
        return 1
    }
    
    
    static func autoLayout(argI:Int, nextArg:String, args:[String]) throws -> Int
    {
        let all=AccessibilityElement.allWindows()
        
        let (layouts,_)=LayoutManager.getLayouts()
        
        for win in all {
            
            if win.isSystemDialog() || win.isSheet() {
                continue
            }
            
            guard let found = Layout.FindLayout(layouts, win.rectOfElement()) else {
                continue
            }
            
            win.setRectOf(found.col.getRect(found.row.index!,found.rowSpan))
        }
        
        return 0
        
    }
    
    
    static func fullScreen(argI:Int, nextArg:String, args:[String]) throws -> Int
    {
        // get front window
        guard let front=AccessibilityElement.frontmostWindow(),
              let screen=front.getScreen() else {
            print("front window not found")
            throw LayoutError.failed
        }

        front.setRectOf(screen.visibleFrame)

        return 0
        
    }
}
