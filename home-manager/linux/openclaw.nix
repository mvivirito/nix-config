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
        auth.mode = "token";
      };

      # Model providers
      models.providers = {
        # NVIDIA NIM - Kimi K2.5 (free tier, OpenAI-compatible)
        nvidia = {
          baseUrl = "https://integrate.api.nvidia.com/v1";
          api = "openai-completions";
          models = [
            { id = "moonshotai/kimi-k2.5"; name = "Kimi K2.5"; contextWindow = 131072; maxTokens = 8192; reasoning = false; input = [ "text" ]; cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; }; }
            { id = "nvidia/llama-3.1-nemotron-70b-instruct"; name = "NVIDIA Llama 3.1 Nemotron 70B Instruct"; contextWindow = 131072; maxTokens = 4096; reasoning = false; input = [ "text" ]; cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; }; }
            { id = "meta/llama-3.3-70b-instruct"; name = "Meta Llama 3.3 70B Instruct"; contextWindow = 131072; maxTokens = 4096; reasoning = false; input = [ "text" ]; cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; }; }
            { id = "nvidia/mistral-nemo-minitron-8b-8k-instruct"; name = "NVIDIA Mistral NeMo Minitron 8B Instruct"; contextWindow = 8192; maxTokens = 2048; reasoning = false; input = [ "text" ]; cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; }; }
          ];
        };

        # Anthropic Claude (API key injected from secrets.env via activation script)
        anthropic = {
          baseUrl = "https://api.anthropic.com";
          api = "anthropic-messages";
          models = [
            { id = "claude-haiku-4-5"; name = "Claude Haiku 4.5"; contextWindow = 200000; maxTokens = 4096; reasoning = false; input = [ "text" "image" ]; cost = { input = 0.80; output = 4.00; cacheRead = 0; cacheWrite = 0; }; }
            { id = "claude-sonnet-4-5"; name = "Claude Sonnet 4.5"; contextWindow = 200000; maxTokens = 8192; reasoning = true; input = [ "text" "image" ]; cost = { input = 3.00; output = 15.00; cacheRead = 0; cacheWrite = 0; }; }
            { id = "claude-opus-4-5"; name = "Claude Opus 4.5"; contextWindow = 200000; maxTokens = 8192; reasoning = false; input = [ "text" "image" ]; cost = { input = 15.00; output = 75.00; cacheRead = 0; cacheWrite = 0; }; }
          ];
        };

        # Google Gemini (API key injected from secrets.env via activation script)
        google = {
          baseUrl = "https://generativelanguage.googleapis.com";
          api = "google-generative-ai";
          models = [
            { id = "gemini-3.1-pro-preview"; name = "Gemini 3.1 Pro"; contextWindow = 1048576; maxTokens = 8192; reasoning = true; input = [ "text" "image" ]; cost = { input = 1.25; output = 10.00; cacheRead = 0; cacheWrite = 0; }; }
            { id = "gemini-3-flash-preview"; name = "Gemini 3 Flash"; contextWindow = 131072; maxTokens = 8192; reasoning = false; input = [ "text" ]; cost = { input = 0.15; output = 0.60; cacheRead = 0; cacheWrite = 0; }; }
            { id = "gemini-2.5-pro"; name = "Gemini 2.5 Pro"; contextWindow = 1048576; maxTokens = 8192; reasoning = true; input = [ "text" ]; cost = { input = 1.25; output = 10.00; cacheRead = 0; cacheWrite = 0; }; }
          ];
        };

        # Ollama (local GPU - free)
        ollama = {
          baseUrl = "http://127.0.0.1:11434";
          api = "ollama";
          apiKey = "ollama-local";
          models = [
            { id = "qwen2.5:7b"; name = "Qwen 2.5 7B"; contextWindow = 32768; maxTokens = 4096; }
            { id = "qwen2.5:14b"; name = "Qwen 2.5 14B"; contextWindow = 32768; maxTokens = 4096; }
            { id = "llama3.2:3b"; name = "Llama 3.2 3B"; contextWindow = 8192; maxTokens = 4096; }
          ];
        };
      };

      # Default agent settings
      agents = {
      defaults = {
        # Default to Gemini 3.1 Pro (confirmed working, high quality)
        model.primary = "google/gemini-3.1-pro-preview";

        # Fallback chain: paid cloud → local GPU → free cloud
        model.fallbacks = [
          "google/gemini-2.5-pro"
          "anthropic/claude-haiku-4-5"
          "ollama/qwen2.5:14b"
          "nvidia/moonshotai/kimi-k2.5"
        ];

        # Model aliases for quick switching (e.g. /model sonnet in Telegram)
        models = {
          "google/gemini-3.1-pro-preview"  = { alias = "gemini"; };
          "nvidia/moonshotai/kimi-k2.5"   = { alias = "kimi"; };
          "anthropic/claude-haiku-4-5"     = { alias = "haiku"; };
          "anthropic/claude-sonnet-4-5"    = { alias = "sonnet"; };
          "anthropic/claude-opus-4-5"      = { alias = "opus"; };
          "google/gemini-3-flash-preview"  = { alias = "flash"; };
          "google/gemini-2.5-pro"          = { alias = "pro"; };
          "ollama/qwen2.5:7b"              = { alias = "qwen7"; };
          "ollama/qwen2.5:14b"             = { alias = "qwen"; };
          "ollama/llama3.2:3b"             = { alias = "llama3"; };
        };

        # Hard cap on context sent to any model
        contextTokens = 65536;

        workspace = "${config.home.homeDirectory}/.openclaw/workspace";

        # Heartbeat (Tier 2 optimized - Qwen 7B, every 30m, visible on Telegram, 8am-11pm PT)
        heartbeat = {
          every = "30m";
          model = "ollama/qwen2.5:7b";
          session = "main";
          target = "last";
          prompt = "Check: Any blockers, opportunities, or progress updates?";
          activeHours = {
            start = "08:00";
            end = "23:00";
            timezone = "America/Los_Angeles";
          };
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

          # Hybrid search (BM25 + vector), temporal decay, MMR deduplication
          query.hybrid = {
            enabled = true;
            textWeight = 0.3;
            vectorWeight = 0.7;
            temporalDecay = {
              enabled = true;
              halfLifeDays = 30;
            };
            mmr = {
              enabled = true;
              lambda = 0.7;
            };
          };
        };
      };

      list = [
        {
          id = "nixie";
          name = "Nixie";
          default = true;
          identity.emoji = "⚡";
        }
        {
          id = "prophet";
          name = "Prophet";
          model = "google/gemini-3.1-pro-preview";
          tools.profile = "coding";
          identity.emoji = "🔮";
        }
        {
          id = "junior";
          name = "Junior";
          model = "anthropic/claude-haiku-4-5";
          tools.profile = "coding";
          identity.emoji = "🧑‍💻";
        }
        {
          id = "doc";
          name = "Doc";
          model = "google/gemini-2.5-pro";
          tools.allow = [ "web_search" "web_fetch" "read" "write" ];
          identity.emoji = "🔬";
        }
        {
          id = "thinker";
          name = "Thinker";
          model = "anthropic/claude-sonnet-4-5";
          identity.emoji = "🧠";
        }
        {
          id = "local";
          name = "Local";
          model = "ollama/qwen2.5:14b";
          identity.emoji = "🏠";
        }
        {
          id = "free";
          name = "Free";
          model = "nvidia/moonshotai/kimi-k2.5";
          identity.emoji = "🆓";
        }
        {
          id = "scout";
          name = "Scout";
          model = "google/gemini-3-flash-preview";
          tools.allow = [ "web_search" "web_fetch" "browser" "image" "read" ];
          identity.emoji = "🔭";
        }
      ];
    };

    # Enable Telegram plugin (required since OpenClaw 2026.2.22+)
      plugins.entries.telegram.enabled = true;

      # Telegram channel
      channels.telegram = {
        tokenFile = "${secretsDir}/telegram-token";
        allowFrom = [ telegramUserId ];
        defaultTo = telegramUserId;
        dmPolicy = "allowlist";
        groupPolicy = "allowlist";
        streaming = "off";
      };

      commands = {
        native = "auto";
        nativeSkills = "auto";
        restart = true;
        ownerDisplay = "raw";
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

      # Inject Gateway auth token
      GATEWAY_TOKEN=$(${pkgs.gnugrep}/bin/grep -m1 '^OPENCLAW_GATEWAY_TOKEN=' "${secretsDir}/secrets.env" | cut -d= -f2-)
      if [ -n "$GATEWAY_TOKEN" ]; then
        ${pkgs.jq}/bin/jq --arg k "$GATEWAY_TOKEN" '.gateway.auth.token = $k' \
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
