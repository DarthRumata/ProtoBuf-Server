//
//  ProtoTests.swift
//  ProtoTests
//
//  Created by Rumata on 12/7/17.
//
//

import XCTest
import PerfectHTTP
import PerfectLib
import MongoKitten
@testable import ServerCore

private let database = DatabaseConnector()
private var documents: [Document]!

class ProtoTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    documents = try! database.findAllEvents()
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testPerformanceJSON() {
    // This is an example of a performance test case.
    self.measure {
      let events = documents.map { stored -> HistoricalEventJSON in
        let dict = stored.dictionaryRepresentation
        let event = HistoricalEventJSON()
        event.id = (dict["_id"] as! BSON.ObjectId).hexString
        event.name = dict["name"] as! String
        event.description = (dict["description"] as? String) ?? ""
        event.date = (dict["date"] as! Date)
        event.verified = dict["verified"] as? Bool ?? false
        if let battleDict = (dict["battle"] as? Document)?.dictionaryRepresentation {
          let battle = BattleJSON()
          battle.duration = Int(battleDict["duration"] as! Int32)
          let forces = (battleDict["forces"] as! Document).arrayRepresentation
          battle.forces = forces.map {
            let forceDict = ($0 as! Document).dictionaryRepresentation
            let force = BattleJSON.Force()
            force.name = forceDict["name"] as! String
            force.quantity = Int(forceDict["quantity"] as! Int32)
            force.casualities = Int(forceDict["casualties"] as! Int32)
            return force
          }
          event.battle = battle
        }
        event.sources = (dict["sources"] as? Document)?.arrayRepresentation as? [String] ?? []

        return event
      }

      XCTAssert(events.count > 0)
    }
  }

  func testPerformanceProto() {
    self.measure {
      let events = documents.map { stored in
        return HistoricalEvent.with { event in
          let dict = stored.dictionaryRepresentation
          event.id = (dict["_id"] as! BSON.ObjectId).hexString
          event.name = dict["name"] as! String
          event.description_p = (dict["description"] as? String) ?? ""
          event.date = Int64((dict["date"] as! Date).timeIntervalSince1970)
          event.verified = dict["verified"] as? Bool ?? false
          if let battleDict = (dict["battle"] as? Document)?.dictionaryRepresentation {
            event.battle = Battle.with { (battle) in
              battle.duration = UInt32(battleDict["duration"] as! Int32)
              let forces = (battleDict["forces"] as! Document).arrayRepresentation
              battle.forces = forces.map { forceDoc in
                let forceDict = (forceDoc as! Document).dictionaryRepresentation
                return Battle.Force.with { force in
                  force.name = forceDict["name"] as! String
                  force.quantity = Int64(forceDict["quantity"] as! Int32)
                  force.casualties = Int64(forceDict["casualties"] as! Int32)
                }
              }
            }
          }
          event.sources = (dict["sources"] as? Document)?.arrayRepresentation as? [String] ?? []
        }
      }

      let eventsEnvelope = HistoricalEvents.with {
        $0.events = events
      }

      XCTAssert(eventsEnvelope.events.count > 0)
    }
  }

}
