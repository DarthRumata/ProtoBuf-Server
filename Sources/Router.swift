//
//  Router.swift
//  ProtoBuf-Server
//
//  Created by Rumata on 11/25/17.
//
//

import Foundation
import PerfectHTTP

enum Router {

  static func makeRoutes() -> Routes {
    var routes = Routes()
    routes.add(Router.makeHistoricalEventRoutes())
    routes.add(Router.makeHistoricalEventJSONRoutes())

    return routes
  }

}
