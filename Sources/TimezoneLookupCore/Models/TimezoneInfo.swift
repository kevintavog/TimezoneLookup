import Foundation

struct TimezoneInfo : Encodable {
    let id: String
    let tag: String
    let standardOffsetSeconds: Int
    let daylightSavingSeconds: Int

    public init(id: String, tag: String, standardOffsetSeconds: Int, daylightSavingSeconds: Int) {
        self.id = id
        self.tag = tag
        self.standardOffsetSeconds = standardOffsetSeconds
        self.daylightSavingSeconds = daylightSavingSeconds
    }
}
