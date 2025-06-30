# Receipt Share - レシート共有アプリ

Receipt Share は SwiftUI で開発された iOS アプリケーションで、グループでレシートを共有・管理できるアプリです。レシートの撮影から自動テキスト抽出（OCR）、グループでの支出管理、チャート表示まで、包括的なレシート管理機能を提供します。

## 主要機能

### 🧾 レシート管理

- **レシート撮影**: カメラでオートスキャン
- **OCR 機能**: Firebase Functions と Gemini in Vertex AIを利用したOCR機能
- **編集機能**: OCR 結果の手動編集・修正
- **詳細表示**: レシートの詳細情報（店舗名、購入日、金額、商品項目など）を表示

### 👥 グループ機能

- **グループ作成・管理**: 家族や友人とのグループ作成
- **メンバー招待**: Universal Links を使用した招待機能
- **支出チャート**: グループの支出をビジュアル化

### 🔐 認証・ユーザー管理

- **Google Sign-In**: 簡単なサインイン・サインアップ
- **Firebase Authentication**: 安全なユーザー認証
- **プロフィール管理**: ユーザー情報の編集・更新

## アーキテクチャ

本プロジェクトは Clean Architecture の原則に基づいて設計されています：

```
receipt-share/
├── domain/                 # ドメイン層
│   ├── entities/          # エンティティ（ビジネスオブジェクト）
│   └── repositories/      # リポジトリインターフェース
├── Infrastructure/        # インフラストラクチャ層
│   ├── firebase/         # Firebase実装
│   └── hardcode/         # テスト用のハードコード実装
├── ViewModel/            # プレゼンテーション層（MVVM）
├── Views/               # UI層（SwiftUI）
│   ├── Auth/           # 認証関連画面
│   ├── Groups/         # グループ管理画面
│   ├── Receipt/        # レシート管理画面
│   ├── Users/          # ユーザー管理画面
│   └── Components/     # 再利用可能コンポーネント
└── extension/          # Swift拡張
```

### 主要なデザインパターン

- **MVVM (Model-View-ViewModel)**: UI とビジネスロジックの分離
- **Repository Pattern**: データアクセスの抽象化
- **Dependency Injection**: テスタビリティの向上

## セットアップ

### 前提条件

- Xcode 15.0 以上
- iOS 17.0 以上
- Swift 5.9 以上

### 1. リポジトリのクローン

```bash
git clone https://github.com/yourusername/receipt-share-public.git
cd receipt-share-public
```

### 2. Firebase 設定

> **重要**: Firebase を使用する場合は、`@/receipt-share` ディレクトリに `GoogleService-Info.plist` ファイルを配置する必要があります。

1. [Firebase Console](https://console.firebase.google.com/)でプロジェクトを作成
2. iOS アプリを追加し、Bundle Identifier を設定
3. `GoogleService-Info.plist` をダウンロード
4. **`receipt-share/GoogleService-Info.plist`** の場所に配置

#### 必要な Firebase サービス

- **Authentication**: Google Sign-In プロバイダーを有効化
- **Firestore Database**: レシートとグループデータの保存
- **Cloud Storage**: レシート画像の保存
- **Cloud Functions**: OCR 処理（別途設定が必要）

### 3. Google Sign-In 設定

1. Firebase Console で Google Sign-In プロバイダーを有効化
2. `GoogleService-Info.plist` の `REVERSED_CLIENT_ID` をアプリの URL Scheme に追加

### 4. プロジェクトのビルド

```bash
open receipt-share.xcodeproj
```

Xcode でプロジェクトを開き、ビルド・実行してください。

## データ構造

### Firestore コレクション構造

```
users/                    # ユーザープロフィール
  {uid}/
    ├ displayName
    ├ email
    ├ photoURL
    └ ...

groups/                   # グループ情報
  {groupId}/
    ├ name
    ├ photoURL
    └ members/            # サブコレクション
        {uid}/
          ├ role          # "admin" | "member"
          └ joinedAt
    └ receipts/           # サブコレクション
        {receiptId}/
          ├ uploadedBy
          ├ merchantName
          ├ totalAmount
          ├ ocrStatus
          └ ...
```

## 開発者向け情報

### ローカル開発（Firebase Emulator）

Firebase エミュレーターを使用した開発も可能です：
[receipt_shareApp.swift](receipt-share/receipt_shareApp.swift)のコメントアウトされたコードを有効化することでfirebase emulatorを利用することが可能です。

```swift
// receipt_shareApp.swift内のコメントアウトされたコードを有効化
// Configure Firebase for local emulators
Auth.auth().useEmulator(withHost: "localhost", port: 9099)
Functions.functions().useEmulator(withHost: "localhost", port: 5001)
Storage.storage().useEmulator(withHost: "localhost", port: 9199)
let settings = Firestore.firestore().settings
settings.host = "localhost:8080"
settings.cacheSettings = MemoryCacheSettings()
settings.isSSLEnabled = false
Firestore.firestore().settings = settings
```

### テスト実装

- **HardCode 実装**: Firebase を使用せずにテストできるモック実装が `Infrastructure/hardcode/` に含まれています
- **Unit Tests**: `receipt-shareTests/` に単体テストが配置されています
- **UI Tests**: `receipt-shareUITests/` に UI テストが配置されています

## 使用技術

### フレームワーク・ライブラリ

- **SwiftUI**: モダンな UI フレームワーク
- **Firebase**: バックエンドサービス
  - Authentication
  - Firestore Database
  - Cloud Storage
  - Cloud Functions
- **Google Sign-In**: 認証プロバイダー

### 開発手法

- **Clean Architecture**: 保守性とテスタビリティの確保
- **MVVM Pattern**: UI とロジックの分離
- **Repository Pattern**: データアクセスの抽象化

## ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](LICENSE) ファイルをご覧ください。

## 貢献

バグ報告、機能要求、プルリクエストを歓迎します。貢献する前に、Issue で議論することをお勧めします。

## サポート

質問やサポートが必要な場合は、GitHub の Issue を作成してください。
