//
//  FileBrowserView.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2024-05-01.
//
//  ---------------------------------------------------------------------------
//
//  © 2024 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers
import AudioToolbox
import Defaults

struct FileBrowserView: View {
    
    @State var document: DirectoryDocument
    
    @AppStorage(.fileBrowserKeepsFoldersOnTop) private var keepsFoldersOnTop
    @AppStorage(.fileBrowserShowsHiddenFiles) private var showsHiddenFiles
    @AppStorage(.fileBrowserShowsFilenameExtensions) private var showsFilenameExtensions
    
    @State private var selection: FileNode.ID?
    
    @State private var error: (any Error)?
    
    
    var body: some View {
        
        VStack(spacing: 0) {
            let fileNodes = (self.document.fileNode?.children ?? [])
                .recursivelyFilter { self.showsHiddenFiles || !$0.isHidden }
                .sorted(keepsFoldersOnTop: self.keepsFoldersOnTop)
            
            List(fileNodes, children: \.children, selection: $selection) { node in
                NodeView(node: node)
            }
            .listStyle(.sidebar)
            .contextMenu(forSelectionType: FileNode.ID.self) { ids in
                let node = ids.first.flatMap { self.document.fileNode?.node(with: $0, keyPath: \.id) }
                self.contextMenu(node: node)
            }
        }
        .onChange(of: self.selection) { (oldValue, _) in
            guard let node = self.selectedNode, !node.isDirectory else { return }
            
            Task {
                guard await self.document.openDocument(at: node.fileURL) else {
                    self.selection = oldValue
                    return
                }
            }
        }
        .onChange(of: self.document.currentDocument) { (_, newValue) in
            guard
                let fileURL = newValue?.fileURL,
                let node = self.document.fileNode?.node(with: fileURL, keyPath: \.fileURL)
            else { return }
            
            self.selection = node.id
        }
        .alert(error: $error)
    }
    
    
    // MARK: Private Methods
    
    private var selectedNode: FileNode? {
        
        self.selection.flatMap { self.document.fileNode?.node(with: $0, keyPath: \.id) }
    }
    
    
    @ViewBuilder private func contextMenu(node: FileNode?) -> some View {
        
        if let node {
            Button(String(localized: "Show in Finder", table: "Document", comment: "menu item label")) {
                NSWorkspace.shared.activateFileViewerSelecting([node.fileURL])
            }
            
            Divider()
            
            if !node.isDirectory {
                Button(String(localized: "Open with External Editor", table: "Document", comment: "menu item label")) {
                    NSWorkspace.shared.open(node.fileURL)
                }
            }
            if !node.isDirectory, NSDocumentController.shared.document(for: node.fileURL) == nil {
                Button(String(localized: "Open in Separate Window", table: "Document", comment: "menu item label")) {
                    NSDocumentController.shared.openDocument(withContentsOf: node.fileURL, display: true) { (_, _, error) in
                        self.error = error
                    }
                }
            }
            
            Divider()
            
            Button(String(localized: "Move to Trash", table: "Document", comment: "menu item label")) {
                do {
                    try FileManager.default.trashItem(at: node.fileURL, resultingItemURL: nil)
                    AudioServicesPlaySystemSound(.moveToTrash)
                } catch {
                    self.error = error
                }
            }
            
            Divider()
        }
        
        Toggle(String(localized: "Show Filename Extensions", table: "Document", comment: "menu item label (Check how Apple translates the term “filename extension.”)"), isOn: $showsFilenameExtensions)
        Toggle(String(localized: "Show Hidden Files", table: "Document", comment: "menu item label"), isOn: $showsHiddenFiles)
        Toggle(String(localized: "Keep Folders on Top", table: "Document", comment: "menu item label"), isOn: $keepsFoldersOnTop)
    }
}


private struct NodeView: View {
    
    var node: FileNode
    
    @AppStorage(.fileBrowserShowsFilenameExtensions) private var showsFilenameExtensions
    
    
    var body: some View {
        
        Label {
            Text(self.showsFilenameExtensions ? self.node.name : self.node.name.deletingPathExtension)
        } icon: {
            Image(systemName: self.node.isDirectory ? "folder" : "doc")
        }
        .lineLimit(1)
        .opacity(self.node.isHidden ? 0.5 : 1)
    }
}



// MARK: - Preview

#Preview(traits: .fixedLayout(width: 200, height: 400)) {
    FileBrowserView(document: DirectoryDocument())
        .listStyle(.sidebar)
}
