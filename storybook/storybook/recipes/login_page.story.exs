defmodule Storybook.Recipes.LoginPage do
  use PhoenixStorybook.Story, :page
  use Cognit

  import Cognit.Components.LoginLayout

  def render(assigns) do
    ~H"""
    <div class="h-[600px] rounded-lg border overflow-hidden">
      <.login_layout>
        <.login_card title="Welcome" description="Sign in to your account to continue.">
          <.login_card_action text="Sign in with SSO" as="button" />
        </.login_card>
      </.login_layout>
    </div>
    """
  end
end
