# IronSovereign (IronSabereign)

> 独自のデザインシステムを持つ、ネイティブ Swift / SwiftUI アプリ。鍛冶（Forge）をモチーフにした世界観のUIコンポーネント群を実装。

[![Swift](https://img.shields.io/badge/Swift-SwiftUI-fa7343)](https://developer.apple.com/swift/) [![Status](https://img.shields.io/badge/status-WIP-yellow)](#)

---

## 概要

独自テーマ（IronTheme）に基づくデザインシステムを中心としたネイティブアプリ。再利用可能なUIコンポーネントとアニメーションを体系的に構築している。

> ⚠️ 開発中（WIP）のプロジェクトです。

---

## デザインシステム

```
DesignSystem/
├── Components/   # ForgeBanner, RuneCard, EmberProgressBar,
│                 #   SovereignButton, GlowingDivider
├── Theme/        # IronTheme, Colors, Typography
└── Animations/   # TransitionEffects, CompletionAnimation
```

その他 `App/` `Core/` `Features/` `Resources/` と、`IronSabereignTests/` を含む。

---

## 技術スタック

`Swift` `SwiftUI` `XCTest`

---

## ビルド

```bash
open IronSabereign/IronSabereign.xcodeproj   # Xcodeで開く
# ⌘R で実行 / ⌘U でテスト
```

---

## このプロジェクトで見せられること

- **SwiftUI による設計システム**構築（テーマ・コンポーネント・アニメーションの分離）
- 一貫した世界観をUIに落とし込むデザイン力
- ネイティブ開発（Xcode / XCTest）

---

*※ ポートフォリオ目的の公開リポジトリです。開発中のため一部未実装の機能があります。*
