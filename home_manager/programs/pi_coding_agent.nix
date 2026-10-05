{
  config,
  pkgs,
  ...
}: let
  qwen = "qwen3.8-flash-next";
in {
  programs.pi-coding-agent = {
    enable = true;
    package = pkgs.pi-coding-agent;
    models.providers.openai = {
      api = "openai-responses";
      # Local Headroom proxy:
      baseUrl = "http://localhost:8787/v1";
      models = [
        {id = qwen;}
      ];
    };
    settings = {
      theme = "dark";
      extensions = [
        "+builtin:mcp"
        "+builtin:codemode"
      ];
      defaultTools = ["+codemode"];
      defaultModel = qwen;
      defaultProvider = "openai";
      enabledModels = [
        qwen
        "gpt-5.6-*"
        "gpt-6-*"
      ];
    };
  };

  home.file.".pi/agent/mcp.json".source = config.xdg.configFile."mcp/mcp.json".source;
}
