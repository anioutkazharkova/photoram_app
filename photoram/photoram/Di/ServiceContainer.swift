//
//  ServiceContainer.swift
//  photoram
//
//  Created by Anna Zharkova on 26.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation

protocol IServiceContainer : AnyObject {
    var postService: PostService {get }
    
    var imageService: ImageService {get}
}

class ServiceContainer: IServiceContainer {
    lazy var postService: PostService = {
       return PostService()
    }()
    
    lazy var imageService: ImageService = {
       return ImageService()
    }()
}
