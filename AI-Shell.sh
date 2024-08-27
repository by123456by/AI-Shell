#!/bin/bash

# 检查命令是否存在的函数
check_command() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "错误: $1 未安装。请安装它以继续使用。"
        exit 1
    }
}

# 检查依赖
check_command "curl"
check_command "jq"

CONFIG_DIR="$HOME/.config"
CONFIG_FILE="$CONFIG_DIR/ais_config"
DEFAULT_URL="https://api.openai.com/v1/chat/completions"  # 默认 URL
DEFAULT_MODEL="gpt-4o-mini"
DEFAULT_MAX_TOKENS=1000
DEFAULT_TEMPERATURE=0.7

# 检查配置目录是否存在，如果不存在则创建
if [ ! -d "$CONFIG_DIR" ]; then
    sudo mkdir -p "$CONFIG_DIR"
fi

# 检查配置文件是否存在，如果不存在则创建
if [ ! -f "$CONFIG_FILE" ]; then
    sudo touch "$CONFIG_FILE"
    echo "初次使用请提供 URL、API_KEY、模型。"
fi

# 读取配置文件的函数
read_config() {
    local key="$1"
    grep "^$key=" "$CONFIG_FILE" | cut -d'=' -f2
}

# 写入配置文件的函数
write_config() {
    local key="$1"
    local value="$2"
    if grep -q "^$key=" "$CONFIG_FILE"; then
        # 如果存在，更新
        sed -i "s/^$key=.*/$key=$value/" "$CONFIG_FILE"
    else
        # 如果不存在，添加
        echo "$key=$value" >> "$CONFIG_FILE"
    fi
}

# 从配置文件读取配置
URL=$(read_config "URL")
API_KEY=$(read_config "API_KEY")
MODEL=$(read_config "MODEL")
MAX_TOKENS=$(read_config "MAX_TOKENS")
TEMPERATURE=$(read_config "TEMPERATURE")

# 处理命令行参数
case "$1" in
    seturl)
        if [ -n "$2" ]; then
            URL="$2"
            write_config "URL" "$URL"
            echo "已设置 URL: $URL"
            exit 0
        else
            echo "请提供 URL。"
            exit 1
        fi
        ;;
    setkey)
        if [ -n "$2" ]; then
            API_KEY="$2"
            write_config "API_KEY" "$API_KEY"
            echo "已设置 API_KEY: $API_KEY"
            exit 0
        else
            echo "请提供 API_KEY。"
            exit 1
        fi
        ;;
    setmodel)
        if [ -n "$2" ]; then
            MODEL="$2"
            write_config "MODEL" "$MODEL"
            echo "已设置模型: $MODEL"
            exit 0
        else
            echo "请提供模型。"
            exit 1
        fi
        ;;
    setmax)
        if [ -n "$2" ]; then
            MAX_TOKENS="$2"
            write_config "MAX_TOKENS" "$MAX_TOKENS"
            echo "已设置 MAX_TOKENS: $MAX_TOKENS"
            exit 0
        else
            echo "请提供 MAX_TOKENS。"
            exit 1
        fi
        ;;
    settemp)
        if [ -n "$2" ]; then
            TEMPERATURE="$2"
            write_config "TEMPERATURE" "$TEMPERATURE"
            echo "已设置 TEMPERATURE: $TEMPERATURE"
            exit 0
        else
            echo "请提供 TEMPERATURE。"
            exit 1
        fi
        ;;
esac

# 如果 URL 为空，提示用户输入
if [ -z "$URL" ]; then
    read -r -p "请输入 URL (留空则使用默认地址 $DEFAULT_URL): " URL
    if [ -z "$URL" ]; then
        URL="$DEFAULT_URL"
    fi
    write_config "URL" "$URL"
fi

# 如果 API_KEY 为空，提示用户输入，直到输入有效
if [ -z "$API_KEY" ]; then
    while [ -z "$API_KEY" ]; do
        read -r -p "请输入 API_KEY: " API_KEY
    done
    write_config "API_KEY" "$API_KEY"
fi

# 如果 MODEL 为空，提示用户输入，直到输入有效
if [ -z "$MODEL" ]; then
    read -r -p "请输入模型 (留空则使用默认值 $DEFAULT_MODEL): " MODEL
    if [ -z "$MODEL" ]; then
        MODEL="$DEFAULT_MODEL"
    fi
    write_config "MODEL" "$MODEL"
fi

# 如果 MAX_TOKENS 为空，设置为默认值
if [ -z "$MAX_TOKENS" ]; then
    MAX_TOKENS="$DEFAULT_MAX_TOKENS"
    write_config "MAX_TOKENS" "$MAX_TOKENS"
