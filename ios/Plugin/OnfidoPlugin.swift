//
//  Response.swift
//  Plugin
//
//  Created by Polo Swelsen on 28/03/2023.
//  Copyright © 2023 ilionx B.V. All rights reserved.
//

import Foundation
import Capacitor
import Onfido

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(OnfidoPlugin)
public class OnfidoPlugin: CAPPlugin {
    @objc func start(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard !call.options.isEmpty else {
                call.reject("No arguments provided")
                return
            }
            
            guard call.options["sdkToken"] is String else {
                call.reject("sdkToken must be provided")
                return
            }
    
            do {
                let onfidoFlow: OnfidoFlow = try buildOnfidoFlow(from: call)
                
                onfidoFlow
                    .with(responseHandler: { response in
                        switch response {
                        case let .error(error):
                            call.reject("\(error)", "Encountered an error running the flow", error)
                            return;
                        case let .success(results):
                            call.resolve(createResponse(results, faceVariant: nil))
                            return;
                        case let .cancel(reason):
                            switch (reason) {
                            case .deniedConsent:
                                call.reject("deniedConsent", "User denied consent.", nil)
                            case .userExit:
                                call.reject("userExit", "User canceled flow.", nil)
                            default:
                                call.reject("userExit", "User canceled flow via unknown method.", nil)
                            }
                            return;
                        default:
                            call.reject("error", "Unknown error has occured", nil)
                            return;
                        }
                    })
                
                
                // Ensure we have a valid UIViewController
                guard let viewController = self.bridge?.viewController else {
                    call.reject("Unable to access the view controller.")
                    return
                }

                try onfidoFlow.run(from: viewController, presentationStyle: .fullScreen, animated: true, completion: nil)
            } catch let error as NSError {
                call.reject("\(error)", error.domain, error)
                return;
            } catch let error {
                call.reject("\(error)", "Error running Onfido SDK", error)
                return;
            }
        }
    }
}

public func buildOnfidoFlow(from config: CAPPluginCall) throws -> OnfidoFlow {
    let appearanceFilePath = Bundle.main.path(forResource: "colors", ofType: "json")
    let appearance = try loadAppearanceFromFile(filePath: appearanceFilePath)
    let sdkToken = getSDKToken(from: config)
    
    if let workflowRunId = config.options["workflowRunId"] as? String {
        let enterpriseFeatures = EnterpriseFeatures.builder()
        
        if let hideLogo = config.options["hideLogo"] as? Bool {
            enterpriseFeatures.withHideOnfidoLogo(hideLogo)
        }
        
        if config.options["logoCobrand"] as? Bool == true {
            if let cobrandLogoLight = UIImage(named: "cobrand-logo-light"),
               let cobrandLogoDark = UIImage(named: "cobrand-logo-dark") {
                enterpriseFeatures.withCobrandingLogo(cobrandLogoLight, cobrandingLogoDarkMode: cobrandLogoDark)
            } else {
                throw NSError(domain: "Cobrand logos were not found", code: 0)
            }
        }
        
        let workflowConfig = WorkflowConfiguration(workflowRunId: workflowRunId, sdkToken: sdkToken)
        workflowConfig.withEnterpriseFeatures(enterpriseFeatures.build())
        workflowConfig.withAppearance(appearance)
        
        if let localisationFile = getLocalisationConfigFileName(from: config) {
            workflowConfig.withCustomLocalization(withTableName: localisationFile, in: Bundle.main)
        }
        
        return OnfidoFlow(workflowConfiguration: workflowConfig)
    } else {
        let onfidoConfig = try buildOnfidoConfig(config: config, appearance: appearance)
        let builtOnfidoConfig = try onfidoConfig.build()
        
        return OnfidoFlow(withConfiguration: builtOnfidoConfig)
    }
}

