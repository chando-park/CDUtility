import UIKit
import SwiftUI
import WebKit

public struct CDWebview<NativeMessage:NativeMessageList_P, Address: CDWebAddress_P>: UIViewRepresentable {

    private let address: Address
    private let backgrouneColor: Color
    var webViewCommunicator: WebViewCommunicator<NativeMessage>
    
    public init(address: Address,
                backgrouneColor: Color,
                webViewCommunicator: WebViewCommunicator<NativeMessage>) {
        
        self.webViewCommunicator = webViewCommunicator
        self.address = address
        self.backgrouneColor = backgrouneColor

    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
#if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        if let cgColor = self.backgrouneColor.cgColor{
            webView.backgroundColor = UIColor(cgColor: cgColor)
        }
        webView.navigationDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator
        
        webViewCommunicator.webView = webView
        webViewCommunicator.addScriptMessages(context.coordinator)
        
        
        if let request = address.request {
            
            print("loadHtml address \(String(describing: request.url?.absoluteString))")
            print("loadHtml allHTTPHeaderFields \(String(describing: request.allHTTPHeaderFields))")
            
            webView.load(request)
        }else{
            self.webViewCommunicator.onError?(.invalidURL)
        }
        
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }

    public func makeCoordinator() -> WebSlave {
        WebSlave(owner: self)
    }
    
    public class WebSlave: NSObject, WKNavigationDelegate, WKScriptMessageHandler,UIScrollViewDelegate{
        
        var owner: CDWebview
        
        public init(owner: CDWebview) {
            self.owner = owner
        }
        
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            self.owner.webViewCommunicator.actInNavive(message: message)
        }
        
        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            self.owner.webViewCommunicator.onStarted?()
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.owner.webViewCommunicator.onFinished?(webView)
        }
        
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let code = (error as NSError).code
            let message = error.localizedDescription
            self.owner.webViewCommunicator.onError?(.specificError(code, message))
        }
        
        public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            scrollView.pinchGestureRecognizer?.isEnabled = false
        }
        
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return nil
        }
    }
    
    
}
