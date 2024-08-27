# AI-Shell
AI-Shell 是一个基于 OpenAI 的自然语言处理能力开发的命令行工具，旨在简化 Linux 命令的使用。通过 AI-Shell，用户可以通过自然语言直接在终端中执行复杂的 Linux 命令，而无需记住繁琐的命令语法。

### 特性：
- **自然语言命令**：输入自然语言描述，即可生成并执行相应的 Linux 命令。
- **智能命令补全**：基于上下文理解，自动生成最合适的命令。
- **可扩展性**：支持自定义命令和语义映射，适应多种应用场景。
- **开箱即用**：简单易用的命令行工具，适合从初学者到高级用户。

### 用法示例：
```bash
# 用自然语言查询系统状态
ais 检查磁盘使用情况

# 安装软件包
ais 安装最新版本的git

# 查找特定文件
ais "在当前目录下查找所有的 .txt 文件"
```
## 安装指南

你可以选择以下任意一种方式来安装 AI-Shell：

### 方式 1: 安装到 `/usr/local/bin`

使用以下命令将脚本下载到 `/usr/local/bin` 目录，并赋予执行权限：

```bash
sudo wget -q -O /usr/local/bin/ais https://raw.githubusercontent.com/by123456by/AI-Shell/main/AI-Shell.sh && sudo chmod +x /usr/local/bin/ais
```

### 方式 2: 安装到 `~/bin`

如果你更喜欢将脚本安装到用户目录下，可以使用以下命令：

```bash
mkdir -p ~/bin && wget -q -O ~/bin/ais https://raw.githubusercontent.com/by123456by/AI-Shell/main/AI-Shell.sh && chmod +x ~/bin/ais && echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

此方式会将脚本安装到 `~/bin` 目录，并自动将该目录添加到你的 `PATH` 环境变量中。

## 配置命令

AIS 提供了几种简单的命令用于配置 AI 服务：

- **设置 API 地址**: 使用 `ais seturl <URL>` 配置 AI 服务的 API 地址。
  ```bash
  ais seturl https://api.openai.com/v1/chat/completions
  ```

- **设置 API 密钥**: 使用 `ais setkey <API_KEY>` 设置你的 OpenAI API 密钥。
  ```bash
  ais setkey sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ```

- **选择模型**: 使用 `ais setmodel <MODEL_NAME>` 指定使用的 AI 模型（例如 `gpt-3.5-turbo` 或 `gpt-4`）。
  ```bash
  ais setmodel gpt-4
  ```

## 贡献

欢迎提交问题、建议或 PR 来改善 AI-Shell。我们希望与开源社区共同发展，让 AI-Shell 更加强大和易用。

## 尾巴

以上所有内容及脚本代码均通过AI完成。
