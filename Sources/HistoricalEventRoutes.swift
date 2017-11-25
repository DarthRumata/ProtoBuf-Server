//
//  HistoricalEventRoutes.swift
//  ProtoBuf-Server
//
//  Created by Rumata on 11/25/17.
//
//

import Foundation
import PerfectHTTP

extension Router {

  static func makeHistoricalEventRoutes() -> Routes {
    var routes = Routes()

    routes.add(method: .get, uri: "/", handler: { request, response in
      response.setHeader(.contentType, value: "text/html")
      response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
      response.completed()
    })

    return routes
  }

}

