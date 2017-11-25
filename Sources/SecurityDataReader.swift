//
//  SecurityDataReader.swift
//  GraphQL-Server
//
//  Created by Rumata on 11/14/17.
//
//

import Foundation

struct SecurityDataReader {
  
  let mongoHost: String
  let databaseName: String
  
  init?() {
    let path = "/Users/rumata/Develop/Projects/Education/GraphQL-Server/Security.plist"
    guard
      let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else
    {
        return nil
    }
    
    mongoHost = dict["mongo_host"] as! String
    databaseName = dict["database"] as! String
  }
  
}
