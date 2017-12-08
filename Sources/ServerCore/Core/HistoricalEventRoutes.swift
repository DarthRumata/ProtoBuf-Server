//
//  HistoricalEventRoutes.swift
//  ProtoBuf-Server
//
//  Created by Rumata on 11/25/17.
//
//

import Foundation
import PerfectHTTP
import PerfectLib
import MongoKitten

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
        let events = try! database.findAllEvents().map { stored in
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
        response.setHeader(.contentType, value: "binary/protobuf")
        let data = try eventsEnvelope.serializedData()
        response.appendBody(bytes: [UInt8](data))
      } catch {
        response.status = .internalServerError
      }
    })

    return routes
  }

  static func makeHistoricalEventJSONRoutes() -> Routes {
    var routes = Routes()
    JSONDecoding.registerJSONDecodable(name: HistoricalEventJSON.registerName, creator: { return HistoricalEventJSON() })

    routes.add(method: .get, uri: uri + "/json", handler: { request, response in
      defer {
        response.completed()
      }
      do {
        let events = try! database.findAllEvents().map { stored -> HistoricalEventJSON in
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


        response.setHeader(.contentType, value: "application/json")
        let data = try JSONSerialization.data(withJSONObject: events.map { $0.getJSONValues() }, options: [])
        let jsonString = String(data: data, encoding: .utf8)!
        response.appendBody(string: jsonString)
      } catch {
        response.status = .internalServerError
      }
    })

    return routes
  }

}

