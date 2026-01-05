defmodule Cognit.Components.LoginLayout do
  use Cognit, :component

  import Cognit.Button
  import Cognit.Card

  import Cognit.Components.Logo

  slot :inner_block

  def login_layout(assigns) do
    ~H"""
    <div class="h-full flex flex-col items-center bg-muted pt-14">
      <div class="mb-[186px]">
        <.brand_logo variant="full" class="w-[153px]" />
      </div>

      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :error_message, :string, default: nil

  slot :inner_block

  def login_card(assigns) do
    ~H"""
    <.card class="max-w-[480px] w-full">
      <.card_header>
        <.card_title>
          {@title}
        </.card_title>
        <.card_description>
          {@description}
        </.card_description>
      </.card_header>

      <.card_content :if={@error_message}>
        <p class="text-destructive">
          {@error_message}
        </p>
      </.card_content>

      <.card_footer>
        {render_slot(@inner_block)}
      </.card_footer>
    </.card>
    """
  end

  attr :text, :string, required: true

  attr :rest, :global,
    include: ~w(as href navigate patch),
    default: %{
      as: &link/1
    }

  def login_card_action(assigns) do
    ~H"""
    <.button class="w-full" {@rest}>
      {@text}
    </.button>
    """
  end
end
