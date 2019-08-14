import PerfectLib
import PerfectHTTP
import PerfectHTTPServer


public class TimezoneLookupServer {
    public init() { }

    public func start() {
        let server = HTTPServer()
        server.serverPort = 8889

        var routes = Routes()
        routes.add(method: .get, uri: "/api/v1/timezone", handler: TimezoneHandler.getTimezone)
        routes.add(method: .get, uri: "/status", handler: statusHandler)
        server.addRoutes(routes)

        let logger = RangicLoggerFilter()
        server.setRequestFilters([(logger, .high)])
        server.setResponseFilters([(logger, .low)])

        do {
            Logger.log("Using ElasticSearch host: \(Config.elasticSearchUrl)")
            try server.start()
        } catch {
            fatalError("\(error)")
        }
    }
}