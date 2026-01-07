import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    @Binding var scannedImages: [UIImage]
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannedImages: $scannedImages, dismiss: dismiss)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Binding var scannedImages: [UIImage]
        var dismiss: DismissAction
        
        init(scannedImages: Binding<[UIImage]>, dismiss: DismissAction) {
            self._scannedImages = scannedImages
            self.dismiss = dismiss
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            for pageIndex in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                scannedImages.append(image)
            }
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document scanner failed with error: \(error.localizedDescription)")
            controller.dismiss(animated: true)
        }
    }
    
    // Check if document scanner is available
    static var isAvailable: Bool {
        return VNDocumentCameraViewController.isSupported
    }
}
