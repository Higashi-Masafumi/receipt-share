//
//  NewReceipt.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//

import SwiftUI
import VisionKit

struct NewReceiptView: View {
    
    // ───────── DI & State ─────────
    @Environment(\.dismiss) private var dismiss
    @Environment(NewReceiptViewModel.self) private var newReceiptViewModel
    
    @State private var scannedImages: [UIImage] = []
    @State private var showScanner      = false
    @State private var showGroupPicker  = false
    @State private var showToast       = false
    private var isButtonDisabled: Bool {
        scannedImages.isEmpty || newReceiptViewModel.selectedGroup == nil
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    // --- 1. プレビュー -------------------------------------
                    Section("スキャン済みレシート") {
                        if scannedImages.isEmpty {
                            ContentUnavailableView("スキャンした画像",
                                                   systemImage: "photo.on.rectangle")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(scannedImages, id: \.self) { img in
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 140, height: 180)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    // --- 2. スキャンボタン ---------------------------------
                    Section("レシートスキャン") {
                        Button {
                            showScanner = true
                        } label: {
                            Label("スキャンを開始", systemImage: "camera.viewfinder")
                                .font(.headline)
                        }
                    }
                    
                    // --- 3. グループ選択 ----------------------------------
                    Section("グループ") {
                        if let g = newReceiptViewModel.selectedGroup {
                            HStack {
                                Text(g.name)
                                Spacer()
                                Button("変更") { showGroupPicker = true }
                                    .font(.caption)
                            }
                        } else {
                            Button {
                                showGroupPicker = true
                            } label: {
                                Label("グループを選択", systemImage: "person.3.sequence")
                            }
                        }
                    }
                    
                    // --- 4. 保存ボタン ------------------------------------
                    Section {
                        SaveButton(
                            isDisabled: { isButtonDisabled },
                            action: {
                                Task {
                                    try await newReceiptViewModel.save(scannedImages: scannedImages)
                                    if newReceiptViewModel.errorMessage == nil {
                                        showToast = true
                                    }
                                }
                            }
                        )
                    }
                    

                }
                
                if newReceiptViewModel.isSaving {
                    ProgressView("保存中...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.8))
                        .edgesIgnoringSafeArea(.all)
                }
                
                if showToast {
                    VStack {
                        Text("レシートを保存しました")
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showToast = false
                                    // 保存後は画面を閉じる
                                    dismiss()
                                    // 状態をリセットする
                                    newReceiptViewModel.reset()
                                    scannedImages = []
                                }
                                
                            }
                    }
                    .transition(.move(edge: .top))
                    .padding(.top, 50)
                }
            }
            .navigationTitle("新規レシート")
            .alert("エラー", isPresented: .constant(newReceiptViewModel.errorMessage != nil)) {
                Button("OK") { newReceiptViewModel.errorMessage = nil }
            } message: {
                Text(newReceiptViewModel.errorMessage ?? "")
            }
            .fullScreenCover(isPresented: $showScanner) {
                ScannerWrapper(images: $scannedImages)
            }
            .sheet(isPresented: $showGroupPicker) {
                GroupPickerSheet(
                    groups: newReceiptViewModel.groups,
                    selected: newReceiptViewModel.selectedGroup
                ) { selected in
                    newReceiptViewModel.selectedGroup = selected
                    showGroupPicker = false
                }
            }
            .onAppear {
                Task {
                    await newReceiptViewModel.observeGroups()
                }
            }
        }
    }
}



struct ScannerWrapper: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.presentationMode) var presentation
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) { }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: ScannerWrapper
        
        init(_ parent: ScannerWrapper) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            var results = [UIImage]()
            for i in 0..<scan.pageCount {
                results.append(scan.imageOfPage(at: i))
            }
            parent.images = results
            controller.dismiss(animated: true) {
                self.parent.presentation.wrappedValue.dismiss()
            }
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true) {
                self.parent.presentation.wrappedValue.dismiss()
            }
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: Error) {
            print("Scan failed:", error)
            controller.dismiss(animated: true) {
                self.parent.presentation.wrappedValue.dismiss()
            }
        }
    }
}
