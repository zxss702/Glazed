//
//  View.swift
//  noteX
//
//  Created by 张旭晟 on 2022/12/2.
//

import SwiftUI
import PDFKit

//MARK: Auto16
extension View{
    func AutoScrollStop(_ bool:Bool) -> some View{
        Group{
            if #available(iOS 16.0, *) {
                self
                    .scrollDisabled(bool)
            } else {
                self
            }
        }
        
    }
    
    func AutoScrollBackgroundHidden() -> some View{
        Group{
            if #available(iOS 16.0, *) {
                
                self
                    .scrollContentBackground(.hidden)
                
            } else {
                self
                    .onAppear{
                        UITableView.appearance().backgroundColor = .clear
                    }
            }
            
        }
        
    }
    
    func AutoNavigationStack16(_ color:UIColor = .secondarySystemBackground) -> some View{
        
        Group{
            
            if #available(iOS 16.0, *) {
                
                NavigationStack{
                    
                    self
                        .toolbarRole(.browser)
                }
                
            } else {
                
                NavigationView{
                    
                    self
                    
                    
                }
                .navigationViewStyle(.stack)
            }
            
        }
        
    }
    func AutoNavigationStack16b() -> some View{
        
        Group{
            
            if #available(iOS 16.0, *) {
                
                NavigationStack{
                    
                    self
                }
                
            } else {
                
                NavigationView{
                    
                    self
                        
                    
                }.navigationViewStyle(.stack)
                
            }
            
        }
        
    }
    
    func NavigationViewTopDivider() -> some View{
        
        ZStack{
            
            self
            
            VStack(spacing: 0){
                
                Divider()
                
                Spacer()
                
            }
            
        }
        
    }
    
    func FontWeightThin() -> some View{
        
        Group{
            
            if #available(iOS 16.0, *) {
                
                self
                    .fontWeight(.thin)
                
            } else {
                
                self
                
            }
            
        }
        
    }
    
    func AutonavigationDocument(_ document : URL) -> some View{
        Group{
            if #available(iOS 16.0, *) {
                self
                    .navigationDocument(document)
            } else {
                self
            }
        }
        
    }
    func AutopersistentSystemOverlays() -> some View{
        if #available(iOS 16.0, *) {
            return self
                .persistentSystemOverlays(.hidden)
        } else {
            return self
        }
    }
}


// MARK: any ios
extension View{
    @ViewBuilder
    func onChange(connect:some Equatable,action:@escaping () -> Void) -> some View {
        self
            .onAppear {
                action()
            }
            .onChange(of: connect){ newValue in
                action()
            }
    }
    
    func ActionSheet(isPresented:Binding<Bool>, title:String, message:String, action: @escaping () -> Void) -> some View {
        self
            .confirmationDialog(title, isPresented: isPresented, titleVisibility: .automatic) {
                SwiftUI.Button(role: .destructive) {
                    action()
                    isPresented.wrappedValue = false
                } label: {
                    Text("确认")
                }
                SwiftUI.Button(role: .cancel) {
                    isPresented.wrappedValue = false
                } label: {
                    Text("取消")
                }
            } message: {
                Text(message)
            }
    }
}

struct UIButtonView:UIViewRepresentable {
    typealias UIViewType = UIView
    let began:() -> Void
    let ended:() -> Void
    let failed:() -> Void

    func makeUIView(context: Context) -> UIView {
        let v = UIView()
        let gesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
        gesture.minimumPressDuration = 0
        gesture.allowableMovement = 5
        gesture.delegate = context.coordinator
        gesture.requiresExclusiveTouchType = true
        gesture.cancelsTouchesInView = false
        v.addGestureRecognizer(gesture)
        return v
    }
    func updateUIView(_ uiView: UIView, context: Context) { }

    func makeCoordinator() -> Coordinator {
        return Coordinator(RootView: self)
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let RootView: UIButtonView
        init(RootView: UIButtonView) {
            self.RootView = RootView
        }
        var location:CGPoint = .zero
        @objc func tapped(gesture:UILongPressGestureRecognizer) {
            switch gesture.state {
            case .began:
                location = gesture.location(in: gesture.view)
                RootView.began()
            case .changed:
                let location2 = gesture.location(in: gesture.view)
                if CGPoint(x: location2.x - location.x, y: location2.y - location.y).length > 5 {
                    RootView.failed()
                }
            case .ended:
                let location2 = gesture.location(in: gesture.view)
                if CGPoint(x: location2.x - location.x, y: location2.y - location.y).length > 5 {
                    RootView.failed()
                } else {
                    RootView.ended()
                }
            case .failed:
                RootView.failed()
            case .possible:
                return
            case .cancelled:
                return
            @unknown default:
                return
            }
        }
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
    }

}

