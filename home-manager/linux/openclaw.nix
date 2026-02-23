{ inputs, config, lib, pkgs, ... }:
let
  secretsDir = "${config.home.homeDirectory}/.config/openclaw";
  telegramUserId = 5135194752;
  openclawConfig = "${config.home.homeDirectory}/.openclaw/openclaw.json";
in
{
  imports = [ inputs.nix-openclaw.homeManagerModules.openclaw ];

  programs.openclaw = {
    enable = true;

    # Enable systemd user service on Linux
    systemd.enable = true;

    # Gateway configuration
    config = {
      gateway = {
        mode = "local";
      };

      # Model providers
      models.providers = {
        # NVIDIA NIM - Kimi K2.5 (free tier, OpenAI-compatible)
        nvidia = {
          baseUrl = "https://integrate.api.nvidia.com/v1";
          api = "openai-completions";
          models = [
            { id = "moonshotai/kimi-k2.5"; name = "Kimi K2.5"; contextWindow = 131072; maxTokens = 8192; }
          ];
        };

        # Anthropic Claude (API key injected from secrets.env via activation script)
        anthropic = {
          baseUrl = "https://api.anthropic.com";
          api = "anthropic-messages";
          models = [
            { id = "claude-haiku-4-5"; name = "Claude Haiku 4.5"; contextWindow = 65536; maxTokens = 4096; }
            { id = "claude-sonnet-4-5"; name = "Claude Sonnet 4.5"; contextWindow = 131072; maxTokens = 8192; }
            { id = "claude-opus-4-5"; name = "Claude Opus 4.5"; contextWindow = 131072; maxTokens = 8192; }
          ];
        };

        # Google Gemini (API key injected from secrets.env via activation script)
        google = {
          baseUrl = "https://generativelanguage.googleapis.com";
          api = "google-generative-ai";
          models = [
            { id = "gemini-3-flash-preview"; name = "Gemini 3 Flash"; contextWindow = 131072; maxTokens = 8192; }
            { id = "gemini-2.5-pro"; name = "Gemini 2.5 Pro"; contextWindow = 131072; maxTokens = 8192; }
          ];
        };

        # Ollama (local GPU - free)
        ollama = {
          baseUrl = "http://127.0.0.1:11434";
          api = "ollama";
          apiKey = "ollama-local";
          models = [
            { id = "qwen2.5:14b"; name = "Qwen 2.5 14B"; contextWindow = 32768; maxTokens = 4096; }
          ];
        };
      };

      # Default agent settings
      agents.defaults = {
        # Default to Kimi K2.5 (free via NVIDIA NIM)
        model.primary = "nvidia/moonshotai/kimi-k2.5";

        # Fallback chain: free cloud → local GPU → paid cloud (last resort)
        model.fallbacks = [
          "google/gemini-3-flash-preview"
          "ollama/qwen2.5:14b"
          "anthropic/claude-haiku-4-5"
        ];

        # Model aliases for quick switching (e.g. /model sonnet in Telegram)
        models = {
          "nvidia/moonshotai/kimi-k2.5"   = { alias = "kimi"; };
          "anthropic/claude-haiku-4-5"     = { alias = "haiku"; };
          "anthropic/claude-sonnet-4-5"    = { alias = "sonnet"; };
          "anthropic/claude-opus-4-5"      = { alias = "opus"; };
          "google/gemini-3-flash-preview"  = { alias = "flash"; };
          "google/gemini-2.5-pro"          = { alias = "pro"; };
          "ollama/qwen2.5:14b"             = { alias = "qwen"; };
        };

        # Hard cap on context sent to any model
        contextTokens = 65536;

        workspace = "${config.home.homeDirectory}/.openclaw/workspace";

        # Heartbeat (free via Ollama - Qwen 14B already loaded in VRAM)
        heartbeat = {
          every = "55m";
          model = "ollama/qwen2.5:14b";
          session = "main";
          prompt = "Check: Any blockers, opportunities, or progress updates?";
        };

        # Context pruning (cache-aware)
        contextPruning = {
          mode = "cache-ttl";
          ttl = "60m";
        };

        # Compaction strategy - aggressive token saving
        compaction = {
          mode = "safeguard";
          keepRecentTokens = 4000;
          maxHistoryShare = 0.6;
          reserveTokens = 2048;
          reserveTokensFloor = 1024;
          memoryFlush = {
            enabled = true;
            softThresholdTokens = 32000;
          };
        };

        # Memory search - Ollama local embeddings via OpenAI-compatible endpoint
        memorySearch = {
          enabled = true;
          provider = "openai";
          model = "nomic-embed-text:latest";
          remote = {
            baseUrl = "http://127.0.0.1:11434/v1";
            apiKey = "ollama-local";
          };
          sources = [ "memory" "sessions" ];
          fallback = "none";
        };
      };

      # Enable Telegram plugin (required since OpenClaw 2026.2.22+)
      plugins.entries.telegram.enabled = true;

      # Telegram channel
      channels.telegram = {
        tokenFile = "${secretsDir}/telegram-token";
        allowFrom = [ telegramUserId ];
        defaultTo = telegramUserId;
        dmPolicy = "allowlist";
      };
    };
  };

  # Inject API keys from secrets.env into the Nix-generated openclaw config.
  # Runs after home-manager writes the config file.
  home.activation.openclawApiKeys = lib.hm.dag.entryAfter [ "openclawConfigFiles" ] ''
    if [ -f "${secretsDir}/secrets.env" ] && [ -f "${openclawConfig}" ]; then
      # Inject Gemini API key
      GEMINI_KEY=$(${pkgs.gnugrep}/bin/grep -m1 '^GEMINI_API_KEY=' "${secretsDir}/secrets.env" | cut -d= -f2-)
      if [ -n "$GEMINI_KEY" ]; then
        ${pkgs.jq}/bin/jq --arg k "$GEMINI_KEY" '.models.providers.google.apiKey = $k' \
          "${openclawConfig}" > "${openclawConfig}.tmp" && \
          mv "${openclawConfig}.tmp" "${openclawConfig}"
      fi

      # Inject Anthropic API key
      ANTHROPIC_KEY=$(${pkgs.gnugrep}/bin/grep -m1 '^ANTHROPIC_API_KEY=' "${secretsDir}/secrets.env" | cut -d= -f2-)
      if [ -n "$ANTHROPIC_KEY" ]; then
        ${pkgs.jq}/bin/jq --arg k "$ANTHROPIC_KEY" '.models.providers.anthropic.apiKey = $k' \
          "${openclawConfig}" > "${openclawConfig}.tmp" && \
          mv "${openclawConfig}.tmp" "${openclawConfig}"
      fi

      # Inject NVIDIA API key
      NVIDIA_KEY=$(${pkgs.gnugrep}/bin/grep -m1 '^NVIDIA_API_KEY=' "${secretsDir}/secrets.env" | cut -d= -f2-)
      if [ -n "$NVIDIA_KEY" ]; then
        ${pkgs.jq}/bin/jq --arg k "$NVIDIA_KEY" '.models.providers.nvidia.apiKey = $k' \
          "${openclawConfig}" > "${openclawConfig}.tmp" && \
          mv "${openclawConfig}.tmp" "${openclawConfig}"
      fi
    fi
  '';

  # Add EnvironmentFile to the openclaw systemd service for gateway token + API keys
  systemd.user.services.openclaw-gateway = {
    Service.EnvironmentFile = "${secretsDir}/secrets.env";
    # Suppress bundled skills warning (nix-openclaw doesn't include the dir next to the binary)
    Service.Environment = [
      "OPENCLAW_BUNDLED_SKILLS_DIR=${config.home.homeDirectory}/.openclaw/skills"
    ];
  };
}
