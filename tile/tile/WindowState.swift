//
//  WindowState.swift
//  tile
//
//  Created by Phillip Vance on 1/21/22.
//

import Foundation

class WindowState: Codable {
    
    
    public static func GetState(_ win:AccessibilityElement, _ layouts:[Layout]) -> WindowState
    {
        let rect=win.rectOfElement()
        let layout=Layout.FindLayout(layouts, rect)
        
        let state=WindowState()
        state.pid=win.getPid()
        state.id=win.getIdentifier()
        state.x=rect.minX
        state.y=rect.minY
        state.width=rect.width
        state.height=rect.height
        state.layoutX=layout?.layout.x
        state.layoutY=layout?.layout.y
        state.layoutWidth=layout?.layout.width
        state.layoutHeight=layout?.layout.height
        
        return state
        
    }
    
    public static func LoadState(_ id:Int) -> WindowState?
    {
        let path=NSString(string:"~/.tile/state/\(id).json").expandingTildeInPath
        
        guard FileManager.default.fileExists(atPath:path),
              let data=FileManager.default.contents(atPath:path)
        else {
            return nil
        }
        
        do{
            return try JSONDecoder().decode(WindowState.self, from: data)
        }catch{
            return nil
        }
    }
    
    var pid: Int32?
    
    var id: Int?
    
    var x: Double?
    
    var y: Double?
    
    var width: Double?
    
    var height: Double?
    
    var layoutX: Double?
    
    var layoutY: Double?
    
    var layoutWidth: Double?
    
    var layoutHeight: Double?
    
    public func getRect() -> CGRect {
        return CGRect(x: x ?? 0, y: y ?? 0, width: width ?? 0, height: height ?? 0)
    }
    
    public func Save()
    {
        do{
            let data = try JSONEncoder().encode(self)
            
            let dir=NSString(string:"~/.tile/state").expandingTildeInPath
            
            if !FileManager.default.fileExists(atPath:dir) {
                try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            }
            
            try data.write(to: URL(fileURLWithPath:"\(dir)/\(id ?? 0).json"))
            
        }catch{
            
        }
    }
    
}
