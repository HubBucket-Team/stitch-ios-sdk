import Foundation
import ExtendedJson

let PrefConfigs: String = "apns.configs"

internal enum DeviceFields: String {
    case ServiceName = "service"
    case Data = "data"
    case RegistrationToken = "registrationToken"
    case DeviceId = "deviceId"
    case AppId = "appId"
    case AppVersion = "appVersion"
    case Platform = "platform"
    case PlatformVersion = "platformVersion"
}

internal enum Actions: String {
    case RegisterPush = "registerPush"
    case DeregisterPush = "deregisterPush"
}

/**
    A PushClient is responsible for allowing users to register and deregister for push notifications sent from Stitch or directly from the provider.
 */
public protocol PushClient {
    /**
        Registers the client with the provider and Stitch
 
        - returns: A task that can be resolved upon registering
    */
    @discardableResult
    func registerToken(token: String) -> StitchTask<Any>
    
    /**
        Deregisters the client from the provider and Stitch.
        
        - returns: A task that can be resolved upon deregistering
    */
    @discardableResult
    func deregister() -> StitchTask<Any>
}

extension PushClient {
    /**
     - parameter info: The push provider info to persist.
     */
    func addInfoToConfigs(info: PushProviderInfo) {
        let userDefaults = UserDefaults(suiteName: Consts.UserDefaultsName)!
        
        var configs: [String : Any] = userDefaults.value(forKey: PrefConfigs) as? [String : Any] ?? [String : Any]()
        
        configs[info.serviceName] = info.toDict()
        
        userDefaults.setValue(configs, forKey: PrefConfigs)
    }
    
    /**
     - parameter info: The push provider info to no longer persist
     */
    public func removeInfoFromConfigs(info: PushProviderInfo) {
        let userDefaults = UserDefaults(suiteName: Consts.UserDefaultsName)!

        var configs = BsonDocument()
        do {
            let configOpt = userDefaults.value(forKey: PrefConfigs)
            
            if let config = configOpt {
                configs = try BsonDocument(extendedJson: config as! [String : Any])
            }
        } catch _ {
            configs = BsonDocument()
        }
        
        configs[info.serviceName] = nil
        userDefaults.setValue(configs, forKey: PrefConfigs)
    }
    
    /**
     - parameter serviceName: The service that will handle push
     for this client
     - returns: A generic device registration request
     */
    public func getBaseRegisterPushRequest(serviceName: String) -> [String : ExtendedJsonRepresentable] {
        var request = [String : ExtendedJsonRepresentable]()
        
        request[DeviceFields.ServiceName.rawValue] = serviceName
        request[DeviceFields.Data.rawValue] = BsonDocument()

        return request
    }
    
    /**
     - parameter serviceName: The service that will handle push
     for this client
     - returns: A generic device deregistration request
     */
    func getBaseDeregisterPushDeviceRequest(serviceName: String) -> BsonDocument {
        var request = BsonDocument()
        
        request[DeviceFields.ServiceName.rawValue] = serviceName
        
        return request
    }
}
