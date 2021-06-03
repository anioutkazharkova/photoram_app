//
//  DI.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation

class DI {
    private static var _dataContainer: IDataContainer? = nil
    private static var _serviceContainer: IServiceContainer? = nil
    
    static var dataContainer: IDataContainer{
        get {
            if _dataContainer == nil {
                _dataContainer = DataContainer()
            }
            return _dataContainer!
        }
    }
    
    static var serviceContainer: IServiceContainer{
        get {
            if _serviceContainer == nil {
                _serviceContainer = ServiceContainer()
            }
            return _serviceContainer!
        }
    }
}