fi

# 如果 TEMPERATURE 为空，设置为默认值
if [ -z "$TEMPERATURE" ]; then
    TEMPERATURE="$DEFAULT_TEMPERATURE"
    write_config "TEMPERATURE" "$TEMPERATURE"
fi

# 检查是否有额外的参数作为 POST 请求的主体
if [ -n "$1" ] && [ "$1" != "seturl" ] && [ "$1" != "setkey" ] && [ "$1" != "setmodel" ] && [ "$1" != "setmax" ] && [ "$1" != "settemp" ]; then
    USER_MESSAGE="$1"
else
    echo "请输入你要执行的操作。"
    exit 1
fi
# 函数：替换换行符和制表符
replace_newline_tab() {
    local input_string="$1"

    # 使用 printf 将字符串中的换行符和制表符替换为 \\n 和空格
    output_string=$(printf "%s" "$input_string" | sed ':a;N;$!ba;s/\n/\\n/g;s/\t/ /g')

    echo "$output_string"
}

release=$(lsb_release -a)
release=$(replace_newline_tab "$release")
id=$(id)
id=$(replace_newline_tab "$id")
ls=$(ls -aF)
ls=$(replace_newline_tab "$ls")
pwd=$(pwd)
pwd=$(replace_newline_tab "$pwd")

data=$(cat <<EOF
{
    "model": "$MODEL",
    "messages": [
        {
            "role": "system",
            "content": "你是一个命令行命令翻译机，负责将用户输入翻译为命令行命令，你需要以json方式回复，以下是示例\n{\\"command\\": [\\"ls\\"],\\"msg\\": \\"执行此命令将列出当前目录中的文件和子目录。\\",\\"code\\": 0}\ncommand是可执行命令，可以有多种翻译结果，每一项都是完整的命令，不要把一条命令拆分为开，用户选择其中一条执行，最多为10个，msg是展示给用户的提示信息，code为翻译结果，0为成功翻译，1为不能翻译、缺少信息或其他异常情况。"
        },
        {
            "role": "system",
            "content": "以下是系统信息\n[echo \$SHELL]\n$SHELL\n[lsb_release -a]\n$release\n[id]\n$id\n[ls -aF]\n$ls\n[pwd]\n$pwd"
        },
        {
            "role": "user",
            "content": "当前用户"
        },
        {
            "role": "assistant",
            "content": "{\\"command\\":[ \\"whoami\\"],\\"msg\\": \\"此命令将显示当前用户的用户名。\\",\\"code\\": 0}"
        },
        {
            "role": "user",
            "content": "$USER_MESSAGE"
        }
    ],
    "max_tokens": $MAX_TOKENS,
    "temperature": $TEMPERATURE,
    "stream": false
}
EOF
)

# 创建一个临时文件
temp_file=$(mktemp /tmp/response_body.XXXXXX)

# 发送 POST 请求
response=$(curl -s -w "%{http_code}" -o "$temp_file" "$URL" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $API_KEY" \
-d "$data")

# 将响应体保存到变量
response_body=$(<"$temp_file")
rm "$temp_file"

# 判断状态码
if [ "$response" -ne 200 ]; then
  echo "错误: 请求失败: $response_body"
  exit 1
fi

# 使用 jq 提取 content 字段
content=$(echo "$response_body" | jq -r '.choices[0].message.content')


# 使用jq解析JSON
msg=$(echo "$content" | jq -r '.msg')
code=$(echo "$content" | jq -r '.code')
commands=$(echo "$content" | jq -r '.command')

# 输出msg
echo "$msg"

# 判断code是否不等于0
if [ "$code" -ne 0 ]; then
    exit 1
fi

# 输出命令选项
length=$(echo "$commands" | jq 'length')
for (( i=0; i<length; i++ )); do
    command=$(echo "$commands" | jq -r ".[$i]")
    echo "$((i + 1)): $command"
done
echo "0 : 退出"

# 提示用户选择
read -r -p "请选择要执行的命令: " choice

# 根据用户选择执行对应的命令
if [ "$choice" -eq 0 ]; then
    echo "退出程序。"
    exit 0
elif [ "$choice" -ge 1 ] && [ "$choice" -le "$length" ]; then
    selected_command=$(echo "$commands" | jq -r ".[$((choice - 1))]")
    echo "执行命令: $selected_command"
    export TERM=xterm-256color
    bash -i -c "$selected_command"
else
    echo "无效的选择，退出程序。"
    exit 1
fi
