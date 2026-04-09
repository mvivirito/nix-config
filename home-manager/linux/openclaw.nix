{ inputs, config, lib, pkgs, ... }:
let
  secretsDir = "${config.home.homeDirectory}/.config/openclaw";
  telegramUserId = 5135194752;
in
{
  imports = [ inputs.nix-openclaw.homeManagerModules.openclaw ];

  programs.openclaw = {
    enable = true;

    # Enable systemd user service on Linux
    systemd.enable = true;

    # No-sudo config refresh + gateway restart helper
    reloadScript.enable = true;

    # Bundled plugins (Linux-relevant ones)
    bundledPlugins = {
      summarize.enable = true;   # Summarize URLs, PDFs, YouTube videos
      # gogcli conflicts with openclaw's own `gog` binary
      # gogcli.enable = true;    # Google Calendar integration
    };

    # Gateway configuration
    config = {
      gateway = {
        mode = "local";
        auth.mode = "token";
      };

      # QMD memory backend (BM25 + vectors + reranking)
      memory = {
        backend = "qmd";
        qmd = {
          command = "${config.home.homeDirectory}/.bun/bin/qmd";
          searchMode = "search";
          includeDefaultMemory = true;
          update = {
            interval = "5m";
            onBoot = true;
            embedInterval = "60m";
          };
          sessions = {
            enabled = true;
          };
          limits = {
            maxResults = 6;
          };
        };
      };

      # Model providers
      # Caching notes:
      #   Anthropic: Prompt caching (90% discount on cache reads, 1hr TTL). Auto for prompts >= 1024 tokens.
      #   Google Gemini 2.5+: Implicit caching (75-90% discount). Automatic, no config needed.
      #   NVIDIA NIM: Free tier, no caching benefit (already $0).
      #   Ollama: Local, no API caching needed. KV cache quantization handled at service level.
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

        # Google Gemini (GEMINI_API_KEY from env)
        google = {
          baseUrl = "https://generativelanguage.googleapis.com";
          api = "google-generative-ai";
          models = [
            { id = "gemini-3.1-pro-preview"; name = "Gemini 3.1 Pro"; contextWindow = 1048576; maxTokens = 8192; reasoning = true; input = [ "text" "image" ]; cost = { input = 1.25; output = 10.00; cacheRead = 0; cacheWrite = 0; }; }
            { id = "gemini-3-flash-preview"; name = "Gemini 3 Flash"; contextWindow = 131072; maxTokens = 8192; reasoning = false; input = [ "text" ]; cost = { input = 0.15; output = 0.60; cacheRead = 0; cacheWrite = 0; }; }
            { id = "gemini-2.5-pro"; name = "Gemini 2.5 Pro"; contextWindow = 1048576; maxTokens = 8192; reasoning = true; input = [ "text" ]; cost = { input = 1.25; output = 10.00; cacheRead = 0; cacheWrite = 0; }; }
          ];
        };

        # OpenRouter (MiMo v2 Pro + Step 3.5 Flash)
        openrouter = {
          baseUrl = "https://openrouter.ai/api/v1";
          api = "openai-completions";
          models = [
            { id = "xiaomi/mimo-v2-pro"; name = "MiMo v2 Pro"; contextWindow = 1048576; maxTokens = 131072; reasoning = true; input = [ "text" ]; cost = { input = 0.001; output = 0.003; cacheRead = 0; cacheWrite = 0; }; }
            { id = "stepfun/step-3.5-flash"; name = "Step 3.5 Flash"; contextWindow = 256000; maxTokens = 256000; reasoning = false; input = [ "text" ]; cost = { input = 0.0001; output = 0.0003; cacheRead = 0; cacheWrite = 0; }; }
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
        # Default to MiMo v2 Pro (reasoning, 1M context, near-free)
        model.primary = "openrouter/xiaomi/mimo-v2-pro";

        # Fallback chain: Step Flash → Gemini → local GPU → free cloud
        model.fallbacks = [
          "openrouter/stepfun/step-3.5-flash"
          "google/gemini-2.5-pro"
          "google/gemini-3.1-pro-preview"
          "ollama/qwen2.5:14b"
          "nvidia/moonshotai/kimi-k2.5"
        ];

        # Model aliases for quick switching (e.g. /model mimo in Telegram)
        models = {
          "openrouter/xiaomi/mimo-v2-pro"  = { alias = "mimo"; };
          "openrouter/stepfun/step-3.5-flash" = { alias = "step"; };
          "google/gemini-3.1-pro-preview"  = { alias = "gemini"; };
          "nvidia/moonshotai/kimi-k2.5"   = { alias = "kimi"; };
          "google/gemini-3-flash-preview"  = { alias = "flash"; };
          "google/gemini-2.5-pro"          = { alias = "pro"; };
          "ollama/qwen2.5:7b"              = { alias = "qwen7"; };
          "ollama/qwen2.5:14b"             = { alias = "qwen"; };
          "ollama/llama3.2:3b"             = { alias = "llama3"; };
        };

        # Hard cap on context sent to any model
        contextTokens = 65536;

        workspace = "${config.home.homeDirectory}/.openclaw/workspace";

        # Heartbeat (Llama 3.2 3B, every 30m, 8am-11pm PT — isolated session to avoid main transcript pollution)
        heartbeat = {
          every = "30m";
          model = "ollama/qwen2.5:14b";
          session = "isolated";
          target = "last";
          lightContext = true;
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
          tools.profile = "coding";
          identity.emoji = "🔮";
        }
        {
          id = "junior";
          name = "Junior";
          model = "openrouter/stepfun/step-3.5-flash";
          tools.profile = "coding";
          identity.emoji = "🧑‍💻";
        }
        {
          id = "doc";
          name = "Doc";
          tools.allow = [ "web_search" "web_fetch" "read" "write" ];
          identity.emoji = "🔬";
        }
        {
          id = "thinker";
          name = "Thinker";
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
          identity.emoji = "🆓";
        }
        {
          id = "scout";
          name = "Scout";
          tools.allow = [ "web_search" "web_fetch" "browser" "image" "read" ];
          identity.emoji = "🔭";
        }
      ];
    };

    # Enable Telegram plugin (required since OpenClaw 2026.2.22+)
      plugins.entries.telegram.enabled = true;

      # Channel defaults - only deliver real heartbeat alerts to Telegram
      channels.defaults.heartbeat = {
        showOk = false;
        showAlerts = true;
      };

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

      # Skills: load from workspace skills directory
      skills.load.extraDirs = [ "${config.home.homeDirectory}/.openclaw/workspace/skills" ];

      # MCP servers
      mcp.servers = {
        jcodemunch = {
          command = "${pkgs.uv}/bin/uvx";
          args = [ "jcodemunch-mcp" ];
          env = {
            CODE_INDEX_PATH = "${config.home.homeDirectory}/.code-index";
            JCODEMUNCH_USE_AI_SUMMARIES = "true";
            JCODEMUNCH_SHARE_SAVINGS = "0";
          };
        };
      };

      # Headless browser (Playwright/CDP)
      browser = {
        enabled = true;
        headless = true;
        executablePath = "${pkgs.chromium}/bin/chromium";
        noSandbox = true;
      };

      # Gmail hooks (uncomment when Google Cloud Pub/Sub is set up)
      # hooks = {
      #   enabled = true;
      #   gmail = {
      #     account = "your@gmail.com";
      #     label = "INBOX";
      #     topic = "projects/<project-id>/topics/<topic-name>";
      #     subscription = "gog-gmail-watch-push";
      #     includeBody = true;
      #     maxBytes = 20000;
      #     model = "openrouter/xiaomi/mimo-v2-pro";
      #     thinking = "medium";
      #     serve = {
      #       bind = "127.0.0.1";
      #       port = 8788;
      #     };
      #   };
      # };
    };
  };

  # Fix upstream packaging bug: dist/extensions/ has compiled JS but no plugin manifests.
  # Point both shell and systemd to the source extensions/ dir which has them.
  home.sessionVariables.OPENCLAW_BUNDLED_PLUGINS_DIR = "${pkgs.openclaw-gateway}/lib/openclaw/extensions";

  # Source secrets.env in shell so CLI tools (openclaw tui, etc.) have API keys + gateway token
  programs.zsh.initExtra = ''
    [ -f "${secretsDir}/secrets.env" ] && set -a && source "${secretsDir}/secrets.env" && set +a
  '';

  # API keys resolved from environment variables at runtime via EnvironmentFile
  systemd.user.services.openclaw-gateway = {
    Service.EnvironmentFile = "${secretsDir}/secrets.env";
    Service.Environment = [
      "OPENCLAW_BUNDLED_SKILLS_DIR=${config.home.homeDirectory}/.openclaw/skills"
      "OPENCLAW_BUNDLED_PLUGINS_DIR=${pkgs.openclaw-gateway}/lib/openclaw/extensions"
      "PATH=${pkgs.uv}/bin:${pkgs.bun}/bin:${pkgs.nodejs_22}/bin:${config.home.homeDirectory}/.bun/bin:/run/current-system/sw/bin:/etc/profiles/per-user/${config.home.username}/bin"
    ];
  };

  # Fix: nix-openclaw module symlinks skills into the Nix store,
  # but the skill loader rejects symlinked paths (resolves outside root).
  # Copy symlinked SKILL.md files to real files after each rebuild.
  home.activation.fixSkillSymlinks = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    skillsDir="${config.home.homeDirectory}/.openclaw/workspace/skills"
    if [ -d "$skillsDir" ]; then
      find "$skillsDir" -name "SKILL.md" -type l | while read -r link; do
        target="$(readlink -f "$link")"
        rm "$link"
        cp "$target" "$link"
      done
    fi
  '';
}
