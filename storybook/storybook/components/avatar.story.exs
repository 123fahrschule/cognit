defmodule Storybook.CognitComponents.Avatar do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Cognit.Avatar

  def function, do: &Cognit.Avatar.avatar/1

  def imports, do: [{Avatar, [avatar_image: 1, avatar_fallback: 1]}]

  def variations do
    [
      %Variation{
        id: :avatar_image,
        template: """
        <.avatar>
        <.avatar_image src="https://github.com/shadcn.png" />
        <.avatar_fallback>CN</.avatar_fallback>
        </.avatar>
        """
      },
      %Variation{
        id: :avatar_fallback,
        template: """
        <.avatar>
        <.avatar_image src="http://example.com/badimage.png" />
        <.avatar_fallback>CN</.avatar_fallback>
        </.avatar>
        """
      },
      %Variation{
        id: :avatar_custom_colors,
        template: """
        <.avatar>
        <.avatar_image src="http://example.com/badimage.png" />
        <.avatar_fallback class="bg-primary text-primary-foreground">CN</.avatar_fallback>
        </.avatar>
        """
      },
      %Variation{
        id: :sizes,
        template: """
        <div class="flex flex-col items-start gap-3">
        <.avatar size="2xs"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="xs"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="sm"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="md"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="lg"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="xl"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="2xl"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="3xl"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="4xl"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="5xl"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="6xl"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        </div>
        """
      },
      %Variation{
        id: :shape_rounded,
        template: """
        <div class="flex flex-col items-start gap-3">
        <.avatar size="2xs" shape="rounded"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="sm" shape="rounded"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="md" shape="rounded"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        <.avatar size="lg" shape="rounded">
        <.avatar_image src="https://github.com/shadcn.png" />
        <.avatar_fallback>CN</.avatar_fallback>
        </.avatar>
        <.avatar size="2xl" shape="rounded"><.avatar_fallback>CN</.avatar_fallback></.avatar>
        </div>
        """
      }
    ]
  end
end
