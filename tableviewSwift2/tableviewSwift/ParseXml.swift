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
    var parentPort: String
    var groupLabel : String
    var hasOutput : Bool
    var outputState : Bool
    var hasOccupany : Bool
    var occupiedState : Bool
}

class ParseXml: NSObject, XMLParserDelegate
{
    private var myData: Data
    private var currentElementName = ""
    private var inItemDevice = false
    private var inItemGroup = false
    private var item: DevXml
    
    var ready = false
    
    var header: DevXml
    var items: [DevXml]
    
    
    override init()
    {
        myData = "".data(using: .ascii)!
        header = DevXml(deviceID: "", model: "", label: "", parentPort: "", groupLabel: "", hasOutput: false, outputState: false, hasOccupany: false, occupiedState: false)
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
            inItemDevice = false
            items.append(item)
        }
        else if elementName == "Group"
        {
            inItemGroup = false
            items.append(item)
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:])
    {
        currentElementName = elementName
        if elementName == "Device"
        {
            inItemDevice = true
            item = DevXml(deviceID: attributeDict["ID"] ?? "", model: attributeDict["Model"] ?? "", label: "", parentPort: "", groupLabel: "", hasOutput: false, outputState: false, hasOccupany: false, occupiedState: false)
        }
        else if elementName == "Group"
        {
            inItemGroup = true
            item = DevXml(deviceID: "", model: "", label: "", parentPort: (attributeDict["ID"] ?? "") + ":" + (attributeDict["Port"] ?? ""), groupLabel: "", hasOutput: false, outputState: false, hasOccupany: false, occupiedState: false)
        }
        
        if elementName == "Parent"
        {
            item.parentPort = (attributeDict["ID"] ?? "") + ":" + (attributeDict["Port"] ?? "")
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data)
    {
        if !inItemDevice
        {
            return
        }
        
        switch currentElementName.lowercased()
        {
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        if !inItemDevice && !inItemGroup
        {
            return
        }
        
        switch currentElementName.lowercased()
        {
        case "label":
            if inItemDevice == true
            {
                item.label += string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
            else if inItemGroup == true
            {
                item.groupLabel += string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
            break
        default:
            break
        }
        
    }
}
