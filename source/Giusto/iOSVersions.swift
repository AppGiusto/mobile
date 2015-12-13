//
//  iOSVersions.swift
//  Giusto
//
//  Created by Nielson Rolim on 8/10/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

import Foundation

let iOS7 = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)
let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)