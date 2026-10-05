{
  activePreset = "openai";
  presets = let
    proxy = "headroom";

    gpt = model: wrap "gpt-${model}";
    claude = model: wrap "claude-${model}";
    wrap = model: {model = "${proxy}/${model}";};
  in {
    openai = {
      fast = gpt "5.6-luna";
      medium = gpt "5.6-terra";
      heavy = gpt "5.6-sol";
    };
    anthropic = {
      fast = claude "sonnet-5";
      medium = claude "opus-5";
      heavy = claude "fable-5";
    };
  };
  fallback.global = {
    openai = []; # no fallback
    anthropic = ["openai"];
  };
}
