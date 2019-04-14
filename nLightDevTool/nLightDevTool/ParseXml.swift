//
//  ParseXml.swift
//  nLightDevTool
//
//  Created by Philip Gross on 4/13/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import Foundation

struct DevXml
{
    var deviceID: String
    var model: String
    var label: String
    var parent: String
    var port: String
}

class ParseXml: NSObject, XMLParserDelegate
{
    private var myData: Data
    private var currentElementName = ""
    private var inItem = false
    private var item: DevXml
    
    var ready = false
    
    var header: DevXml
    var items: [DevXml]
    
    
    override init()
    {
        myData = "".data(using: .ascii)!
        header = DevXml(deviceID: "", model: "", label: "", parent: "", port: "")
        items = []
        item = header
    }
    
    func setData(data: Data!) -> Void
    {
        if data == nil
        {
            return
        }
        
        myData = data
    }
    
    func parse() -> Void
    {
        let parser = XMLParser(data: myData)
        parser.delegate = self
        parser.parse()
    }
    
    // -----------------------
    
    func parserDidEndDocument(_ parser: XMLParser)
    {
        ready = true
    }
    
    func parserDidStartDocument(_ parser: XMLParser)
    {
        ready = false
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        currentElementName = elementName
        if elementName == "Device"
        {
            inItem = false
            items.append(item)
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:])
    {
        currentElementName = elementName
        if elementName == "Device"
        {
            inItem = true
            item = DevXml(deviceID: "", model: "", label: "", parent: "", port: "")
        }
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data)
    {
        if !inItem
        {
            return
        }
        
        let s = String(data: CDATABlock, encoding: .utf8)!
        
        switch currentElementName.lowercased()
        {
        case "id":
            item.deviceID = s
            break
        case "model":
            item.model = s
            break
        case "parent":
            item.parent = s
            break
        case "label":
            item.label = s
            break
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        if !inItem
        {
            return
        }
        
        switch currentElementName.lowercased()
        {
        case "id":
            item.deviceID += string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            break
        case "parent":
            item.parent += string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            break
        case "label":
            item.label += string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            break
        case "model":
            item.model += string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            break
        default:
            break
        }
        
    }
}
