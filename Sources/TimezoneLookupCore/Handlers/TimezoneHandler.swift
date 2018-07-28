import Foundation

import PerfectHTTP
import SwiftyJSON


class TimezoneHandler {
    static func getTimezone(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        defer { response.completed() }

        do {
            guard let latParam = request.param(name: "lat") else {
                ErrorHandler.error(request, response, message: "lat must be specified")
                return                
            }
            guard let lonParam = request.param(name: "lon") else {
                ErrorHandler.error(request, response, message: "lon must be specified")
                return
            }

            guard let lat = Double(latParam) else {
                ErrorHandler.error(request, response, message: "lat must be a number")
                return
            }
            guard let lon = Double(lonParam) else {
                ErrorHandler.error(request, response, message: "lon must be a number")
                return
            }

            let timezoneInfo = try LocationToTimezoneInfo().from(latitude: lat, longitude: lon)

            let encodedData = try JSONEncoder().encode(timezoneInfo)
            response.setBody(string: String(data: encodedData, encoding: .utf8)!)
        } catch {
            ErrorHandler.error(request, response, error)
        }
   }
}
