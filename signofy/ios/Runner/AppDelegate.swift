import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Configurar apariencia de la barra de estado: iconos claros (fondo oscuro)
        UINavigationBar.appearance().barStyle = .black
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Para notificaciones locales (rachas diarias — v0.2)
    override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        completionHandler(.noData)
    }
}
