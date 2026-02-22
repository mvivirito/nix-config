{ pkgs, config, lib, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;  # Enable GPU acceleration for RTX 4080

    # Pre-pull models for heartbeats and local fallback
    loadModels = [ "llama3.2:3b" "qwen2.5:7b" ];

    # Set environment variables for CUDA
    environmentVariables = {
      CUDA_VISIBLE_DEVICES = "0";  # Use first GPU
    };
  };

  # Open the Ollama port in the firewall
  networking.firewall.allowedTCPPorts = [ 11434 ];
}