class CustomHostingView<Content: View>: UIHostingController<Content>{
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = view.intrinsicContentSize
    }
}


extension View {
    func ifMode(@ViewBuilder ifAction: (AnyView) -> some View) -> some View {
        ifAction(AnyView(self))
    }
    
    @ViewBuilder
    func provided(_ Bool: Bool, _ ifAction: (AnyView) -> some View, else elseAction: (AnyView) -> some View = { AnyView in return AnyView}) -> some View {
        if Bool {
            ifAction(AnyView(self))
        } else {
            elseAction(AnyView(self))
        }
    }
    
    func UIContextMenu(cornerRadius: CGFloat, action: @escaping (UIContextMenuInteraction) -> UIMenu) -> some View{
        contextMenuHelper(cornerRadius: cornerRadius){
            self
        } action: { interaction in
            action(interaction)
        }
    }
    
    func shadow(Ofset: CGPoint = .zero) -> some View {
        self
            .shadow(size: 0.6)
            .shadow(radius: 40, x: Ofset.x, y: Ofset.y)
    }
    func shadow(size: CGFloat, Ofset: CGPoint = .zero) -> some View {
        self
            .shadow(radius: size, x: Ofset.x, y: Ofset.y)
    }
    func shadow(color: Color, size: CGFloat, Ofset: CGPoint = .zero) -> some View {
        self
            .shadow(radius: size, x: Ofset.x, y: Ofset.y)
    }
}

extension Color {
    static var shadowColor = Color("ShadowColor")
}

struct apperAction:UIViewRepresentable {
    let Action:() -> Void
    
    func makeUIView(context: Context) -> some UIView {
        DispatchQueue.main.async {
            Action()
        }
        return UIView(frame: .zero)
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
struct contextMenuHelper<Content:View>:UIViewControllerRepresentable {
    let cornerRadius:CGFloat
    @ViewBuilder var content:Content
    let action:(UIContextMenuInteraction) -> UIMenu
    func makeUIViewController(context: Context) -> some UIViewController {
        let Host = UIHostingController(rootView: content)
        Host.view.layer.cornerRadius = cornerRadius
        Host.view.backgroundColor = .clear
        Host.view.layer.masksToBounds = true
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        Host.view.addInteraction(interaction)
        return Host
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if let Host = uiViewController as? UIHostingController<Content> {
            Host.rootView = content
        }
    }
    func makeCoordinator() -> coordinator {
        coordinator(action: action)
    }
    class coordinator:NSObject, UIContextMenuInteractionDelegate {
        let action:(UIContextMenuInteraction) -> UIMenu
        init(action: @escaping (UIContextMenuInteraction) -> UIMenu) {
            self.action = action
            super.init()
        }
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
                return self.action(interaction)
            })
        }
    }
}


#if os(iOS)
struct BlurViewa: UIViewRepresentable {
    let style: UIBlurEffect.Style
    init(style: UIBlurEffect.Style = .systemMaterial) {
        self.style = style
    }
    
    typealias UIViewType = UIVisualEffectView
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: self.style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: self.style)
    }
}
#else
public struct BlurViewa: NSViewRepresentable {
    let style: NSVisualEffectView.Material
    init(style: NSVisualEffectView.Material = .hudWindow) {
        self.style = style
    }
    
    public typealias NSViewType = NSVisualEffectView
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let effectView = NSVisualEffectView()
        effectView.material = style
        effectView.blendingMode = .withinWindow
        effectView.state = NSVisualEffectView.State.active
        return effectView
    }
    
    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = style
        nsView.blendingMode = .withinWindow
    }
}
#endif


struct BlurView:View {
    var style:Material = .bar
    var color:Color = .clear
    
    init(style: Material = .bar, color: Color = .clear) {
        self.style = style
        self.color = color
    }
    
    var body: some View {
        Rectangle()
            .background(style)
            .foregroundColor(color.opacity(0.9))
    }
}

extension View {
    func EditViewLabelStyle(_ padding: Bool = false, color: Color = Color("systemBackColor")) -> some View {
        self
            .frame(minWidth: 35, minHeight: 35)
            .padding([.leading, .trailing], padding ? 14 : 0)
            .background(color)
            .clipShape(Capsule())
            .hoverEffect(.lift)
    }
    func EditViewViewStyle() -> some View {
        self
            .frame(minWidth: 35, minHeight: 35)
            .padding(.all, 7)
            .background(Color("systemBackColor"))
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .hoverEffect(.lift)
    }
    func EditShadow() -> some View {
        self
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.11), radius: 8)
    }
}

