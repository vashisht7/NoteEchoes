import Flutter
import UIKit
import AppIntents
import PDFKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [
            UIApplication.LaunchOptionsKey: Any
        ]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if let pdfRegistrar = registrar(forPlugin: "NoteEchoesPDFKitView") {
            pdfRegistrar.register(
                NoteEchoesPDFViewFactory(),
                withId: "noteechoes/pdf_view"
            )
        }

        if #available(iOS 16.0, *) {
            NotechoesShortcuts.updateAppShortcutParameters()
        }

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
}

private final class NoteEchoesPDFViewFactory: NSObject,
    FlutterPlatformViewFactory {
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        NoteEchoesPDFPlatformView(frame: frame, arguments: args)
    }
}

private final class NoteEchoesPDFPlatformView: NSObject, FlutterPlatformView {
    private let pdfView: PDFView

    init(frame: CGRect, arguments: Any?) {
        pdfView = PDFView(frame: frame)
        super.init()

        pdfView.backgroundColor = UIColor(
            red: 8.0 / 255.0,
            green: 8.0 / 255.0,
            blue: 8.0 / 255.0,
            alpha: 1
        )
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.displaysPageBreaks = true
        pdfView.pageBreakMargins = UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 10
        )
        pdfView.usePageViewController(false)

        if let values = arguments as? [String: Any],
           let path = values["path"] as? String,
           let document = PDFDocument(url: URL(fileURLWithPath: path)) {
            pdfView.document = document
            pdfView.autoScales = true
            DispatchQueue.main.async { [weak pdfView] in
                guard let pdfView else { return }
                pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
                pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
            }
        }
    }

    func view() -> UIView { pdfView }
}
