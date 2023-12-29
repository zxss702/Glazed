//
//  EX_Swift.swift
//  noteE
//
//  Created by 张旭晟 on 2023/1/14.
//

import SwiftUI
import QuickLookThumbnailing

func GetFileThumbail(fileUrl: URL, size: CGSize, representationTypes: QLThumbnailGenerator.Request.RepresentationTypes, image: @escaping (UIImage) -> Void ) {
    DispatchQueue.global().async {
        let request = QLThumbnailGenerator.Request(fileAt: fileUrl, size: CGSize(width: size.width.rounded(), height: size.height.rounded()), scale: UIScreen.main.scale, representationTypes: representationTypes)
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, Error in
            if thumbnail != nil {
                guard let newimage = thumbnail?.uiImage else { return }
                image(newimage)
            }
        }
    }
}
func GetFileThumbailinMain(fileUrl: URL, size: CGSize, representationTypes: QLThumbnailGenerator.Request.RepresentationTypes, image: @escaping (UIImage) -> Void ) {
    let request = QLThumbnailGenerator.Request(fileAt: fileUrl, size: CGSize(width: size.width.rounded(), height: size.height.rounded()), scale: UIScreen.main.scale, representationTypes: representationTypes)
    QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, Error in
        if thumbnail != nil {
            guard let newimage = thumbnail?.uiImage else { return }
            image(newimage)
        }
    }
}

func GetNewFileName(LastFile url:URL, PaperURL toUrl:URL, AppendString: String = "") -> String {
    let name = url.lastPathComponent
    var count = 1
    while FileManager.default.fileExists(atPath: toUrl.append(path: newName(str: name, count: count)).path) {
        count += 1
    }
    return newName(str: name, count: count)
}
func newName(str:String, count: Int) -> String {
    var strList = str.components(separatedBy: ".")
    if strList.count <= 1 {
        return str + (count == 1 ? "" : String(count))
    } else {
        let LastList = strList.removeLast()
        var NameString = ""
        var counts = 1
        for i in strList {
            NameString += i
            if counts != strList.count {
                NameString += "."
            }
            counts += 1
        }
        return NameString + (count == 1 ? "" : String(count)) + "." + LastList
    }
}
