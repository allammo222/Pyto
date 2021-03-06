//
//  DocumentationViewController.swift
//  Pyto
//
//  Created by Adrian Labbe on 12/8/18.
//  Copyright © 2018 Adrian Labbé. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

/// A View controller showing offline documentation.
class DocumentationViewController: UIViewController, WKNavigationDelegate {
    
    /// The button for going back.
    var goBackButton: UIBarButtonItem!
    
    /// The button for going forward.
    var goForwardButton: UIBarButtonItem!
    
    /// The Web view containing documentation.
    var webView: WKWebView!
    
    /// Goes back.
    @objc func goBack() {
        webView.goBack()
    }
    
    /// Goes forward
    @objc func goForward() {
        webView.goForward()
    }
    
    /// Closes this View controller.
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View controller
    
    override var keyCommands: [UIKeyCommand]? {
        return [UIKeyCommand(input: "w", modifierFlags: .command, action: #selector(close), discoverabilityTitle: Localizable.close)]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        
        webView = WKWebView(frame: view.frame)
        webView.isHidden = true
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
        
        if let url = Bundle.main.url(forResource: "docs", withExtension: "") {
            webView.loadFileURL(url.appendingPathComponent("index.html"), allowingReadAccessTo: url)
        }
        
        goBackButton = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(goBack))
        goForwardButton = UIBarButtonItem(image: UIImage(named: "forward"), style: .plain, target: self, action: #selector(goForward))
        
        toolbarItems = [goBackButton, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), goForwardButton]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(close))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    // MARK: - Navigation delegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        goBackButton.isEnabled = webView.canGoBack
        goForwardButton.isEnabled = webView.canGoForward
        
        webView.evaluateJavaScript("document.body.style.backgroundColor = '\(ConsoleViewController.choosenTheme.sourceCodeTheme.backgroundColor.hexString ?? "white")'; document.body.style.color = '\(ConsoleViewController.choosenTheme.sourceCodeTheme.color(for: .plain).hexString ?? "black")'") { (_, _) in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                webView.isHidden = false
            })
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url, url.scheme == "http" || url.scheme == "https" {
            present(SFSafariViewController(url: url), animated: true, completion: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

