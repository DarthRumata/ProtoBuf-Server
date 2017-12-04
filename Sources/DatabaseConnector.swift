//
//  DatabaseConnector.swift
//  ProtoBuf-Server
//
//  Created by Rumata on 12/4/17.
//
//

import Foundation
import MongoKitten

private let security = SecurityDataReader()!

struct DatabaseConnector {

  private let myDatabase: Database

  init() {
    let server = try! Server("mongodb://\(security.mongoHost)")
    myDatabase = server[security.databaseName]

  }

  func findAllEvents() throws -> [HistoricalEvent] {
    let eventsCollection = myDatabase["historical_events"]
    let events = try eventsCollection.find()
    return events.map { stored in
      return HistoricalEvent.with { event in
        let dict = stored.dictionaryRepresentation
        event.id = (dict["_id"] as! BSON.ObjectId).hexString
        event.name = dict["name"] as! String
        event.description_p = (dict["description"] as? String) ?? ""
        event.date = Int64((dict["date"] as! Date).timeIntervalSince1970)
      }
    }
  }
  
}
