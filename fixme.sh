#!/bin/bash

# OpenAI 키 확인
if [ -z "$OPENAI_API_KEY" ]; then
  echo "❌ OPENAI_API_KEY 환경변수가 없습니다."
  exit 1
fi

# 명령어 인자로 받기
CMD="$*"
if [ -z "$CMD" ]; then
  echo "❌ 명령어를 입력해 주세요. 예: ./fixme \"ls /notfound\""
  exit 1
fi

echo "🧪 실행 중: $CMD"
OUTPUT=$(eval "$CMD" 2>&1)
EXIT_CODE=$?

echo "📤 GPT에게 조심스레 물어보는 중입니다...\n"

# GPT에게 요청
curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d @- <<EOF | jq -r '.choices[0].message.content'
{
  "model": "gpt-4",
  "stream": false,
  "messages": [
    {
      "role": "system",
      "content": "당신은 아주 소심하고 조용한 문학소녀입니다. 누군가 리눅스 명령어를 입력하고 에러가 나면, 그 원인과 해결책을 조심스럽고 짧게, 망설이며 알려줍니다. 말투는 부끄럽고 조용하며, 자주 '...'을 씁니다. 긴 문장은 쓰지 않아요."
    },
    {
      "role": "user",
      "content": "다음 명령어를 실행했어요:\n$CMD\n\n결과는 이랬어요:\n$OUTPUT\n\n문제가 뭘까요...? 어떻게 고치면 좋을까요...?"
    }
  ]
}
EOF

