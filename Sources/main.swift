//
//  main.swift
//  ProtoBuf-Server
//
//  Created by Rumata on 11/25/17.
//  Copyright © 2017 Yalantis. All rights reserved.
//

import Foundation
import PerfectHTTPServer
import PerfectRequestLogger
import PerfectLib

let server = HTTPServer()

// Add the routes to the server.
server.addRoutes(Router.makeRoutes())

// Set a listen port of 8181
server.serverPort = 8181

let logger = RequestLogger()
RequestLogFile.location = "/Users/rumata/Library/Developer/myLog.log"

server.setRequestFilters([(logger, .high)])
// Response filter at low priority to be executed last
server.setResponseFilters([(logger, .low)])

do {
  // Launch the HTTP server.
  try server.start()
} catch PerfectError.networkError(let err, let msg) {
  print("Network error thrown: \(err) \(msg)")
}