extension Image {
    init(_ cgimage: CGImage) {
        #if targetEnvironment(macCatalyst)
        self.init(uiImage: UIImage(cgImage: cgimage, scale: UIScreen().scale, orientation: .up))
        #else
        if #available(iOS 16.0, *) {
            self.init(cgimage, scale: UIScreen().scale, label: Text(""))
        } else {
            self.init(uiImage:  UIImage(cgImage: cgimage, scale: UIScreen().scale, orientation: .up))
        }
        #endif
    }
}

struct TapButtonStyle: ButtonStyle {
    @State var scale:CGFloat = 1
    @State var time:Date = Date()
   
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(x: scale, y: scale)
            .foregroundColor(.accentColor)
            .contentShape(Rectangle())
            .onChange(of: configuration.isPressed, perform: { newValue in
                if newValue {
                    time = Date()
                    withAnimation(.spring().speed(2)) {
                        scale = 0.9
                    }
                } else {
                    if time.distance(to: Date()) > 0.15 {
                        withAnimation(.spring().speed(1.5)) {
                            scale = 1
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring().speed(1.5)) {
                                scale = 1
                            }
                        }
                    }
                    
                }
            })
    }
}
struct TapButtonStyle2: ButtonStyle {
    @State var scale:CGFloat = 1
    @State var time:Date = Date()
   
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(x: scale, y: scale)
            .foregroundColor(.accentColor)
            .contentShape(Rectangle())
            .onChange(of: configuration.isPressed, perform: { newValue in
                if newValue {
                    time = Date()
                    withAnimation(.spring().speed(2)) {
                        scale = 0.98
                    }
                } else {
                    if time.distance(to: Date()) > 0.15 {
                        withAnimation(.spring().speed(1.5)) {
                            scale = 1
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring().speed(1.5)) {
                                scale = 1
                            }
                        }
                    }
                    
                }
            })
    }
}

struct FontHelper: ViewModifier {
    @Environment(\.font) var font
    @AppStorage("fontName") var fontName: String = "ShouJinTi"
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                let fontFamilies = UIFont.familyNames.sorted()
                    for family in fontFamilies {
                        print(family)
                        for font in UIFont.fontNames(forFamilyName: family).sorted() {
                            print("\t\(font)")
                        }
                    }
            }
            .font(.custom(fontName, size: UIFont.preferredFont(from: font ?? .body).pointSize))
    }
}

extension View {
    func customFont() -> some View {
        self.modifier(FontHelper())
    }
}
extension UIFont {
  class func preferredFont(from font: Font) -> UIFont {
      let style: UIFont.TextStyle
      switch font {
        case .largeTitle:  style = .largeTitle
        case .title:       style = .title1
        case .title2:      style = .title2
        case .title3:      style = .title3
        case .headline:    style = .headline
        case .subheadline: style = .subheadline
        case .callout:     style = .callout
        case .caption:     style = .caption1
        case .caption2:    style = .caption2
        case .footnote:    style = .footnote
        case .body: fallthrough
        default:           style = .body
     }
     return  UIFont.preferredFont(forTextStyle: style)
   }
}
//struct ViewController<Content: View>: UIViewRepresentable {
//    typealias UIViewType = UIView
//    
//    public var body:Content
//    
//    func makeUIView(context: Context) -> UIView {
//        UIHostingController(rootView: body).view
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//        
//    }
//}


class ViewControllerUIViewController<Content:View>: UIViewController {
    
    var hostingController:UIHostingController<Content>!
    var content: (ViewControllerUIViewController<Content>) -> Content
    private var viewWillLoad2:(ViewControllerUIViewController<Content>) -> Void
    private var viewDidLoad2:(ViewControllerUIViewController<Content>) -> Void
    private var viewWillAppear2:(ViewControllerUIViewController<Content>) -> Void
    private var viewDidAppear2:(ViewControllerUIViewController<Content>) -> Void
    private var viewWillLayoutSubviews2:(ViewControllerUIViewController<Content>) -> Void
    private var viewDidLayoutSubviews2:(ViewControllerUIViewController<Content>) -> Void
    private var viewWillTransition2:(ViewControllerUIViewController<Content>) -> Void
    private var didReceiveMemoryWarning2:(ViewControllerUIViewController<Content>) -> Void
    private var viewWillDisappear2:(ViewControllerUIViewController<Content>) -> Void
    private var viewDidDisappear2:(ViewControllerUIViewController<Content>) -> Void
    
