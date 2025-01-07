# 琉璃瓦
由华夏旭府构建设计并提供支持的swiftUI弹出窗口增强系统。

### 功能
- Sheet：与swiftUI类似的支持自定义背景颜色和动态大小变化的模态视图。
- Popover：包含支持在视图Z轴上方弹出窗口和支持各种行为自定义的弹出视图。
- Progress：一个和swiftUI深度结合的异步加载等待视图。
  
### 优势
- 可高度定制的各种视图。
- 完全基于Swift。
- 只需要将首字母大写就可实现从系统视图到琉璃瓦视图的过渡。
- 由华夏旭府背书并支持。

## 实例
以下内容均为 华夏旭府 书笺 中的实现。您可以在AppStore中下载到书笺。
### Sheet
<img src="https://github.com/user-attachments/assets/4efe8c4d-18ba-4537-ae6b-2476a4669a98" width="240px">

```swift
SomeView()
    .Sheet(isPresented: $showSetting) {
        SettingView(showSetting: $showSetting)
                .frame(maxWidth: 750, maxHeight: 640)
    }
```
### Popover
<img src="https://github.com/user-attachments/assets/fee871ec-c24c-46e2-ad0e-f32dce2433f5" width="240px">

```swift
SomeView()
    .Popover(isPresented: $editName, type: popoverType(isCenter: true)) {
        TextEditor(text: $editNameText)
            .frame(maxWidth: 192, maxHeight: 96)
    }
    .Popover(isPresented: $editFile, type: popoverType(isCenter: true)) {
        BrowserCorePaperEnotCellContextMenu()
    }
```

