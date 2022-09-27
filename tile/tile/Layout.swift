//
//  Layout.swift
//  tile
//
//  Created by Phillip Vance on 12/26/21.
//

import Foundation
import Carbon
import Cocoa

enum LayoutError: Error {
    case failed
}

enum MoveDirection : String {
    case Left = "left"
    case Right = "right"
    case Up = "up"
    case Down = "down"
}

class LayoutManager {
    static fileprivate var _layouts:[Layout]?
    static fileprivate var _cols:[Col]?
    
    
    
    static func getLayouts() -> (layouts:[Layout], allCols:[Col])
    {
        
        if _layouts != nil {
            return (_layouts!,_cols!)
        }
        
        // Load layout JSON
        guard let layoutData=FileManager.default.contents(atPath: NSString(string:"~/.tile/layout.json").expandingTildeInPath) else {
            print("~/.tile/layout.json")
            exit(1)
        }
        
        var layouts: [Layout]
        do {
            layouts = try JSONDecoder().decode([Layout].self, from: layoutData)
        }catch{
            layouts=[]
            print("Failed to load layouts json")
        }
        
        var currentLayout: String = "default"
        if let currentLayoutData=FileManager.default.contents(atPath: NSString(string:"~/.tile/state/current-layout.json").expandingTildeInPath) {
            do {
                currentLayout = try JSONDecoder().decode(String.self, from: currentLayoutData)
            }catch{
                print("Failed to current layout json")
            }
        }
        
        

        // example / format layouts
        layouts=Layout.expandAry(currentLayout,layouts)
        let cols=Layout.joinCols(layouts)
        
        _layouts=layouts
        _cols=cols
        
        return (layouts,cols)
    }
}

class Layout: Codable {
    
    var index: Int?
    
    var layout: String?
    
    var x: Double?
    
    var y: Double?
    
    var width: Double?
    
    var height: Double?
    
    var minWidth : Int?
    
    var maxWidth : Int?
    
    var minHeight: Int?
    
    var maxHeight: Int?
    
    var minScreens: Int?
    
    var maxScreens: Int?
    
    var gap: Double?
    
    var cols:[Col] = []
    
    static func create2x2() -> Layout
    {
        let layout=Layout()
        layout.cols=[
            {
                let col=Col()
                col.rows=[Row(),Row()]
                return col
            }(),
            {
                let col=Col()
                col.rows=[Row(),Row()]
                return col
            }()]
        return layout
    }
    
    static func create2x1() -> Layout
    {
        let layout=Layout()
        layout.cols=[
            {
                let col=Col()
                col.rows=[Row()]
                return col
            }(),
            {
                let col=Col()
                col.rows=[Row()]
                return col
            }()]
        return layout
    }
    
    static func FindLayout(_ layouts:[Layout], _ rect:NSRect) -> (
        rect:NSRect,
        layout:Layout,
        col:Col,
        row:Row,
        rowSpan:Int)?
    {
        var area:Double=0
        var layout:Layout? = nil
        var col:Col? = nil
        for l in layouts {
            
            for c in l.cols {
                
                let ints = c.getRect().intersection(rect)
                let a=ints.width * ints.height
                
                if(a > area){
                    area=a
                    layout=l
                    col=c
                }
                
            }
        }
        
        if col?.rows == nil {
            return nil
        }
        
        let fillTolerance=0.9
        var bottomIndex=0
        var row:Row? = nil
        
        area=0
        for r in col!.rows! {
            
            let rowRect = r.getRect()
            let ints = rowRect.intersection(rect)
            let a=ints.width * ints.height
            
            if a > area {
                area=a
                row=r
            }
            
            if a/(rowRect.width*rowRect.height) >= fillTolerance && r.index!>bottomIndex {
                bottomIndex=r.index!
            }
            
        }
        
            
        
        
        if area > 0 && layout != nil && col != nil && row != nil {
            return (row!.getRect(),layout!,col!,row!,bottomIndex+1-row!.index!)
        }else{
            return nil
        }
    }
    
