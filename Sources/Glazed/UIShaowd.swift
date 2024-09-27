//
//  UIShaowd.swift
//  noteE
//
//  Created by 张旭晟 on 2023/12/18.
//

import SwiftUI
//
//  UIShaowd.swift
//  书笺
//
//  Created by 张旭晟 on 2023/12/18.
//

import SwiftUI

struct UIShaowd: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIShaowdViewController
    
    let radius: CGFloat
    let cornerRaduiu: CGFloat
    var color: Color? = nil
    
    @Environment(\.colorScheme) var colorScheme
    
    func makeUIViewController(context: Context) -> UIShaowdViewController {
        return UIShaowdViewController(RootView: self)
    }
    
    func updateUIViewController(_ uiViewController: UIShaowdViewController, context: Context) {
        uiViewController.RootView = self
        uiViewController.SetShadow()
    }
}

class UIShaowdViewController: UIViewController {
    var RootView: UIShaowd
    
    init(RootView: UIShaowd) {
        self.RootView = RootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetShadow()
    }
    
    func SetShadow() {
        switch RootView.colorScheme {
        case .dark:
            view.layer.shadowColor = Color(.sRGBLinear, white: 0, opacity: 0.2).cgColor
        case .light:
            view.layer.shadowColor = Color(.sRGBLinear, white: 1, opacity: 0.2).cgColor
        @unknown default:
            view.layer.shadowColor = Color(.sRGBLinear, white: 0, opacity: 0.2).cgColor
        }
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = RootView.radius
        view.layer.shadowOpacity = 1
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: RootView.cornerRaduiu).cgPath
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        SetShadow()
    }
}
struct UIPathShaowd: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIPathShaowdViewController
    
    let radius: CGFloat
    let path: CGPath
    var color: Color? = nil
    
    @Environment(\.colorScheme) var colorScheme
    
    func makeUIViewController(context: Context) -> UIPathShaowdViewController {
        return UIPathShaowdViewController(RootView: self)
    }
    
    func updateUIViewController(_ uiViewController: UIPathShaowdViewController, context: Context) {
        uiViewController.RootView = self
        uiViewController.SetShadow()
    }
}

class UIPathShaowdViewController: UIViewController {
    var RootView: UIPathShaowd
    
    init(RootView: UIPathShaowd) {
        self.RootView = RootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetShadow()
    }
    
    func SetShadow() {
        switch RootView.colorScheme {
        case .dark:
            view.layer.shadowColor = Color(.sRGBLinear, white: 0, opacity: 0.2).cgColor
        case .light:
            view.layer.shadowColor = Color(.sRGBLinear, white: 1, opacity: 0.2).cgColor
        @unknown default:
            view.layer.shadowColor = Color(.sRGBLinear, white: 0, opacity: 0.2).cgColor
        }
        view.layer.shadowOffset = CGSize(width: 0,height: 0)
        view.layer.shadowRadius = RootView.radius
        view.layer.shadowOpacity = 1
        view.layer.shadowPath = RootView.path
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        SetShadow()
    }
}
