import XCTest
@testable import StitchCore_iOS

class StitchTests: XCTestCase {

    override func setUp() {
        do {
            try Stitch.initialize()
            _ = try Stitch.initializeDefaultAppClient(
                withConfigBuilder: StitchAppClientConfigurationBuilder.init({
                    $0.clientAppId = "placeholder-app-id"
                }))
        } catch {
            XCTFail("Failed to initialize MongoDB Stitch iOS SDK: \(error.localizedDescription)")
        }
    }

    func testDataDirectoryInitialization() {
        var client: StitchAppClient!
        do {
            try client = Stitch.getDefaultAppClient()
        } catch {
            XCTFail("No default app client initialized")
        }

        guard let clientImpl = client as? StitchAppClientImpl else {
            XCTFail("App client is not a StitchAppClientImpl")
            return
        }

        // Check that the default data directory configured by the SDK exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: clientImpl.info.dataDirectory.path))
    }
}