    static func expandAry(_ currentLayout:String, _ sourceLayouts: [Layout]) -> [Layout]
    {
        var height:Double=0
        for screen in NSScreen.screens {
            print("frame minX=\(screen.frame.minX),  minY=\(screen.frame.minY),  maxX=\(screen.frame.maxX),  maxY=\(screen.frame.maxY)")
            if screen.frame.minY == 0 && screen.frame.minX == 0 {
                height=screen.frame.maxY
            }
        }
        
        var layouts:[Layout] = []
        
        var index:Int = 0
        var colIndex:Int = 0
        for screen in NSScreen.screens.sorted(by: {
            return $0.visibleFrame.minX < $1.visibleFrame.minX
        } ) {
            let rect=screen.visibleFrame
            var layout:Layout
            
            print("screen width=\(rect.width),  height=\(rect.height),  x=\(rect.minX),  y=\(rect.minY), maxY=\(rect.maxY)")
            
            layout=sourceLayouts.last ?? create2x1()
            for l in sourceLayouts {
                print("layout \(rect.width), screens=\(NSScreen.screens.count), maxWidth=\(l.maxWidth ?? 0), minWidth=\(l.minWidth ?? 0), maxScreens=\(l.maxScreens ?? 0), minScreens=\(l.minScreens ?? 0), layout=\(l.layout ?? "(all)")")
                
                if l.layout != nil && currentLayout != l.layout {
                    continue
                }
                
                if l.minWidth != nil && Int(rect.width) < l.minWidth! {
                    continue
                }
                
                if l.maxWidth != nil && Int(rect.width) > l.maxWidth! {
                    continue
                }
                
                if l.minHeight != nil && Int(rect.height) < l.minHeight! {
                    continue
                }
                
                if l.maxHeight != nil && Int(rect.height) > l.maxHeight! {
                    continue
                }
                
                if l.minScreens != nil && NSScreen.screens.count < l.minScreens! {
                    continue
                }
                
                if l.maxScreens != nil && NSScreen.screens.count > l.maxScreens! {
                    continue
                }
                
                print("select \(rect.width)")
                layout=l
                break
                
            }
            layout=layout.clone()
            layout.expand(
                index,
                colIndex,
                rect.minX,
                height-rect.maxY,
                rect.width,
                rect.height)
            
            index += 1
            colIndex += layout.cols.count
            
            layouts.append(layout)
            
        }
        
        return layouts.sorted {
            return $0.x! < $1.x!
        }
    }
    
    static func joinCols(_ layouts:[Layout]) -> [Col]
    {
        var cols:[Col]=[]
        
        for l in layouts {
            cols.append(contentsOf: l.cols)
        }
        
        return cols
    }
    
    public func clone() -> Layout
    {
        do{
            let data = try JSONEncoder().encode(self)
            let copy = try JSONDecoder().decode(Layout.self, from: data)
            return copy
        }catch{
            return Layout()
        }
    }
    
