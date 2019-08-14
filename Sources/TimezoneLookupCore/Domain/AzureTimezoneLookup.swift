import Foundation
import SwiftyJSON


class AzureTimezoneLookup {
    let cache = ElasticSearchGeoCache()
    let elasticIndexName = "azure_timezone_lookup"

    func from(latitude: Double, longitude: Double) throws -> TimezoneInfo {
        var response: JSON?

        do {
            response = try fromCache(latitude, longitude)
        } catch LocationToTimezoneInfo.Error.NoMatches {
            // The cache doesn't have this entry, no value in logging that info
        }  catch {
Logger.log("cache exception: \(error)")
        }

        // Not in the cache, get it from the source
        if response == nil {
            do {
                Logger.log("Getting location from source: \(latitude),\(longitude))")
                response = try fromSource(latitude, longitude)
            } catch {
Logger.log("fromSource exception: \(error)")
            }

            if response != nil {
                // This can be done asynchronously - it'll shave off a bit of request time/duration
                do {
                    try saveToCache(latitude, longitude, response!)
                } catch {
                    Logger.log("Caching of \(latitude), \(longitude) failed: \(error)")
                }
            }
        }

        guard let json = response else {
            throw LocationToTimezoneInfo.Error.NoDataInResponse
        }

        return try toTimezoneInfo(latitude, longitude, json)
    }

    func fromCache(_ latitude: Double, _ longitude: Double) throws -> JSON? {
        return try cache.resolve(elasticIndexName, latitude, longitude, 3)
    }

    func fromSource(_ latitude: Double, _ longitude: Double) throws -> JSON? {
        return try AzureTimezoneLookupProvider().lookup(latitude, longitude, maxDistanceInMeters: 3)
    }

    func saveToCache(_ latitude: Double, _ longitude: Double, _ json: JSON) throws {
        try cache.cache(elasticIndexName, latitude, longitude, json)
    }

    func toTimezoneInfo(_ latitude: Double, _ longitude: Double, _ json: JSON) throws -> TimezoneInfo {
        let jsonTimezones = json["TimeZones"]
        if !jsonTimezones.exists() || jsonTimezones.count == 0 {
            throw LocationToTimezoneInfo.Error.MissingOrBadTimezones("\(json)")            
        }

        let jsonReferenceTime = jsonTimezones[0]["ReferenceTime"]

        let id = jsonTimezones[0]["Id"].stringValue
        let tag = jsonReferenceTime["Tag"].stringValue
        let daylightSavingsString = jsonReferenceTime["DaylightSavings"].stringValue
        var standardOffsetString = jsonReferenceTime["StandardOffset"].stringValue
        let firstChar = String(standardOffsetString[standardOffsetString.startIndex...standardOffsetString.startIndex])
        let standardOffsetIsNegative = firstChar == "-"
        if standardOffsetIsNegative {
            standardOffsetString.removeFirst()
        }

        let intervalFormatter = DateFormatter()
        intervalFormatter.dateFormat = "HH:mm:ss"
        intervalFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        // The reference date is Jan 1, 2001 while the returned date for these strings, which don't 
        // have dates, is Jan 1, 2000. The one year is added to get proper offsets - and that one 
        // year is a leap year, hence 366 rather than 365.
        let secondsIn2000 = 366 * 24 * 60 * 60.0
        var standardOffsetSeconds = Int(intervalFormatter.date(from: standardOffsetString)!.timeIntervalSinceReferenceDate + secondsIn2000)
        if standardOffsetIsNegative {
            standardOffsetSeconds = standardOffsetSeconds * -1
        }
        let daylightSavingSeconds = Int(intervalFormatter.date(from: daylightSavingsString)!.timeIntervalSinceReferenceDate + secondsIn2000)

        return TimezoneInfo(
            id: id,
            tag: tag,
            standardOffsetSeconds: standardOffsetSeconds,
            daylightSavingSeconds: daylightSavingSeconds)
    }
}