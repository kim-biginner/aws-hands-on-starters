# AWS Hands-on Starters (SAA 対策)

**目的**: Udemy で学んだ内容を **再現可能 (reproducible)** な成果物として残すスターター集。  
**コスト最小化** & **Always Free 対象サービス中心**。

## ラボ一覧
- [VPC 基本 — Public/Private + IGW + S3 Gateway](./vpc-basics/README.md)
- [S3 静的ウェブサイトホスティング](./s3-static-website/README.md)
- [Lambda Function URL](./lambda-function-url/README.md)
- [Security Access Analyzer — クイックチェック](./security-access-analyzer/README.md)
- [EC2: Root EBS と追加 EBS の終了挙動 (10分ラボ)](./ec2-ebs-termination-lab/README.md)

## 利用方法（共通）
```bash
git init
git add .
git commit -m "add: aws hands-on starters"
# GitHub に新規リポジトリを作成して push
> すべてのスクリプトは ap-northeast-1 (Tokyo) 前提。他リージョンを利用する場合は REGION 環境変数を変更してください。
> 学習後は teardown.sh / destroy.sh で 必ず後片付け。
