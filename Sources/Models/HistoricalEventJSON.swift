//
//  HistoricalEventJSON.swift
//  ProtoBuf-Server
//
//  Created by Rumata on 12/6/17.
//
//

import Foundation
import PerfectLib

class HistoricalEventJSON: JSONConvertibleObject {
  static let registerName = "historical_event"

  var id = ""
  var name = ""
  var date = Date()
  var description = ""
  var verified = false
  var battle: BattleJSON?
  var sources = [String]()

  override func setJSONValues(_ values: [String: Any]) {
    id = getJSONValue(named: "id", from: values, defaultValue: "")
    name = getJSONValue(named: "name", from: values, defaultValue: "")
    description = getJSONValue(named: "description", from: values, defaultValue: "")
    date = Date(timeIntervalSince1970: TimeInterval(getJSONValue(named: "date", from: values, defaultValue: 0) as Int64))
  }

  override func getJSONValues() -> [String : Any] {
    return [
      JSONDecoding.objectIdentifierKey: HistoricalEventJSON.registerName,
      "id": id,
      "name": name,
      "date": date.timeIntervalSince1970,
      "description": description,
      "verified": verified,
      "battle": battle?.getJSONValues() as Any,
      "sources": sources
    ]
  }
}

class BattleJSON: JSONConvertibleObject {
  static let registerName = "battle"

  class Force: JSONConvertibleObject {
    static let registerName = "force"

    var name = ""
    var quantity = 0
    var casualities = 0

    override func getJSONValues() -> [String : Any] {
      return [
        JSONDecoding.objectIdentifierKey: Force.registerName,
        "name": name,
        "quantity": quantity,
        "casualities": casualities
      ]
    }
  }

  var duration = 0
  var forces = [Force]()

  override func getJSONValues() -> [String : Any] {
    return [
      JSONDecoding.objectIdentifierKey: BattleJSON.registerName,
      "duration": duration,
      "forces": forces.map { $0.getJSONValues() }
    ]
  }

}


