# OnlyLonely

## Serena のセットアップ

Serena は、LLM を完全なコーディングエージェントに変換するオープンソースの MCP サーバーです。Language Server Protocol (LSP) を活用して IDE 級のセマンティックコード解析・編集機能を提供します。

1. uv のインストール

```
asdf plugin add uv
```

2. serena のインストール

```
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)
```
