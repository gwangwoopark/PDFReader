import PDFKit
import PencilKit
import UIKit

let MAX_SCALE = 5.0
let MIN_SCALE = 0.5

class ViewController: UIViewController {
    var pdfView: PDFView!
    var overlayProvider: Coordinator!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openDocument()
    }

    private func setupView() {
        pdfView = PDFView(frame: .zero)
        pdfView.maxScaleFactor = MAX_SCALE
        pdfView.minScaleFactor = MIN_SCALE
        pdfView.isInMarkupMode = true

        view.addSubview(pdfView)

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: view.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func openDocument() {
        overlayProvider = Coordinator()
        pdfView.pageOverlayViewProvider = overlayProvider

        guard let documentURL = Bundle.main.url(forResource: "1706.03762v7", withExtension: "pdf") else {
            print("Failed to find document.")
            return
        }
        pdfView.document = PDFDocument(url: documentURL)
    }
}

class Coordinator: NSObject, PDFPageOverlayViewProvider {
    var pageToViewMapping = [PDFPage: PKCanvasView]()

    func pdfView(_ view: PDFView, overlayViewFor page: PDFPage) -> UIView? {
        var resultView: PKCanvasView? = nil

        if let overlayView = pageToViewMapping[page] {
            resultView = overlayView
        } else {
            let canvasView = PKCanvasView(frame: .zero)
            canvasView.drawingPolicy = .pencilOnly
            canvasView.tool = PKInkingTool(.pen, color: .black, width: 1)
            canvasView.isOpaque = false
            canvasView.backgroundColor = .clear
            canvasView.becomeFirstResponder()

            pageToViewMapping[page] = canvasView
            resultView = canvasView
        }

        // If we have stored a drawing on the page, set it on the canvas
        if let myPage = page as? MyPDFPage, let drawing = myPage.drawing {
            resultView?.drawing = drawing
        }

        return resultView
    }

    func pdfView(
        _ pdfView: PDFView,
        willDisplayOverlayView overlayView: UIView,
        for page: PDFPage
    ) {}

    func pdfView(_ pdfView: PDFView, willEndDisplayingOverlayView overlayView: UIView,
                 for page: PDFPage)
    {
        let overlayView = overlayView as! PKCanvasView
        if let page = page as? MyPDFPage {
            page.drawing = overlayView.drawing
            pageToViewMapping.removeValue(forKey: page)
        }
    }
}

class MyPDFPage: PDFPage {
    var drawing: PKDrawing?
}

// import PDFKit
// import PencilKit
// import UIKit
//
// let MAX_SCALE = 5.0
// let MIN_SCALE = 0.5
//
// class ViewController: UIViewController {
//    var pdfView: PDFView!
//    var overlayProvider: Coordinator!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupView()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        openDocument()
//        if let scrollView = pdfView.subviews.compactMap({ $0 as? UIScrollView }).first {
//            scrollView.delegate = self
//            scrollView.bounces = false
//            scrollView.bouncesZoom = false
//        }
//    }
//
//    private func setupView() {
//        pdfView = PDFView(frame: .zero)
//        pdfView.translatesAutoresizingMaskIntoConstraints = false
//        pdfView.maxScaleFactor = MAX_SCALE
//        pdfView.minScaleFactor = MIN_SCALE
//        pdfView.isInMarkupMode = true
//
//        view.addSubview(pdfView)
//
//        NSLayoutConstraint.activate([
//            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            pdfView.topAnchor.constraint(equalTo: view.topAnchor),
//            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//
//    private func openDocument() {
//        overlayProvider = Coordinator(pdfView: pdfView)
//        pdfView.pageOverlayViewProvider = overlayProvider
//
//        guard let documentURL = Bundle.main.url(forResource: "PSPDFKit 9 QuickStart Guide", withExtension: "pdf") else {
//            print("Failed to find document.")
//            return
//        }
//        pdfView.document = PDFDocument(url: documentURL)
//    }
// }
//
// extension ViewController: UIScrollViewDelegate {
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        let view = scrollView.subviews.first
//        return view
//    }
//
//    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {}
//
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        print("pdfViewDidZoom")
//        overlayProvider.updateCanvasViewScales(pdfView: pdfView, scrollView: scrollView, with: scrollView.zoomScale)
//    }
//
//    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {}
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("pdfViewDidScroll")
//    }
// }
//
// class Coordinator: NSObject, PDFPageOverlayViewProvider {
//    var pageToViewMapping = [PDFPage: PKCanvasView]()
//    var pdfView: PDFView
//
//    init(pdfView: PDFView) {
//        self.pdfView = pdfView
//    }
//
//    func pdfView(_ view: PDFView, overlayViewFor page: PDFPage) -> UIView? {
//        var resultView: PKCanvasView? = nil
//
//        if let overlayView = pageToViewMapping[page] {
//            resultView = overlayView
//        } else {
//            let canvasView = PKCanvasView(frame: .zero)
//            canvasView.drawingPolicy = .pencilOnly
//            canvasView.tool = PKInkingTool(.pen, color: .black, width: 1)
//            canvasView.overrideUserInterfaceStyle = .light
//            canvasView.isOpaque = false
//            canvasView.backgroundColor = .clear
//            canvasView.minimumZoomScale = MIN_SCALE
//            canvasView.maximumZoomScale = MAX_SCALE
//            canvasView.bouncesZoom = false
//            canvasView.bounces = false
//            canvasView.delegate = self
//            canvasView.becomeFirstResponder()
//            canvasView.isScrollEnabled = false
//
//            pageToViewMapping[page] = canvasView
//            resultView = canvasView
//        }
//
//        // If we have stored a drawing on the page, set it on the canvas
//        if let myPage = page as? MyPDFPage, let drawing = myPage.drawing {
//            resultView?.drawing = drawing
//        }
//        print("resultView")
//
//        return resultView
//    }
//
//    func pdfView(
//        _ pdfView: PDFView,
//        willDisplayOverlayView overlayView: UIView,
//        for page: PDFPage
//    ) {
//        print("will")
//    }
//
//    func pdfView(_ pdfView: PDFView, willEndDisplayingOverlayView overlayView: UIView,
//                 for page: PDFPage)
//    {
//        let overlayView = overlayView as! PKCanvasView
//        if let page = page as? MyPDFPage {
//            page.drawing = overlayView.drawing
//            pageToViewMapping.removeValue(forKey: page)
//        }
//    }
//
//    func updateCanvasViewScales(pdfView: PDFView, scrollView: UIScrollView, with scale: CGFloat) {
//        guard let currentPage = pdfView.currentPage else { return }
//        if let canvasView = pageToViewMapping[currentPage] {
//            canvasView.transform = CGAffineTransform(scaleX: 1.0 / scale, y: 1.0 / scale)
//            canvasView.frame = currentPage.bounds(for: .mediaBox)
//            pageToViewMapping[currentPage] = canvasView
//            pdfView.setNeedsLayout()
//            pdfView.layoutIfNeeded()
//        }
//    }
// }
//
// extension Coordinator: UIScrollViewDelegate, PKCanvasViewDelegate {
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        print("scrollViewDidZoom")
//        pdfView.scaleFactor = scrollView.zoomScale
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollViewDidScroll")
//    }
//
//    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//        print(canvasView.drawing)
//    }
// }
//
// class MyPDFPage: PDFPage {
//    var drawing: PKDrawing?
// }
//
// extension PKDrawing {
//    mutating func scale(to scaleFactor: CGFloat) {
//        transform(using: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
//    }
// }
