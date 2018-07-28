import Foundation
import SwiftyJSON

class LocationToTimezoneInfo {

    enum Error : Swift.Error {
        case NoMatches
        case NoDataInResponse
        case MissingOrBadTimezones(String)
    }


    func from(latitude: Double, longitude: Double) throws -> TimezoneInfo {
        return try AzureTimezoneLookup().from(latitude: latitude, longitude: longitude)
    }

}