    // Exapndes the Layout with columns and rows with absolute dimensions
    func expand(
        _ index: Int,
        _ colStartIndex: Int,
        _ screenX: Double,
        _ screenY: Double,
        _ screenWidth:Double,
        _ screenHeight:Double)
    {
        if self.width == nil {
            self.width = screenWidth
        }
        if self.height == nil {
            self.height = screenHeight
        }
        if self.x == nil {
            self.x = screenX
        }
        if self.y == nil {
            self.y = screenY
        }
        let width=self.width ?? screenWidth
        let height=self.height ?? screenHeight
        
        self.index=index;
        
        var remaning = width
        var flex:Double = 0
        // apply wwidth flex
        for col in self.cols {
            col._parent=self
            if col.flex == nil {
                col.flex = 1
            }
            if col.width == nil || col.width! < 0 {
                if col.flex! < 0 {
                    col.width=0
                }else{
                    flex+=col.flex!
                }
            }else{
                remaning -= col.width!
            }
        }
        var x:Double = self.x!
        var i:Int = colStartIndex
        for col in cols {
            if col.width == nil {
                col.width = col.flex! / flex * remaning
            }
            col.x = x
            col.index = i
            x += col.width!
            i += 1
            
            if col.paddingLeft == nil {
                col.paddingLeft = col.padding
            }
            
            if col.paddingRight == nil {
                col.paddingRight = col.padding
            }

            
            if gap != nil {
                if col.paddingLeft == nil {
                    col.paddingLeft = col.index == 0 ? gap! : gap!/2
                }
                if col.paddingRight == nil {
                    col.paddingRight = col.index == cols.count-1 ? gap! : gap!/2
                }
            }
            
            if col.paddingLeft != nil {
                col.x! += col.paddingLeft!
                col.width! -= col.paddingLeft!
            }
            
            if col.paddingRight != nil {
                col.width! -= col.paddingRight!
            }
        }
        
        
        // apply height flex
        for col in cols {
            if col.rows == nil {
                col.rows=[Row()]
            }
            
            remaning = height
            flex = 0
            
            for row in col.rows! {
                
                row._parent=col
                if row.height == nil || row.height! < 0 {
                    if row.flex == nil {
                        row.flex = 1
                    }
                    if row.flex! < 0 {
                        row.height=0
                    }else{
                        flex+=row.flex!
                    }
                }else{
                    remaning -= row.height!
                }
            }
            
            var y:Double = self.y!
            i=0
            for row in col.rows! {
                if row.height == nil {
                    row.height = row.flex! / flex * remaning
                }
                row.y = y
                row.index = i
                y += row.height!
                i += 1
                
                if row.paddingTop == nil {
                    row.paddingTop = row.padding
                }
                
                if row.paddingBottom == nil {
                    row.paddingBottom = row.padding
                }
                
                if gap != nil {
                        
                    if row.paddingTop == nil {
                        row.paddingTop = row.index == 0 ? gap! : gap!/2
                    }
                    
                    if row.paddingBottom == nil {
                        row.paddingBottom = row.index == col.rows!.count-1 ? gap! : gap!/2
                    }
                }
                
                if row.paddingTop != nil {
                    row.y! += row.paddingTop!
                    row.height! -= row.paddingTop!
                }
                
                if row.paddingBottom != nil {
                    row.height! -= row.paddingBottom!
                }
            }
        }
        
    }
    
}

class Col: Codable {
    
    var index: Int?
    
    var x: Double?
    
    var width: Double?
    
    var flex: Double? = 1
    
    var padding: Double?
    
    var paddingLeft: Double?
    
    var paddingRight: Double?
    
    var rows: [Row]?
    
    fileprivate var _parent: Layout?
    
    func getRect() -> NSRect
    {
        return getRect(0,rows!.count)
    }
    
    
    func getRect(_ rowIndex:Int, _ rowSpan:Int) -> NSRect
    {
        if rows == nil || rowIndex < 0 || rowIndex >= rows!.count {
            return NSRect(x: x ?? 0, y: _parent?.y ?? 0, width: 0, height: 0)
        }
        var endIndex=rowIndex+rowSpan-1
        if endIndex >= rows!.count {
            endIndex = rowIndex
        }
        
        let start=rows![rowIndex]
        let end=rows![endIndex]
        return start.getRect().union(end.getRect())
        
    }
}

class Row: Codable {
    
    var index: Int?
    
    var y: Double?
    
    var height: Double?
    
    var flex: Double? = 1
    
    var padding: Double?
    
    var paddingTop: Double?
    
    var paddingBottom: Double?
    
    fileprivate var _parent: Col?
    
    func getRect() -> NSRect
    {
        return NSRect(x: _parent?.x ?? 0, y: y ?? 0, width: _parent?.width ?? 0, height: height ?? 0)
    }
}
