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
        # Token read from OPENCLAW_GATEWAY_TOKEN env var (set via EnvironmentFile below)
      };

      # Model providers
      models.providers = {
        # Anthropic Claude (API key injected from secrets.env via activation script)
        anthropic = {
          baseUrl = "https://api.anthropic.com";
          api = "anthropic-messages";
          models = [
            { id = "claude-haiku-4-5"; name = "Claude Haiku 4.5"; }
            { id = "claude-sonnet-4-5"; name = "Claude Sonnet 4.5"; }
            { id = "claude-opus-4-5"; name = "Claude Opus 4.5"; }
          ];
        };

        # Google Gemini (API key injected from secrets.env via activation script)
        google = {
          baseUrl = "https://generativelanguage.googleapis.com";
          api = "google-generative-ai";
          models = [
            { id = "gemini-3-flash-preview"; name = "Gemini 3 Flash"; }
            { id = "gemini-2.5-pro"; name = "Gemini 2.5 Pro"; }
          ];
        };

        # Ollama (local - free)
        ollama = {
          baseUrl = "http://127.0.0.1:11434";
          api = "ollama";
          apiKey = "ollama-local";
          models = [
            { id = "llama3.2:3b"; name = "Llama 3.2 3B"; }
            { id = "qwen2.5:7b"; name = "Qwen 2.5 7B"; }
          ];
        };
      };

      # Default agent settings
      agents.defaults = {
        # Default to Claude Haiku (cheapest cloud, good for most queries)
        model.primary = "anthropic/claude-haiku-4-5";

        # Fallback chain: cloud-to-local cascade
        model.fallbacks = [
          "google/gemini-3-flash-preview"
          "google/gemini-2.5-pro"
          "ollama/qwen2.5:7b"
        ];

        # Model aliases for quick switching (e.g. /model sonnet in Telegram)
        models = {
          "anthropic/claude-haiku-4-5"    = { alias = "haiku"; };
          "anthropic/claude-sonnet-4-5"   = { alias = "sonnet"; };
          "anthropic/claude-opus-4-5"     = { alias = "opus"; };
          "google/gemini-3-flash-preview" = { alias = "flash"; };
          "google/gemini-2.5-pro"         = { alias = "pro"; };
          "ollama/qwen2.5:7b"             = { alias = "qwen"; };
          "ollama/llama3.2:3b"            = { alias = "local"; };
        };

        workspace = "/home/michael/.openclaw/workspace";

        # Heartbeat (free via Ollama)
        heartbeat = {
          every = "55m";  # 55min to keep cache warm with 60min TTL
          model = "ollama/llama3.2:3b";
          session = "main";
          prompt = "Check: Any blockers, opportunities, or progress updates?";
        };

        # Context pruning (cache-aware)
        contextPruning = {
          mode = "cache-ttl";
          ttl = "60m";
        };

        # Compaction strategy
        compaction = {
          mode = "safeguard";
        };
      };

      # Telegram channel
      channels.telegram = {
        tokenFile = "${secretsDir}/telegram-token";
        allowFrom = [ telegramUserId ];
        defaultTo = telegramUserId;
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
