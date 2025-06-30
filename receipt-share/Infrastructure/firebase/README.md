# Firebase DTO (Data Transfer Objects)

このディレクトリには、Firestore とのデータのやり取りに使用する DTO が含まれています。

## ファイル構成

- **DTO Files**: 純粋なデータ構造

  - `UserDTO.swift`
  - `GroupDTO.swift`
  - `MemberDTO.swift`
  - `ReceiptDTO.swift`
  - `ReceiptItemDTO.swift`

- **DTOMapper.swift**: Domain Model との相互変換ロジック
- **DTOConstants.swift**: 共通定数と列挙型

## データ構造

### Firestore のコレクション構造

```
┬ users                … ユーザープロフィール
│ └ {uid}
│    ├ displayName
│    ├ email
│    ├ photoURL
│    ├ createdAt
│    └ lastSeenAt
│
┬ groups               … グループ本体
│ └ {groupId}
│    ├ name
│    ├ photoURL
│    ├ createdAt
│    └ settings{…}
│
│   └─ members          … サブコレクション（1メンバー=1ドキュメント）
│        └ {uid}
│           ├ role      … "admin"|"member"
│           └ joinedAt
│
│   └─ receipts         … サブコレクション（グループ単位で分散）
│        └ {receiptId}
│           ├ uploadedBy          … uid
│           ├ invoiceNumber
│           ├ purchaseDate        … Timestamp
│           ├ merchantName
│           ├ totalAmount         … Number
│           ├ paymentMethod
│           ├ imageURL
│           ├ ocrStatus           … "pending"|"processing"|… 
│           ├ createdAt
│           └ updatedAt
```

## DTO の役割

各 DTO は以下の役割を持ちます：

1. **UserDTO**: ユーザー情報を Firestore に保存
2. **GroupDTO**: グループ情報を保存（メンバーは別コレクション）
3. **MemberDTO**: グループメンバーの役割と参加情報を保存
4. **ReceiptDTO**: レシート情報を保存
5. **ReceiptItemDTO**: レシートの商品項目を保存（ReceiptDTO 内の配列）

## 使用例

### ユーザーの保存

```swift
// Domain → DTO
let user = User(id: "123", name: "田中太郎", photoURL: URL(string: "...")!, email: "tanaka@example.com")
let userDTO = user.toDTO()

// DTO → Domain
let domainUser = userDTO.toDomain()
```

### グループの作成とメンバー追加

```swift
// グループ作成
let group = Group(id: "g1", name: "家族", photoURL: URL(string: "...")!, members: [])
let groupDTO = group.toDTO(createdBy: currentUserId)

// メンバー追加（シンプルな初期化）
let memberDTO = MemberDTO(id: "u2", role: MemberRole.member.rawValue, joinedAt: Timestamp())
```

### レシートの保存

```swift
let receipt = Receipt(/* ... */)
let receiptDTO = receipt.toDTO()
```

## 注意事項

- DTO は純粋なデータ構造として定義（ビジネスロジックは含まない）
- 変換ロジックは `DTOMapper.swift` で Extension として実装
- 金額は全て **cents** 単位で保存（100 円 = 10000 cents）
- 日時は `Timestamp` 型を使用
- URL は文字列として保存
