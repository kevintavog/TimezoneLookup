import PerfectHTTP

class ErrorHandler {

	static func error(_ request: HTTPRequest, _ response: HTTPResponse, _ error: Error) {
        ErrorHandler.error(request, response, message: "\(error)")
    }

	static func error(_ request: HTTPRequest, _ response: HTTPResponse, message: String, code: HTTPResponseStatus = .badRequest) {
		do {
			response.status = code
			request.scratchPad[RangicLoggerFilter.serviceErrorMessageKey] = message
			try response.setBody(json: ["error": "\(message)"])
		} catch {
			Logger.log("\(error)")
		}
		response.completed()
	}
}
