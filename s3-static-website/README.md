# S3 Static Website (学習用)

**目的**: S3の静的サイトホスティングを体験し、公開→確認→元に戻す(または削除)の一連の流れを残す。

## 手順
- `scripts/setup.sh` で作成と公開設定
- `website/index.html` / `error.html` をアップロード
- `scripts/teardown.sh` で非公開化 or 削除

## 注意
- ウェブサイトエンドポイントは **HTTP** のみ (HTTPSは CloudFront + OACを利用)。
- 公開は学習のための一時措置。終了後は **非公開化** または **バケット削除**。
