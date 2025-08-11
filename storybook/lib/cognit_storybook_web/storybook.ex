defmodule CognitStorybookWeb.Storybook do
  use PhoenixStorybook,
    otp_app: :cognit_storybook,
    content_path: Path.expand("../../storybook", __DIR__),
    # assets path are remote path, not local file-system paths
    css_path: "/assets/storybook_styles.css",
    js_path: "/assets/storybook.js",
    sandbox_class: "cognit-storybook"
end
