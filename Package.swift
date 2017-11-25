//
//  Package.swift
//  ProtoBuf-Server
//
//  Created by Rumata on 11/25/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import PackageDescription

let package = Package(
  name: "ProtoBuf-Server",
  dependencies: [
    .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2),
    .Package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 1),
    .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 4)
  ]
)

