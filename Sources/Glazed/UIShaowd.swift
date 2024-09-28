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

public struct UIShaowd: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIShaowdViewController
    
    let radius: CGFloat
    let cornerRaduiu: CGFloat
    var color: Color? = nil
    
    @Environment(\.colorScheme) var colorScheme
    
    public init(radius: CGFloat, cornerRaduiu: CGFloat, color: Color? = nil) {
        self.radius = radius
        self.cornerRaduiu = cornerRaduiu
        self.color = color
    }
    public func makeUIViewController(context: Context) -> UIShaowdViewController {
        return UIShaowdViewController(RootView: self)
    }
    
    public func updateUIViewController(_ uiViewController: UIShaowdViewController, context: Context) {
        uiViewController.RootView = self
        uiViewController.SetShadow()
    }
}

public class UIShaowdViewController: UIViewController {
    var RootView: UIShaowd
    
    public init(RootView: UIShaowd) {
        self.RootView = RootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        SetShadow()
    }
    
    func SetShadow() {
        switch RootView.colorScheme {
        case .dark:
            view.layer.shadowColor = UIColor.gray.withAlphaComponent(0.7).cgColor
        case .light:
            view.layer.shadowColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        @unknown default:
            view.layer.shadowColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        }
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = RootView.radius
        view.layer.shadowOpacity = 1
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: RootView.cornerRaduiu).cgPath
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        SetShadow()
    }
}
public struct UIPathShaowd: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIPathShaowdViewController
    
    let radius: CGFloat
    let path: CGPath
    var color: Color? = nil
    
    @Environment(\.colorScheme) var colorScheme
    
    public init(radius: CGFloat, path: CGPath, color: Color? = nil) {
        self.radius = radius
        self.path = path
        self.color = color
    }
    
    public func makeUIViewController(context: Context) -> UIPathShaowdViewController {
        return UIPathShaowdViewController(RootView: self)
    }
    
    public func updateUIViewController(_ uiViewController: UIPathShaowdViewController, context: Context) {
        uiViewController.RootView = self
        uiViewController.SetShadow()
    }
}

public class UIPathShaowdViewController: UIViewController {
    var RootView: UIPathShaowd
    
    init(RootView: UIPathShaowd) {
        self.RootView = RootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
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
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        SetShadow()
    }
}
