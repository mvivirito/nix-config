{ pkgs, config, lib, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;  # Enable GPU acceleration for RTX 4080

    # Pre-pull Qwen 2.5 14B (~10GB VRAM) for local fallback + heartbeats
    loadModels = [ "qwen2.5:14b" ];

    # Set environment variables for CUDA
    environmentVariables = {
      CUDA_VISIBLE_DEVICES = "0";  # Use first GPU
    };
  };

  # Open the Ollama port in the firewall
  networking.firewall.allowedTCPPorts = [ 11434 ];
}
