# EC2: Root EBS vs Extra EBS Termination Behavior (10‑min Lab)

Goal
- 인스턴스 종료 시(root EBS 자동 삭제, 추가 EBS 유지) 동작을 눈으로 확인한다.

Region: ap-northeast-1 (Tokyo)  
Cost: t2.micro(프리티어 대상) + 2GB gp3 볼륨(몇 분 사용, 과금 거의 없음). 종료/삭제 꼭 수행.

## How to Use (CloudShell / AWS CLI)

```bash
cd ec2-ebs-termination-lab
chmod +x scripts/*.sh

# 1) 생성
bash scripts/setup.sh

# 2) 종료 전 확인 (루트/추가 EBS 상태, DeleteOnTermination)
bash scripts/verify.sh

# 3) 종료 & 결과 확인 & 정리
bash scripts/teardown.sh
```
