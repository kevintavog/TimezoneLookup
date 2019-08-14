import Foundation
import TimezoneLookupCore

#if os(OSX)
func fullLocationFilenameURL() -> URL {
    return FileManager.default.urls(
        for: .libraryDirectory, 
        in: .userDomainMask)[0].appendingPathComponent("Preferences").appendingPathComponent("rangic.TimezoneLookup.config")
}
#elseif os(Linux)
func fullLocationFilenameURL() -> URL {
    return URL(fileURLWithPath: "/etc/TimezoneLookup.config")
}
#endif


Config.filename = fullLocationFilenameURL()
print("Loading configuration from: \(String(describing: Config.filename?.path))")

TimezoneLookupServer().start()
