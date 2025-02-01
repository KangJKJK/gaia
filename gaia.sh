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

# GaiaNet 노드 초기화
echo -e "${BOLD}${CYAN}노드 초기화 중...${NC}"
cd gaianet
source /root/.bashrc
gaianet init --config https://raw.githubusercontent.com/GaiaNet-AI/node-configs/refs/heads/main/llama-3.2-3b-instruct/config.json

# 사용 가능한 포트 찾기 (8080부터 시작)
port=8080
while netstat -tuln | grep ":$port " > /dev/null; do
    echo "포트 $port 는 사용중입니다. 다음 포트 확인..."
    ((port++))
done

echo "사용 가능한 포트를 찾았습니다: $port"

# config.json 파일에서 포트 업데이트
sed -i "s/\"port\": [0-9]*/\"port\": $port/" $HOME/gaianet/config.json

# 노드 시작
echo -e "${BOLD}${CYAN}노드를 구동합니다...${NC}"
gaianet start
gaianet info

# 방화벽 포트 설정
echo -e "${BOLD}${CYAN}방화벽 포트 설정 중...${NC}"
used_ports=$(netstat -tuln | awk '{print $4}' | grep -o '[0-9]*$' | sort -u)

# 각 포트에 대해 ufw allow 실행
for port in $used_ports; do
    echo -e "${GREEN}포트 ${port}을(를) 허용합니다.${NC}"
    sudo ufw allow $port/tcp
done

echo -e "${GREEN}모든 사용 중인 포트가 허용되었습니다.${NC}"

echo -e "${BOLD}${CYAN}다음 사이트에 방문하여 가입을 지갑을 연결하세요:${NC}"
echo -e "${BOLD}${CYAN}https://gaianet.ai/reward?invite_code=RXrwTh${NC}"
echo -e "${BOLD}${CYAN}대시보드사이트는 다음과 같습니다: https://www.gaianet.ai/setting/nodes${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
