//
//  RelayPostRow.swift
//  Light
//
//  Created by Philip Gross on 1/11/21.
//

import SwiftUI

struct RelayPostRow: View {
    var relayPost: RelayPost
    
    var body: some View {
        HStack {
        if (relayPost.relaystate ?? true) {
            Image(systemName: "lightbulb.fill").foregroundColor(.yellow)
        }
        else {
            Image(systemName: "lightbulb.slash")
        }
            Text(convertTimestamp(timestamp: relayPost.ts ?? "20210111T18:08:08"))
            
        }
    }
}

struct RelayPostRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            RelayPostRow(relayPost: RelayPost(id: 1, relaystate: false, ts: "20210111T18:06:52"))
            RelayPostRow(relayPost: RelayPost(id: 2, relaystate: true, ts: "20210111T18:08:08"))
        }
    }
}

func convertTimestamp(timestamp: String) -> String {
    let string = timestamp

    let dateFormatter = DateFormatter()
    let tempLocale = dateFormatter.locale // save locale temporarily
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyyMMdd'T'HH:mm:ss"
    let date = dateFormatter.date(from: string)
    //print("date=", date)
    dateFormatter.dateFormat = "E MM-dd-yyyy, hh:mm:ss a"
    dateFormatter.locale = tempLocale // reset the locale
    let dateString = dateFormatter.string(from: date!)
    return dateString
}
