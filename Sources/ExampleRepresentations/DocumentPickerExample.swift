import SwiftUI
import UniformTypeIdentifiers
import DocumentPickerRepresentation

#if canImport(UIKit)

public struct DocumentPickerExample: View {
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    enum Mode: Hashable, CaseIterable {
        case importing
        case exporting
    }
    
    @State private var error: Error?
    @State private var mode: Mode = .importing
    @State private var importing: [UTType] = []
    @State private var exporting: [URL] = []
    @State private var copyResource = false
    @State private var multiSelect = false
    @State private var showsExtension = false
    
    private var action: DocumentPicker.Action {
        switch mode {
        case .importing: .importing(importing)
        case .exporting: .exporting(exporting)
        }
    }
    
    private var updateHash: Int {
        var hasher = Hasher()
        hasher.combine(mode)
        hasher.combine(copyResource)
        return hasher.finalize()
    }
    
    public init(){ }
    
    @ViewBuilder private var options: some View {
        Toggle(isOn: $copyResource){
            Text("Copy Resource")
                .font(.headline)
        }
        .padding(.horizontal)
        .frame(height: 46)
        
        Divider().padding(.leading, verticalSizeClass == .compact ? 0 : 16)
        
        Toggle(isOn: $multiSelect){
            Text("Allows Multi Selection")
                .font(.headline)
        }
        .padding(.horizontal)
        .frame(height: 46)
        
        Divider().padding(.leading, verticalSizeClass == .compact ? 0 : 16)
        
        Toggle(isOn: $showsExtension){
            Text("Show Extensions")
                .font(.headline)
        }
        .padding(.horizontal)
        .frame(height: 46)
    }
    
    public var body: some View {
        VStack(spacing: 0){
            VStack(spacing: 16) {
                if let error = error as? LocalizedError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.tint)
                            .font(.title)
                        
                        VStack(alignment: .leading) {
                            Text("Error").font(.headline)
                            Text(error.localizedDescription)
                                .font(.footnote)
                                .opacity(0.5)
                        }
                        
                        Spacer()
                        
                        Button{ self.error = nil } label: {
                            Text("Clear")
                        }
                    }
                    .padding(12)
                    .background{
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.tint)
                            .opacity(0.1)
                    }
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .tint(.red)
                }
                
                DocumentPicker(
                    action,
                    copyResource: copyResource,
                    allowMultipleSelection: multiSelect,
                    showFileExtension: showsExtension
                ){ res in
                    print(res)
                    switch res {
                    case .success(let urls):
                        print(urls)
                    case .failure(let err):
                        self.error = err
                    }
                }
                .id(updateHash)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.1), radius: 5, y: 5)
                .transition(.scale(scale: 0.8).combined(with: .opacity).animation(.smooth))
            }
            .padding()
            .animation(.bouncy, value: error == nil)
            
            VStack(spacing: 0) {
                Picker(selection: $mode){
                    ForEach(Mode.allCases, id: \.self){
                        ModeLabel($0).tag($0)
                    }
                } label: {
                    Text("Mode")
                }
                .pickerStyle(.segmented)
                .padding()
                
                if verticalSizeClass == .compact {
                    HStack(spacing: 0){ options }
                        .frame(height: 50)
                } else {
                    VStack(spacing: 0){ options }
                }
            }
            .frame(maxWidth: verticalSizeClass == .compact ? nil : 580)
        }
        .background{
            Color.secondary
                .opacity(0.2)
                .ignoresSafeArea()
        }
    }
    
    
    struct ModeLabel: View {
        
        let mode: Mode
        
        init(_ mode: Mode) {
            self.mode = mode
        }
        
        var body: some View {
            switch mode {
            case .importing:
                Text("Import")
            case .exporting:
                Text("Export")
            }
        }
    }
    
}

#Preview {
    DocumentPickerExample()
}

#endif
