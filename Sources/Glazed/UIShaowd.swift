//
//  UIShaowd.swift
//  noteE
//
//  Created by 张旭晟 on 2023/12/18.
//

import SwiftUI

#if os(macOS)
public struct UIShaowd: NSViewControllerRepresentable {
    public typealias NSViewControllerType = UIShaowdViewController
    
    let radius: CGFloat
    let cornerRaduiu: CGFloat
    var color: Color = Color(.sRGBLinear, white: 0, opacity: 0.2)
    
    public func makeNSViewController(context: Context) -> UIShaowdViewController {
        return UIShaowdViewController(RootView: self)
    }
    
    public func updateNSViewController(_ nsViewController: UIShaowdViewController, context: Context) {
        nsViewController.RootView = self
        nsViewController.SetShadow()
    }
    
    public init(radius: CGFloat, cornerRaduiu: CGFloat, color: Color = Color(.sRGBLinear, white: 0, opacity: 0.2)) {
        self.radius = radius
        self.cornerRaduiu = cornerRaduiu
        self.color = color
    }
}

public class UIShaowdViewController: NSViewController {
    var RootView: UIShaowd
    
    init(RootView: UIShaowd) {
        self.RootView = RootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewWillAppear() {
        SetShadow()
    }
    func SetShadow() {
        view.layer?.shadowColor = RootView.color.cgColor
        view.layer?.shadowOffset = CGSize(width: 0,height: 0)
        view.layer?.shadowRadius = RootView.radius
        view.layer?.shadowOpacity = 1
        view.layer?.shadowPath = CGPath(roundedRect: view.bounds, cornerWidth: RootView.cornerRaduiu, cornerHeight: RootView.cornerRaduiu, transform: nil)
    }
    public override func viewDidLayout() {
        SetShadow()
    }
}
#else
public struct UIShaowd: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIShaowdViewController
    
    let radius: CGFloat
    let cornerRaduiu: CGFloat
    var color: Color = Color(.sRGBLinear, white: 0, opacity: 0.2)
    
    public func makeUIViewController(context: Context) -> UIShaowdViewController {
        return UIShaowdViewController(RootView: self)
    }
    
    public func updateUIViewController(_ uiViewController: UIShaowdViewController, context: Context) {
        uiViewController.RootView = self
        uiViewController.SetShadow()
    }
    
    public init(radius: CGFloat, cornerRaduiu: CGFloat, color: Color = Color(.sRGBLinear, white: 0, opacity: 0.2)) {
        self.radius = radius
        self.cornerRaduiu = cornerRaduiu
        self.color = color
    }
}

public class UIShaowdViewController: UIViewController {
    var RootView: UIShaowd
    
    init(RootView: UIShaowd) {
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
        view.layer.shadowColor = RootView.color.cgColor
        view.layer.shadowOffset = CGSize(width: 0,height: 0)
        view.layer.shadowRadius = RootView.radius
        view.layer.shadowOpacity = 1
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: RootView.cornerRaduiu).cgPath
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        SetShadow()
    }
}
#endif
