//
//  UIShaowd.swift
//  noteE
//
//  Created by 张旭晟 on 2023/12/18.
//

import SwiftUI

struct UIShaowd: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIShaowdViewController
    
    let radius: CGFloat
    let cornerRaduiu: CGFloat
    var color: Color = Color(.sRGBLinear, white: 0, opacity: 0.2)
    
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
        view.layer.shadowColor = RootView.color.cgColor
        view.layer.shadowOffset = CGSize(width: 0,height: 0)
        view.layer.shadowRadius = RootView.radius
        view.layer.shadowOpacity = 1
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: RootView.cornerRaduiu).cgPath
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        SetShadow()
    }
}
