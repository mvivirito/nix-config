{ pkgs, config, lib, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama;

    # Pre-pull Qwen 2.5 14B for local LLM
    loadModels = [ "qwen2.5:14b" ];

    # CUDA environment
    environmentVariables = {
      CUDA_VISIBLE_DEVICES = "0";
    };
  };

  # Open Ollama API port
  networking.firewall.allowedTCPPorts = [ 11434 ];
}
