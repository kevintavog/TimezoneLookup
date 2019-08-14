import Foundation
import SwiftyJSON


class AzureTimezoneLookupProvider {
    let baseAddress = "https://atlas.microsoft.com/timezone/byCoordinates/json?subscription-key=%1$s&api-version=1.0&query=%2$lf,%3$lf"

    func lookup(_ latitude: Double, _ longitude: Double, maxDistanceInMeters: Int) throws -> JSON? {
        var url = ""
        Config.azureApiKey.withCString {
            url = String(format: baseAddress, $0, latitude, longitude)
        }


print("source url: \(url)")
        guard let data = try synchronousHttpGet(url) else {
            throw LocationToTimezoneInfo.Error.NoDataInResponse
        }

        return try JSON(data: data)
    }
}