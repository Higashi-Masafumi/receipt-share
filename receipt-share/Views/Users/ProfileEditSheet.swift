import SwiftUI
import PhotosUI

struct ProfileEditSheet: View {
    @Binding var user: User
    @Binding var isPresented: Bool
    @Environment(ProfileViewModel.self) private var profileViewModel: ProfileViewModel
    @State private var selectedImage: UIImage?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("プロフィール画像") {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                AsyncImage(url: user.photoURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                        .frame(width: 80, height: 80)
                                        .opacity(0.3)
                                        .clipShape(Circle())
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("写真を変更")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                    }
                    .disabled(isSaving)

                }
                
                Section("基本情報") {
                    TextField("名前", text: $user.name)
                        .disabled(isSaving)
                    
                    HStack {
                        Text("メールアドレス")
                        Spacer()
                        Text(user.email)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        isPresented = false
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            isSaving = true
                            await saveChanges()
                            if profileViewModel.errorMessage.isEmpty {
                                isPresented = false
                            }
                            isSaving = false
                        }
                    }) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                Text("保存中...")
                            } else {
                                Text("完了")
                            }
                        }
                    }
                    .disabled(user.name.isEmpty || isSaving)
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            Task {
                await loadSelectedImage(newPhoto)
            }
        }
        .alert("エラー", isPresented: .constant(!profileViewModel.errorMessage.isEmpty)) {
            Button("OK") {
                profileViewModel.clearError()
            }
        } message: {
            Text(profileViewModel.errorMessage)
        }
    }
    
    private func loadSelectedImage(_ photo: PhotosPickerItem?) async {
        guard let photo = photo else { return }
        
        do {
            if let data = try await photo.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        } catch {
            print("画像読み込みエラー: \(error)")
        }
    }
    
    private func saveChanges() async {
        if let image = selectedImage {
            // 画像がある場合はアップロードしてからユーザー情報を更新
            await profileViewModel.updateUserProfileWithImage(user, image: image)
        } else {
            // 画像がない場合はユーザー情報のみ更新
            await profileViewModel.updateUserProfile(user)
        }
    }
}

#Preview {
    ProfileEditSheet(
        user: .constant(mockuser),
        isPresented: .constant(true)
    )
    .environment(ProfileViewModel(
        authRepository: FirebaseAuthRepository(),
        userRepository: FirebaseUserRepository(),
        storageRepository: FirebaseStorageRepository(),
        currentUser: AuthUser(id: "test", email: "test@example.com")
    ))
} 
