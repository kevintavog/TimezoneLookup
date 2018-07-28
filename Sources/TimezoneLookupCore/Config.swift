import Foundation
import SwiftyJSON

public class Config
{
    static private var _filename: URL? = nil
    private let _azureApiKey: String
    private let _elasticSearchUrl: String

    public static var filename: URL? {
        set(newValue) {
            _filename = newValue
        }
        get {
            return _filename
        }
    }

    public static var sharedInstance: Config
    {
        struct _Singleton {
            static let instance = Config(Config._filename)
        }
        return _Singleton.instance
    }

    private init(_ filenameURL: URL?) {
        var azureApiKey = "azure_api_key"
        var eUrl = "elastic_url"

        if filenameURL == nil {
            Logger.log("Config.filename not set, unable to start service")
            _azureApiKey = ""
            _elasticSearchUrl = ""
        } else {

            var loadedFile = false
            if let data = try? Data(contentsOf: filenameURL!) {
                loadedFile = true
                if let json = try? JSON(data:data) {
                    azureApiKey = json["azure_api_key"].stringValue
                    eUrl = json["elasticSearchUrl"].stringValue
                }
            }

            _azureApiKey = azureApiKey
            _elasticSearchUrl = eUrl
            if !loadedFile {
                self.save(filenameURL!)
            }
        }
    }

    private func save(_ filenameURL: URL) {
        do {
            var json = JSON()
            json["azure_api_key"].string = _azureApiKey
            json["elasticSearchUrl"].string = _elasticSearchUrl
            let jsonString: String = json.rawString()!
            try jsonString.write(to: filenameURL, atomically: false, encoding: String.Encoding.utf8)
        } catch let error {
            Logger.log("Unable to save locations: \(error)")
        }
    }


    public static var azureApiKey: String {
        get { return Config.sharedInstance._azureApiKey }
    }

    public static var elasticSearchUrl: String {
        get { return Config.sharedInstance._elasticSearchUrl }
    }
}
