# Yommy (ヨミー)

> 📚 読みたい記事を溜めて、忘れずに読める。忙しい人のための「あとで読む」アプリ

**バージョン:** 1.0.0  
**最終更新日:** 2026年1月8日  
**ステータス:** 開発中（Phase 4 完了）

---

## 目次

1. [概要](#1-概要)
2. [ターゲットユーザー](#2-ターゲットユーザー)
3. [機能一覧](#3-機能一覧)
4. [技術スタック](#4-技術スタック)
5. [アーキテクチャ](#5-アーキテクチャ)
6. [データモデル](#6-データモデル)
7. [画面設計](#7-画面設計)
8. [開発ロードマップ](#8-開発ロードマップ)
9. [セットアップ手順](#9-セットアップ手順)
10. [リリース計画](#10-リリース計画)

---

## 1. 概要

### 1.1 アプリの目的

Yommy（ヨミー）は、「あとで読みたい」と思った記事やWebページを簡単に保存し、忘れずに読めるようリマインドしてくれるモバイルアプリケーションです。

### 1.2 解決する課題

| 課題 | Yommyの解決策 |
|------|---------------|
| 読みたい記事が溜まって忘れる | 毎日決まった時間にリマインド通知 |
| ブックマークが整理できない | 未読/読了のシンプルな管理 |
| 保存が面倒 | 他アプリからワンタップで共有保存 |
| 何を読んだか分からない | 知識の可視化機能（将来実装） |

### 1.3 コンセプト

- **シンプル**: 余計な機能を省き、「保存→リマインド→読む」に特化
- **かわいい**: 温かみのあるUIで、使うのが楽しくなるデザイン
- **継続しやすい**: 無理なく読書習慣が身につく仕組み

---

## 2. ターゲットユーザー

### 2.1 メインターゲット

**忙しい社会人・ビジネスパーソン**

- 通勤中や休憩時間にSNSで気になる記事を見つける
- 「あとで読もう」と思ってブックマークするが、そのまま忘れる
- 情報収集は習慣化したいが、時間がない

### 2.2 サブターゲット

- **エンジニア**: 技術記事（Zenn, Qiita, note）を効率的に消化したい
- **学生**: 勉強に関連する記事を計画的に読みたい
- **情報感度の高い人**: 日々大量の記事に触れるが、整理できていない

### 2.3 ユーザーペルソナ

```
名前: 田中 健太（32歳）
職業: ITベンチャー企業のプロダクトマネージャー
課題:
  - 毎日Twitterで20件以上の記事をブックマークする
  - 週末に読もうと思うが、溜まりすぎて諦める
  - 本当に読みたかった記事が埋もれてしまう
理想:
  - 毎朝3件だけ「今日読む記事」をレコメンドしてほしい
  - サクッと読了マークをつけて達成感を得たい
```

---

## 3. 機能一覧

### 3.1 実装済み機能（v1.0）

#### 📥 記事保存機能

| 機能 | 説明 |
|------|------|
| URL入力保存 | アプリ内でURLを入力して記事を追加 |
| メタデータ自動取得 | タイトル、説明文、サムネイル画像を自動取得 |
| ソース自動判定 | note, Zenn, Qiita等のサービス名を自動認識 |
| メモ追加 | 「なぜ読みたいか」などのメモを記録可能 |
| 重複チェック | 同じURLは二重登録されない |

#### 📋 記事管理機能

| 機能 | 説明 |
|------|------|
| 一覧表示 | カード形式で記事を一覧表示 |
| ステータス管理 | 未読/読了の切り替え |
| フィルタリング | 全て/未読/読了でフィルタ |
| スワイプアクション | 左スワイプで読了切替・削除 |
| 統計表示 | 全体/未読/読了の件数を表示 |

#### 🔔 リマインダー機能

| 機能 | 説明 |
|------|------|
| 毎日通知 | 指定時刻にプッシュ通知 |
| 曜日選択 | 通知する曜日をカスタマイズ |
| 記事選択モード | ランダム/古い順/新しい順 |
| 表示件数設定 | 通知に含める記事数を設定 |
| テスト通知 | 設定確認用のテスト送信 |

#### 📤 共有機能（iOS）

| 機能 | 説明 |
|------|------|
| Share Extension | Safari等から直接Yommyに保存 |
| App Groups | メインアプリとExtension間でデータ共有 |
| 自動取り込み | アプリ起動時に共有URLを自動追加 |

### 3.2 今後実装予定の機能

#### Phase 5: Android Share Intent

| 機能 | 説明 | 優先度 |
|------|------|--------|
| Intent Filter | 他アプリからの共有を受信 | 高 |
| URL抽出 | テキストからURLを検出 | 高 |

#### Phase 6: 検索・タグ機能

| 機能 | 説明 | 優先度 |
|------|------|--------|
| フリーワード検索 | タイトル・説明文で検索 | 高 |
| タグ追加 | 記事にタグを付与 | 中 |
| タグフィルタ | タグで絞り込み | 中 |
| 自動タグ提案 | 内容からタグを自動提案 | 低 |

#### Phase 7: AI要約機能

| 機能 | 説明 | 優先度 |
|------|------|--------|
| 記事要約 | AIが記事内容を3行で要約 | 中 |
| キーポイント抽出 | 重要なポイントをリスト化 | 中 |
| 読了時間予測 | 記事の長さから読了時間を推定 | 低 |

#### Phase 8: 知識の可視化

| 機能 | 説明 | 優先度 |
|------|------|--------|
| 知識ポット | 読んだ記事が「ポット」に溜まるUI | 中 |
| 成長アニメーション | 読了するとポットが育つ演出 | 中 |
| 統計ダッシュボード | 週間/月間の読了数グラフ | 中 |
| ストリーク | 連続読了日数の表示 | 低 |
| 実績バッジ | 読了数に応じたバッジ付与 | 低 |

---

## 4. 技術スタック

### 4.1 フレームワーク・言語

| カテゴリ | 技術 | バージョン | 選定理由 |
|----------|------|------------|----------|
| フレームワーク | Flutter | 3.x | iOS/Android両対応、リッチUI |
| 言語 | Dart | 3.2+ | Flutter標準、型安全 |
| iOS Native | Swift | 5.0 | Share Extension実装 |
| Android Native | Kotlin | - | Share Intent実装（予定） |

### 4.2 主要パッケージ

| パッケージ | バージョン | 用途 |
|-----------|------------|------|
| flutter_riverpod | ^2.4.9 | 状態管理 |
| hive_flutter | ^1.1.0 | ローカルデータベース |
| hive | ^2.2.3 | NoSQLストレージ |
| flutter_local_notifications | ^16.3.2 | プッシュ通知 |
| timezone | ^0.9.2 | タイムゾーン処理 |
| metadata_fetch | ^0.4.1 | URLメタデータ取得 |
| http | ^1.2.0 | HTTP通信 |
| cached_network_image | ^3.3.1 | 画像キャッシュ |
| flutter_slidable | ^3.0.1 | スワイプアクション |
| url_launcher | ^6.2.4 | 外部URL起動 |
| uuid | ^4.3.3 | ユニークID生成 |
| intl | ^0.19.0 | 国際化・日付フォーマット |

### 4.3 開発ツール

| ツール | 用途 |
|--------|------|
| build_runner | コード生成 |
| hive_generator | Hive TypeAdapter生成 |
| flutter_lints | 静的解析 |

---

## 5. アーキテクチャ

### 5.1 レイヤード・アーキテクチャ

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Screens   │  │   Widgets   │  │      Providers      │  │
│  │  (画面)      │  │ (UIパーツ)   │  │  (状態管理)          │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                     Service Layer                            │
│  ┌─────────────────────┐  ┌─────────────────────────────┐   │
│  │ NotificationService │  │     MetadataService         │   │
│  │   (通知管理)         │  │   (メタデータ取得)           │   │
│  └─────────────────────┘  └─────────────────────────────┘   │
│  ┌─────────────────────┐                                    │
│  │ ShareIntentService  │                                    │
│  │   (共有受信)         │                                    │
│  └─────────────────────┘                                    │
├─────────────────────────────────────────────────────────────┤
│                       Data Layer                             │
│  ┌─────────────────────┐  ┌─────────────────────────────┐   │
│  │  ArticleRepository  │  │    SettingsRepository       │   │
│  │   (記事データ操作)    │  │    (設定データ操作)          │   │
│  └─────────────────────┘  └─────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                      Storage Layer                           │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                    Hive Database                     │    │
│  │         (articles box / settings box)                │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 ディレクトリ構成

```
lib/
├── main.dart                      # エントリーポイント
├── app.dart                       # MaterialApp設定
│
├── core/                          # アプリ全体で使う共通機能
│   ├── theme/
│   │   └── app_theme.dart         # テーマ・カラー定義
│   └── providers/
│       └── providers.dart         # Riverpodプロバイダー定義
│
├── data/                          # データ層
│   ├── models/
│   │   ├── article.dart           # 記事モデル
│   │   ├── article.g.dart         # Hive TypeAdapter（自動生成）
│   │   ├── reminder_settings.dart # リマインダー設定モデル
│   │   └── reminder_settings.g.dart
│   └── repositories/
│       ├── article_repository.dart    # 記事CRUD操作
│       └── settings_repository.dart   # 設定CRUD操作
│
├── services/                      # ビジネスロジック・外部連携
│   ├── notification_service.dart  # ローカル通知管理
│   ├── metadata_service.dart      # URLメタデータ取得
│   └── share_intent_service.dart  # 共有Intent受信
│
└── presentation/                  # UI層
    ├── screens/
    │   ├── home_screen.dart       # ホーム画面（記事一覧）
    │   ├── add_article_screen.dart # 記事追加画面
    │   └── settings_screen.dart   # 設定画面
    └── widgets/
        ├── article_card.dart      # 記事カードウィジェット
        ├── filter_chips.dart      # フィルターチップ
        └── empty_state.dart       # 空状態表示
```

### 5.3 状態管理（Riverpod）

```dart
// プロバイダー構成図

articlesProvider (StateNotifierProvider)
    │
    ├── filteredArticlesProvider (Provider)  ← articleFilterProvider を監視
    │
    ├── unreadArticlesProvider (Provider)
    │
    ├── readArticlesProvider (Provider)
    │
    └── articleCountsProvider (Provider)

reminderSettingsProvider (StateNotifierProvider)

articleFilterProvider (StateProvider<ArticleFilter>)
```

---

## 6. データモデル

### 6.1 Article（記事）

```dart
@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0)  String id;           // ユニークID
  @HiveField(1)  String url;          // 記事URL
  @HiveField(2)  String title;        // タイトル
  @HiveField(3)  String? description; // 説明文
  @HiveField(4)  String? thumbnailUrl;// サムネイル画像URL
  @HiveField(5)  String? sourceName;  // ソース名（note, Zenn等）
  @HiveField(6)  String? memo;        // ユーザーメモ
  @HiveField(7)  ArticleStatus status;// 未読/読了
  @HiveField(8)  DateTime createdAt;  // 作成日時
  @HiveField(9)  DateTime? readAt;    // 読了日時
  @HiveField(10) List<String> tags;   // タグ（将来用）
}

@HiveType(typeId: 1)
enum ArticleStatus {
  @HiveField(0) unread,  // 未読
  @HiveField(1) read,    // 読了
}
```

### 6.2 ReminderSettings（リマインダー設定）

```dart
@HiveType(typeId: 2)
class ReminderSettings extends HiveObject {
  @HiveField(0) bool enabled;         // 有効/無効
  @HiveField(1) int hour;             // 通知時刻（時）
  @HiveField(2) int minute;           // 通知時刻（分）
  @HiveField(3) ReminderMode mode;    // 記事選択モード
  @HiveField(4) int articleCount;     // 表示記事数
  @HiveField(5) List<int> activeDays; // 有効な曜日（0=月〜6=日）
}

@HiveType(typeId: 3)
enum ReminderMode {
  @HiveField(0) random,  // ランダム
  @HiveField(1) oldest,  // 古い順
  @HiveField(2) newest,  // 新しい順
}
```

### 6.3 ER図

```
┌─────────────────────────────────────────┐
│              articles (Box)              │
├─────────────────────────────────────────┤
│ id: String (PK)                         │
│ url: String (Unique)                    │
│ title: String                           │
│ description: String?                    │
│ thumbnailUrl: String?                   │
│ sourceName: String?                     │
│ memo: String?                           │
│ status: ArticleStatus                   │
│ createdAt: DateTime                     │
│ readAt: DateTime?                       │
│ tags: List<String>                      │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│             settings (Box)               │
├─────────────────────────────────────────┤
│ reminder: ReminderSettings              │
│   - enabled: bool                       │
│   - hour: int                           │
│   - minute: int                         │
│   - mode: ReminderMode                  │
│   - articleCount: int                   │
│   - activeDays: List<int>               │
└─────────────────────────────────────────┘
```

---

## 7. 画面設計

### 7.1 画面一覧

| 画面名 | ファイル | 説明 |
|--------|----------|------|
| ホーム | home_screen.dart | 記事一覧、統計、フィルター |
| 記事追加 | add_article_screen.dart | URL入力、プレビュー、メモ |
| 設定 | settings_screen.dart | リマインダー設定 |

### 7.2 画面遷移図

```
┌─────────────┐
│   ホーム     │
│  (記事一覧)  │
└──────┬──────┘
       │
       ├─────────────────┐
       │                 │
       ▼                 ▼
┌─────────────┐   ┌─────────────┐
│  記事追加    │   │    設定     │
│ (FABタップ)  │   │ (⚙️タップ)  │
└─────────────┘   └─────────────┘
```

### 7.3 ホーム画面詳細

```
┌────────────────────────────────────┐
│  ←  Yommy 📚                    ⚙️ │  AppBar
├────────────────────────────────────┤
│     12        8         4          │  統計バー
│    全て      未読      読了        │
├────────────────────────────────────┤
│  [全て] [未読] [読了]              │  フィルターチップ
├────────────────────────────────────┤
│ ┌────────────────────────────────┐ │
│ │ 🖼️ │ note                 未読 │ │  記事カード
│ │    │ 記事タイトル...           │ │  （スワイプ可能）
│ │    │ 説明文...                 │ │
│ │    │ 📝 メモ...                │ │
│ │    │ 今日                      │ │
│ └────────────────────────────────┘ │
│ ┌────────────────────────────────┐ │
│ │ 🖼️ │ Zenn                 読了 │ │
│ │    │ ...                       │ │
│ └────────────────────────────────┘ │
│                                    │
│                              (＋)  │  FAB
└────────────────────────────────────┘
```

### 7.4 デザインシステム

#### カラーパレット

| 名前 | カラーコード | 用途 |
|------|--------------|------|
| Primary | #FF7B7B | メインカラー（コーラルピンク） |
| Primary Light | #FFADAD | ホバー、アクセント |
| Secondary | #7BCFB5 | サブカラー（ミントグリーン） |
| Accent | #FFD93D | 強調（イエロー） |
| Background | #FFFBF5 | 背景色（ライトモード） |
| Unread Badge | #FF7B7B | 未読バッジ |
| Read Badge | #7BCFB5 | 読了バッジ |

#### タイポグラフィ

- フォント: Noto Sans JP（日本語対応）
- 見出し: Bold
- 本文: Regular

---

## 8. 開発ロードマップ

### 8.1 フェーズ概要

```
Phase 1-3 ✅ コア機能
    │
    ▼
Phase 4 ✅ iOS Share Extension
    │
    ▼
Phase 5 🔲 Android Share Intent
    │
    ▼
Phase 6 🔲 検索・タグ機能
    │
    ▼
Phase 7 🔲 AI要約機能
    │
    ▼
Phase 8 🔲 知識の可視化
    │
    ▼
v1.0 リリース 🚀
```

### 8.2 詳細スケジュール

| Phase | 機能 | ステータス | 工数目安 |
|-------|------|------------|----------|
| 1 | プロジェクト設計・基盤構築 | ✅ 完了 | 1日 |
| 2 | 記事保存・管理機能 | ✅ 完了 | 2日 |
| 3 | リマインダー通知機能 | ✅ 完了 | 1日 |
| 4 | iOS Share Extension | ✅ 完了 | 1日 |
| 5 | Android Share Intent | 🔲 未着手 | 1日 |
| 6 | 検索・タグ機能 | 🔲 未着手 | 2日 |
| 7 | AI要約機能 | 🔲 未着手 | 3日 |
| 8 | 知識の可視化 | 🔲 未着手 | 3日 |

### 8.3 将来の拡張案

- **クラウド同期**: Firebase等でデバイス間同期
- **ウィジェット**: ホーム画面ウィジェット
- **Apple Watch対応**: 通知からサッと読了マーク
- **ブラウザ拡張**: Chrome/Safari拡張で保存
- **Pocket/Instapaper連携**: 既存サービスからインポート

---

## 9. セットアップ手順

### 9.1 前提条件

- Flutter SDK 3.x 以上
- Xcode 15+ (iOS開発)
- Android Studio (Android開発)
- CocoaPods (iOS依存関係管理)

### 9.2 環境構築

```bash
# リポジトリをクローン
git clone <repository-url>
cd yommy

# 依存関係をインストール
flutter pub get

# Hive TypeAdapterを生成
flutter pub run build_runner build

# iOS依存関係をインストール
cd ios
pod install
cd ..
```

### 9.3 iOS固有の設定

#### Info.plist（通知許可）

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

#### App Groups設定

1. Xcode で Runner ターゲットを選択
2. Signing & Capabilities → + Capability → App Groups
3. `group.com.example.yommy` を追加
4. YommyShare ターゲットにも同様に追加

### 9.4 Android固有の設定

#### AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### 9.5 実行

```bash
# iOS シミュレータで実行
flutter run -d ios

# Android エミュレータで実行
flutter run -d android

# デバッグビルド
flutter build ios --debug
flutter build apk --debug
```

---

## 10. リリース計画

### 10.1 App Store 提出準備

| 項目 | 状態 | 備考 |
|------|------|------|
| Apple Developer登録 | 🔲 | 年間$99 |
| App ID作成 | 🔲 | com.example.yommy |
| 証明書・Provisioning Profile | 🔲 | |
| App Store Connect登録 | 🔲 | |
| スクリーンショット | 🔲 | 6.5", 5.5" 必須 |
| アプリ説明文 | 🔲 | 日本語/英語 |
| プライバシーポリシー | 🔲 | URL必須 |
| アプリアイコン | 🔲 | 1024x1024 |

### 10.2 Google Play 提出準備

| 項目 | 状態 | 備考 |
|------|------|------|
| Google Developer登録 | 🔲 | 一回$25 |
| 署名鍵作成 | 🔲 | keystore |
| Google Play Console登録 | 🔲 | |
| スクリーンショット | 🔲 | 電話、タブレット |
| アプリ説明文 | 🔲 | 日本語/英語 |
| コンテンツレーティング | 🔲 | 質問回答 |
| プライバシーポリシー | 🔲 | URL必須 |

### 10.3 リリースチェックリスト

- [ ] 全機能の動作確認
- [ ] クラッシュレポートツール導入（Firebase Crashlytics等）
- [ ] パフォーマンステスト
- [ ] 多言語対応（日本語/英語）
- [ ] アクセシビリティ対応
- [ ] プライバシーポリシー作成
- [ ] 利用規約作成
- [ ] ベータテスト実施

---

## 付録

### A. 参考リンク

- [Flutter 公式ドキュメント](https://docs.flutter.dev/)
- [Riverpod ドキュメント](https://riverpod.dev/)
- [Hive ドキュメント](https://docs.hivedb.dev/)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)

### B. 変更履歴

| バージョン | 日付 | 変更内容 |
|------------|------|----------|
| 0.1.0 | 2026-01-08 | 初版作成、Phase 1-4 完了 |

### C. 用語集

| 用語 | 説明 |
|------|------|
| Share Extension | iOSの共有機能を拡張するApp Extension |
| App Groups | 複数のアプリ間でデータを共有する仕組み |
| TypeAdapter | Hiveでカスタムオブジェクトを保存するためのアダプター |
| StateNotifier | Riverpodで状態を管理するクラス |

---

**© 2026 Yommy Project**
