# AWS Hands-on Starters (SAA Practice)

**目的**: Udemyで学んだ内容を「再現可能( reproducible )」な成果物として残すスターター。**コスト最小** & **Always Free**中心。

## 内容
- `s3-static-website/` — S3静的サイト (HTTP)。学習後は公開を**元に戻す/削除**。
- `lambda-function-url/` — Lambda + Function URL (API Gatewayなし)。
- `security-access-analyzer/` — Access Analyzer 有効化 & 発見項目チェック。

## 使い方（共通）
```bash
git init
git add .
git commit -m "add: aws hands-on starters"
# GitHubに新規リポジトリを作って push
```
> すべてのスクリプトは **ap-northeast-1 (Tokyo)** 前提。別リージョンは `REGION` を変更してください。
> 学習後は `teardown.sh` / `destroy.sh` で**必ず後片付け**。
