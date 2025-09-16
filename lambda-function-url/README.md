# Lambda + Function URL (API Gatewayなし)

**目的**: 最小構成のHTTPエンドポイントを作成して、サーバレスの基本を把握する。

## 手順
- `scripts/deploy.sh` で関数と実行ロールを作成
- `scripts/open.sh` で Function URL を公開に変更（学習用）
- `scripts/destroy.sh` で削除

> ログの保持期間は 7日 に設定 (課金最小化)。
