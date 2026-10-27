{
  activePreset = "openai";
  presets = let
    proxy = "headroom";

    gpt = model: variant: {inherit variant;} // wrap "gpt-${model}";
    claude = model: wrap "claude-${model}";
    wrap = model: {model = "${proxy}/${model}";};
  in {
    openai = {
      fast = gpt "6-luna" "low";
      medium = gpt "6.1-sol" "high";
      heavy = gpt "6.1-sol" "xhigh";
    };
    anthropic = {
      fast = claude "sonnet-5-5";
      medium = claude "opus-5-5";
      heavy = claude "fable-5-5";
    };
  };
  fallback.global = {
    openai = []; # no fallback
    anthropic = ["openai"];
  };
}
