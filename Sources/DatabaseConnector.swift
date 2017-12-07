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

  func findAllEvents() throws -> [Document] {
    let eventsCollection = myDatabase["historical_events"]
    let events = try eventsCollection.find()
    return events.map { $0 }
  }
  
}
