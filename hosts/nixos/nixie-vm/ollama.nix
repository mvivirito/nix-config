{ pkgs, config, lib, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;  # Enable GPU acceleration for RTX 4080
    host = "0.0.0.0";  # Listen on all interfaces (needed for k8s pod access)

    # Pre-pull registry models on service start (idempotent — skips if present).
    # Custom Modelfile models (Trismegistus/Synthia/MythoMax) live in ~/ollama-models/
    # and must be re-created manually via `ollama create` after a fresh install.
    loadModels = [
      # General / large
      "qwen2.5:14b"
      "qwen2.5:32b"
      "qwen2.5-coder:14b"
      # Reasoning / multimodal
      "deepseek-r1:14b"
      "phi4:14b"
      "gemma3:12b"
      # Uncensored general
      "dolphin3:8b"
      "hermes3:8b"
      "nous-hermes2:10.7b"
      "huihui_ai/qwen2.5-abliterate:14b"
      "wizard-vicuna-uncensored:13b"
    ];

    # Set environment variables for CUDA
    environmentVariables = {
      CUDA_VISIBLE_DEVICES = "0";  # Use first GPU
    };
  };

  # Open the Ollama port in the firewall
  networking.firewall.allowedTCPPorts = [ 11434 ];
}
