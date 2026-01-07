# Yommy 📚

読みたいけど今は読めない記事をためて、あとでリマインドしてくれるかわいいアプリ。

## 機能

- ✅ URLを入力して記事を保存
- ✅ タイトル・サムネイルを自動取得
- ✅ 未読/読了の管理
- ✅ 毎日決まった時間に通知でリマインド
- ✅ ランダム or 順番で記事を選択
- 🔜 他アプリからの共有で追加（Phase 4）
- 🔜 知識の可視化（将来機能）

## セットアップ

### 1. Flutterプロジェクトを作成

```bash
flutter create yommy
cd yommy
```

### 2. 既存ファイルを置き換え

このプロジェクトのファイルを、作成した `yommy` フォルダにコピーしてください。

### 3. 依存関係をインストール

```bash
flutter pub get
```

### 4. アセットフォルダを作成

```bash
mkdir -p assets/images
mkdir -p assets/fonts
```

フォントを使う場合は、NotoSansJP を `assets/fonts/` に配置してください。
使わない場合は `pubspec.yaml` の `fonts:` セクションを削除してください。

### 5. iOS設定（通知用）

`ios/Runner/Info.plist` に以下を追加:

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

### 6. Android設定（通知用）

`android/app/src/main/AndroidManifest.xml` の `<manifest>` 内に追加:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### 7. 実行

```bash
flutter run
```

## プロジェクト構成

```
lib/
├── main.dart              # エントリーポイント
├── app.dart               # アプリルート
├── core/
│   ├── theme/
│   │   └── app_theme.dart    # テーマ・カラー定義
│   └── providers/
│       └── providers.dart    # Riverpod プロバイダー
├── data/
│   ├── models/
│   │   ├── article.dart      # 記事モデル
│   │   └── reminder_settings.dart  # 設定モデル
│   └── repositories/
│       ├── article_repository.dart   # 記事データ操作
│       └── settings_repository.dart  # 設定データ操作
├── services/
│   ├── notification_service.dart  # 通知管理
│   └── metadata_service.dart      # URLメタデータ取得
└── presentation/
    ├── screens/
    │   ├── home_screen.dart       # ホーム画面
    │   ├── add_article_screen.dart # 記事追加画面
    │   └── settings_screen.dart   # 設定画面
    └── widgets/
        ├── article_card.dart      # 記事カード
        ├── filter_chips.dart      # フィルター
        └── empty_state.dart       # 空状態
```

## 技術スタック

- **Flutter** - クロスプラットフォームUI
- **Riverpod** - 状態管理
- **Hive** - ローカルデータベース
- **flutter_local_notifications** - ローカル通知
- **metadata_fetch** - URLメタデータ取得
- **cached_network_image** - 画像キャッシュ
- **flutter_slidable** - スワイプアクション

## 次のステップ

### Phase 4: Share Extension
他のアプリから「共有」で記事を追加できるようにする。

### 将来機能
- AI要約機能
- 知識の可視化（ポットに知識が溜まるUI）
- タグ機能
- 検索機能
