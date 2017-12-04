//
//  HistoricalEventRoutes.swift
//  ProtoBuf-Server
//
//  Created by Rumata on 11/25/17.
//
//

import Foundation
import PerfectHTTP

private let uri = "events"
private let database = DatabaseConnector()

extension Router {

  static func makeHistoricalEventRoutes() -> Routes {
    var routes = Routes()

    routes.add(method: .get, uri: uri, handler: { request, response in
      defer {
        response.completed()
      }
      do {
        let events = try! database.findAllEvents()
        let eventsEnvelope = HistoricalEvents.with {
          $0.events = events
        }
        response.setHeader(.contentType, value: "binary/protobuf")
        let data = try eventsEnvelope.serializedData()
        response.appendBody(bytes: [UInt8](data))
      } catch {
        response.status = .internalServerError
      }
    })

    return routes
  }

}

