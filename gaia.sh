#!/bin/bash

# 터미널 출력 색상 정의
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # 색상 초기화

# 시스템 업데이트 및 필수 패키지 설치
echo -e "${BOLD}${CYAN}시스템 업데이트 및 필수 패키지 설치 중...${NC}"
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get install -y ufw curl wget git build-essential

# GaiaNet 노드 설치
echo -e "${BOLD}${CYAN}GaiaNet 노드 설치 중...${NC}"
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
source /root/.bashrc

# 환경 변수 설정
export PATH=$PATH:/root/gaianet
cd /root/gaianet

# GaiaNet 노드 초기화
echo -e "${BOLD}${CYAN}노드 초기화 중...${NC}"
source /root/.bashrc
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/refs/heads/main/llama-3.2-3b-instruct/config.json

# 사용 가능한 포트 찾기 (8080부터 시작)
port=8080
while netstat -tuln | grep ":$port " > /dev/null; do
    echo "포트 $port 는 사용중입니다. 다음 포트 확인..."
    ((port++))
done

echo "사용 가능한 포트를 찾았습니다: $port"

# config.json 파일에서 포트 업데이트 (llamaedge_port로 수정)
sed -i "s/\"llamaedge_port\": \"[0-9]*\"/\"llamaedge_port\": \"$port\"/" $HOME/gaianet/config.json

# GaiaNet 시작
echo "포트 $port 로 GaiaNet을 시작합니다..."
gaianet init
gaianet start
gaianet info

echo -e "${BOLD}${YELLOW}위의 Node ID와 Device ID를 반드시 메모해두세요!${NC}"
echo -e "${BOLD}${YELLOW}메모를 완료하셨다면 엔터를 눌러주세요...${NC}"
read -p ""

# 방화벽 포트 설정
echo -e "${BOLD}${CYAN}방화벽 포트 설정 중...${NC}"
used_ports=$(netstat -tuln | awk '{print $4}' | grep -o '[0-9]*$' | sort -u)

# 각 포트에 대해 ufw allow 실행
for port in $used_ports; do
    echo -e "${GREEN}포트 ${port}을(를) 허용합니다.${NC}"
    sudo ufw allow $port/tcp
done

echo -e "${GREEN}모든 사용 중인 포트가 허용되었습니다.${NC}"

echo -e "${BOLD}${CYAN}1.다음 사이트에 방문하여 지갑을 연결하세요: https://gaianet.ai/reward?invite_code=RXrwTh${NC}"
echo -e "${BOLD}${CYAN}2.퀘스트를 수행하여 리워드를 획득하세요.${NC}"
echo -e "${BOLD}${CYAN}3.노드를 연동하세요: https://www.gaianet.ai/setting/nodes${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