public func buildOnfidoConfig(config: CAPPluginCall, appearance: Appearance) throws -> Onfido.OnfidoConfigBuilder {
    let sdkToken: String = getSDKToken(from: config)
    let flowSteps = config.options["flowSteps"] as! JSObject
    let captureDocument = flowSteps["captureDocument"] as? JSObject
    let captureFace = flowSteps["captureFace"] as? JSObject
    
    var onfidoConfig = OnfidoConfig.builder()
        .withSDKToken(sdkToken)
        .withAppearance(appearance)
    
    let enterpriseFeatures = EnterpriseFeatures.builder()
    
    if let localisationFile = getLocalisationConfigFileName(from: config) {
        onfidoConfig = onfidoConfig.withCustomLocalization(andTableName: localisationFile)
    }
    
    if flowSteps["welcome"] as? Bool == true {
        onfidoConfig = onfidoConfig.withWelcomeStep()
    }
    
    if let docType = captureDocument?["docType"] as? String, let countryCode = captureDocument?["countryCode"] as? String {
        switch docType {
        case "PASSPORT":
            onfidoConfig = onfidoConfig.withDocumentStep(type: .passport(config: PassportConfiguration()))
        case "DRIVING_LICENCE":
            onfidoConfig = onfidoConfig.withDocumentStep(type: .drivingLicence(config: DrivingLicenceConfiguration(country: countryCode)))
        case "NATIONAL_IDENTITY_CARD":
            onfidoConfig = onfidoConfig.withDocumentStep(type: .nationalIdentityCard(config: NationalIdentityConfiguration(country: countryCode)))
        case "RESIDENCE_PERMIT":
            onfidoConfig = onfidoConfig.withDocumentStep(type: .residencePermit(config: ResidencePermitConfiguration(country: countryCode)))
        case "VISA":
            onfidoConfig = onfidoConfig.withDocumentStep(type: .visa(config: VisaConfiguration(country: countryCode)))
        case "WORK_PERMIT":
            onfidoConfig = onfidoConfig.withDocumentStep(type: .workPermit(config: WorkPermitConfiguration(country: countryCode)))
        case "GENERIC":
            onfidoConfig = onfidoConfig.withDocumentStep(type: .generic(config: GenericDocumentConfiguration(country: countryCode)))
        default:
            throw NSError(domain: "Unsupported document type", code: 0)
        }
    } else if captureDocument != nil {
        onfidoConfig = onfidoConfig.withDocumentStep()
    }
    
    if let faceVariant = captureFace?["type"] as? String {
        if faceVariant == "VIDEO" {
            onfidoConfig = onfidoConfig.withFaceStep(ofVariant: .video(withConfiguration: VideoStepConfiguration(showIntroVideo: true, manualLivenessCapture: false)))
        } else if faceVariant == "PHOTO" {
            onfidoConfig = onfidoConfig.withFaceStep(ofVariant: .photo(withConfiguration: nil))
        } else if faceVariant == "MOTION" {
            onfidoConfig = onfidoConfig.withFaceStep(ofVariant: .motion(withConfiguration: nil))
        }
        else {
            throw NSError(domain: "Invalid or unsupported face variant", code: 0)
        }
    }
    
    if config.options["enableNFC"] as? Bool == true {
        onfidoConfig = onfidoConfig.withNFC(NFCConfiguration.optional)
    }
    
    if let hideLogo = config.options["hideLogo"] as? Bool {
        enterpriseFeatures.withHideOnfidoLogo(hideLogo)
    }
    
    if config.options["logoCobrand"] as? Bool == true {
        if (UIImage(named: "cobrand-logo-light") != nil && UIImage(named: "cobrand-logo-dark") != nil) {
            enterpriseFeatures.withCobrandingLogo(UIImage(named: "cobrand-logo-light")!, cobrandingLogoDarkMode: UIImage(named: "cobrand-logo-dark")!)
        } else {
            throw NSError(domain: "Cobrand logos were not found", code: 0)
        }
    }
    
    onfidoConfig.withEnterpriseFeatures(enterpriseFeatures.build())
    return onfidoConfig;
}


public func getSDKToken(from config: CAPPluginCall) -> String {
    return config.options["sdkToken"] as! String
}

