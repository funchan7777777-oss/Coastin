import Flutter
import AVFoundation
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var shareChannel: FlutterMethodChannel?
  private var callPermissionChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CoastinShare") else {
      return
    }
    shareChannel = FlutterMethodChannel(
      name: "coastin/share",
      binaryMessenger: registrar.messenger()
    )
    callPermissionChannel = FlutterMethodChannel(
      name: "coastin/shore_call_permissions",
      binaryMessenger: registrar.messenger()
    )
    shareChannel?.setMethodCallHandler { [weak self] call, result in
      guard call.method == "shareText" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let arguments = call.arguments as? [String: Any],
        let text = arguments["text"] as? String,
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      else {
        result(
          FlutterError(
            code: "BAD_SHARE_TEXT",
            message: "A non-empty text value is required.",
            details: nil
          )
        )
        return
      }
      self?.presentShareSheet(text: text, result: result)
    }
    callPermissionChannel?.setMethodCallHandler { [weak self] call, result in
      guard call.method == "requestCallAccess" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let self else {
        result(
          FlutterError(
            code: "CALL_PERMISSION_BRIDGE_UNAVAILABLE",
            message: "Coastin could not open the video call permission bridge.",
            details: nil
          )
        )
        return
      }
      self.requestCallAccess(result: result)
    }
  }

  private func requestCallAccess(result: @escaping FlutterResult) {
    requestCaptureAccess(for: .video) { cameraAllowed in
      self.requestCaptureAccess(for: .audio) { microphoneAllowed in
        DispatchQueue.main.async {
          result([
            "camera": cameraAllowed,
            "microphone": microphoneAllowed,
          ])
        }
      }
    }
  }

  private func requestCaptureAccess(
    for mediaType: AVMediaType,
    completion: @escaping (Bool) -> Void
  ) {
    switch AVCaptureDevice.authorizationStatus(for: mediaType) {
    case .authorized:
      completion(true)
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: mediaType) { allowed in
        completion(allowed)
      }
    case .denied, .restricted:
      completion(false)
    @unknown default:
      completion(false)
    }
  }

  private func presentShareSheet(text: String, result: @escaping FlutterResult) {
    DispatchQueue.main.async { [weak self] in
      guard let presenter = self?.activeTopViewController() else {
        result(
          FlutterError(
            code: "NO_PRESENTING_CONTROLLER",
            message: "Coastin could not find a visible screen for sharing.",
            details: nil
          )
        )
        return
      }
      let shareSheet = UIActivityViewController(
        activityItems: [text],
        applicationActivities: nil
      )
      if let popover = shareSheet.popoverPresentationController {
        popover.sourceView = presenter.view
        popover.sourceRect = CGRect(
          x: presenter.view.bounds.midX,
          y: presenter.view.bounds.midY,
          width: 1,
          height: 1
        )
        popover.permittedArrowDirections = []
      }
      shareSheet.completionWithItemsHandler = { _, completed, _, error in
        if let error = error {
          result(
            FlutterError(
              code: "SHARE_FAILED",
              message: error.localizedDescription,
              details: nil
            )
          )
          return
        }
        result(completed)
      }
      presenter.present(shareSheet, animated: true)
    }
  }

  private func activeTopViewController() -> UIViewController? {
    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first { $0.isKeyWindow }
    var controller = keyWindow?.rootViewController ?? window?.rootViewController
    while let presented = controller?.presentedViewController {
      controller = presented
    }
    if let navigationController = controller as? UINavigationController {
      controller = navigationController.visibleViewController
    }
    if let tabController = controller as? UITabBarController {
      controller = tabController.selectedViewController
    }
    return controller
  }
}
