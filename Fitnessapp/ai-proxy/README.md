# Fitnessapp AI Proxy

Small local/backend proxy for DeepSeek. The iOS app must call this proxy, not DeepSeek directly, so the AI API key never ships inside the app.

## Setup

1. Rotate the API key that was pasted into chat.
2. Create `.env` from `.env.example`. The proxy auto-loads `.env` from this folder.
3. Start the proxy:

```sh
npm start
```

The proxy listens on `http://127.0.0.1:8787` by default.

## Model routing

Set different models in `.env`:

```sh
DEEPSEEK_CHAT_MODEL=flash
DEEPSEEK_FLASH_MODEL=deepseek-chat
DEEPSEEK_RECOMMENDATION_MODEL=pro
DEEPSEEK_PRO_MODEL=deepseek-v4-pro
```

`flash` and `pro` are local aliases. Change `DEEPSEEK_FLASH_MODEL` or `DEEPSEEK_PRO_MODEL` if DeepSeek gives you a different exact model id.

## Endpoints

- `GET /health`
- `POST /chat`
- `POST /recommendation`

For physical iPhone testing, host this on a reachable backend URL or expose the Mac's LAN IP and update the iOS service base URL. Do not put `DEEPSEEK_API_KEY` in Swift, plist files, or Firebase client config.