public func loadAppearancePublicFromFile(filePath: String?) throws -> AppearancePublic? {

    do {
        let jsonResult:Any
        do {
            guard let path = filePath else { return nil }
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        } catch let e as NSError where e.code == NSFileNoSuchFileError || e.code == NSFileReadNoSuchFileError {
            jsonResult = Dictionary<String, AnyObject>()
        }
        if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
            let primaryColor: UIColor = (jsonResult["onfidoPrimaryColor"] == nil)
            ? UIColor.primaryColor : UIColor.from(hex: jsonResult["onfidoPrimaryColor"] as! String)
            let primaryTitleColor: UIColor = (jsonResult["onfidoPrimaryButtonTextColor"] == nil)
            ? UIColor.white : UIColor.from(hex: jsonResult["onfidoPrimaryButtonTextColor"] as! String)
            let primaryBackgroundPressedColor: UIColor = (jsonResult["onfidoPrimaryButtonColorPressed"] == nil)
            ? UIColor.primaryButtonColorPressed : UIColor.from(hex: jsonResult["onfidoPrimaryButtonColorPressed"] as! String)
            let supportDarkMode: Bool = (jsonResult["onfidoIosSupportDarkMode"] == nil)
            ? true : jsonResult["onfidoIosSupportDarkMode"] as! Bool


            let appearancePublic = AppearancePublic(
                primaryColor: primaryColor,
                primaryTitleColor: primaryTitleColor,
                primaryBackgroundPressedColor: primaryBackgroundPressedColor,
                supportDarkMode: supportDarkMode
            )
            return appearancePublic
        } else {
            return nil
        }
    } catch let error {
        throw NSError(domain: "There was an error setting colors for Appearance: \(error)", code: 0)
    }
}

public func loadAppearanceFromFile(filePath: String?) throws -> Appearance {
    let appearancePublic = try loadAppearancePublicFromFile(filePath: filePath)

    if let appearancePublic = appearancePublic {
        let appearance = Appearance()
        appearance.primaryColor = appearancePublic.primaryColor
        appearance.primaryTitleColor = appearancePublic.primaryTitleColor
        appearance.primaryBackgroundPressedColor = appearancePublic.primaryBackgroundPressedColor
        return appearance
    } else {
        return Appearance.default;
    }
}

public func getLocalisationConfigFileName(from config: CAPPluginCall) -> String? {
    guard let localisationConfig = config.options["localisation"] as? JSObject,
          let file = localisationConfig["ios_strings_file_name"] as? String
    else { return nil }
    
    return file
}

extension UIColor {

    static var primaryColor: UIColor {
        return decideColor(light: UIColor.from(hex: "#353FF4"), dark: UIColor.from(hex: "#3B43D8"))
    }

    static var primaryButtonColorPressed: UIColor {
        return decideColor(light: UIColor.from(hex: "#232AAD"), dark: UIColor.from(hex: "#5C6CFF"))
    }

    private static func decideColor(light: UIColor, dark: UIColor) -> UIColor {
#if XCODE11
        guard #available(iOS 13.0, *) else {
            return light
        }
        return UIColor { (collection) -> UIColor in
            return collection.userInterfaceStyle == .dark ? dark : light
        }
#else
        return light
#endif
    }

    static func from(hex: String) -> UIColor {

        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let redInt = Int(color >> 16) & mask
        let greenInt = Int(color >> 8) & mask
        let blueInt = Int(color) & mask

        let red = CGFloat(redInt) / 255.0
        let green = CGFloat(greenInt) / 255.0
        let blue = CGFloat(blueInt) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension Appearance {

    static let `default`: Appearance = {
        let appearance = Appearance()
        appearance.primaryColor = .primaryColor
        appearance.primaryTitleColor = .white
        appearance.primaryBackgroundPressedColor = .primaryButtonColorPressed
        return appearance
    }()
}

extension UIViewController {
    public func findTopMostController() -> UIViewController {
        var topController: UIViewController? = self
        while topController!.presentedViewController != nil {
            topController = topController!.presentedViewController!
        }
        return topController!
    }
}
