//
//  Daemon.swift
//  tile
//
//  Created by Phillip Vance on 12/27/21.
//

import Foundation

class Daemon
{
    
    private var applications:Applications?
    
    func start()
    {
        if applications != nil {
            return
        }
        
        applications=Applications()
        
        applications?.start()

    }
}