    init(
        @ViewBuilder content: @escaping (ViewControllerUIViewController<Content>) -> Content,
        viewWillLoad: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewDidLoad: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewWillAppear: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewDidAppear: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewWillLayoutSubviews: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewDidLayoutSubviews: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewWillTransition: @escaping (ViewControllerUIViewController<Content>) -> Void,
        didReceiveMemoryWarning: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewWillDisappear: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewDidDisappear: @escaping (ViewControllerUIViewController<Content>) -> Void
    ) {
        self.content = content
        self.viewWillLoad2 = viewWillLoad
        self.viewDidLoad2 = viewDidLoad
        self.viewWillAppear2 = viewWillAppear
        self.viewDidAppear2 = viewDidAppear
        self.viewWillLayoutSubviews2 = viewWillLayoutSubviews
        self.viewDidLayoutSubviews2 = viewDidLayoutSubviews
        self.viewWillTransition2 = viewWillTransition
        self.didReceiveMemoryWarning2 = didReceiveMemoryWarning
        self.viewWillDisappear2 = viewWillDisappear
        self.viewDidDisappear2 = viewDidDisappear
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func actionsSet(
        viewWillLoad: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewDidLoad: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewWillAppear: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewDidAppear: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewWillLayoutSubviews: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewDidLayoutSubviews: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewWillTransition: @escaping (ViewControllerUIViewController<Content>) -> Void,
        didReceiveMemoryWarning: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewWillDisappear: @escaping (ViewControllerUIViewController<Content>) -> Void,
        viewDidDisappear: @escaping (ViewControllerUIViewController<Content>) -> Void
    ) {
        self.viewWillLoad2 = viewWillLoad
        self.viewDidLoad2 = viewDidLoad
        self.viewWillAppear2 = viewWillAppear
        self.viewDidAppear2 = viewDidAppear
        self.viewWillLayoutSubviews2 = viewWillLayoutSubviews
        self.viewDidLayoutSubviews2 = viewDidLayoutSubviews
        self.viewWillTransition2 = viewWillTransition
        self.didReceiveMemoryWarning2 = didReceiveMemoryWarning
        self.viewWillDisappear2 = viewWillDisappear
        self.viewDidDisappear2 = viewDidDisappear
    }
    
    override func viewDidLoad() {
        hostingController = UIHostingController(rootView: content(self))
        viewWillLoad2(self)
        super.viewDidLoad()
        view.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
        viewDidLoad2(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear2(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear2(self)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewWillLayoutSubviews2(self)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewDidLayoutSubviews2(self)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        viewWillTransition2(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        didReceiveMemoryWarning2(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappear2(self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidDisappear2(self)
    }
}
struct ViewController<Content:View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = ViewControllerUIViewController<Content>
    typealias ViewController = ViewControllerUIViewController<Content>
    
    @ViewBuilder var content: (ViewController) -> Content
    
    @State var viewWillLoad:(ViewController) -> Void = { _ in }
    @State var viewDidLoad:(ViewController) -> Void = { _ in }
    @State var viewWillAppear:(ViewController) -> Void = { _ in }
    @State var viewDidAppear:(ViewController) -> Void = { _ in }
    @State var viewWillLayoutSubviews:(ViewController) -> Void = { _ in }
    @State var viewDidLayoutSubviews:(ViewController) -> Void = { _ in }
    @State var viewWillTransition:(ViewController) -> Void = { _ in }
    @State var didReceiveMemoryWarning:(ViewController) -> Void = { _ in }
    @State var viewWillDisappear:(ViewController) -> Void = { _ in }
    @State var viewDidDisappear:(ViewController) -> Void = { _ in }
    
    func makeUIViewController(context: Context) -> ViewControllerUIViewController<Content> {
        ViewControllerUIViewController(content: content, viewWillLoad: viewWillLoad, viewDidLoad: viewDidLoad, viewWillAppear: viewWillAppear, viewDidAppear: viewDidAppear, viewWillLayoutSubviews: viewWillLayoutSubviews, viewDidLayoutSubviews: viewDidLayoutSubviews, viewWillTransition: viewWillTransition, didReceiveMemoryWarning: didReceiveMemoryWarning, viewWillDisappear: viewWillTransition, viewDidDisappear: viewDidDisappear)
    }
    
    func updateUIViewController(_ uiViewController: ViewControllerUIViewController<Content>, context: Context) {
        uiViewController.actionsSet(viewWillLoad: viewWillLoad, viewDidLoad: viewDidLoad, viewWillAppear: viewWillAppear, viewDidAppear: viewDidAppear, viewWillLayoutSubviews: viewWillLayoutSubviews, viewDidLayoutSubviews: viewDidLayoutSubviews, viewWillTransition: viewWillTransition, didReceiveMemoryWarning: didReceiveMemoryWarning, viewWillDisappear: viewWillTransition, viewDidDisappear: viewDidDisappear)
        withAnimation(.spring()) {
            uiViewController.hostingController.rootView = content(uiViewController)
        }
    }
}
