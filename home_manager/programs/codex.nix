{
  config,
  pkgs,
  ...
}: {
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.codex;
    settings.mcp_servers.github = {
      inherit (config.programs.mcp.servers.github) enabled url;
      bearer_token_env_var = "GITHUB_COM_TOKEN";
    };
  };
}
