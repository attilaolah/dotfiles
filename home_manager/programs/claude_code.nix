{
  config,
  pkgs,
  ...
}: {
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.claude-code;
    mcpServers.github = {
      inherit (config.programs.mcp.servers.github) enabled url;
      headers.Authorization = "Bearer \${GITHUB_COM_TOKEN}";
    };
  };
}
