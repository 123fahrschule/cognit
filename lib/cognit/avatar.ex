defmodule Cognit.Avatar do
  @moduledoc """
  Implementation of avatar component for user profile pictures with fallback support.

  Avatars are visual representations of users, typically displaying a profile picture
  or initials as a fallback. The component consists of a container, image, and fallback
  elements to ensure consistent display even when images fail to load.

  ## Examples:

      <.avatar>
        <.avatar_image src="/images/profile.jpg" alt="User avatar" />
        <.avatar_fallback>JD</.avatar_fallback>
      </.avatar>

      <.avatar class="h-12 w-12">
        <.avatar_image src={@user.avatar_url} alt={@user.name} />
        <.avatar_fallback>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-6 h-6">
            <path fill-rule="evenodd" d="M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0zm-5.5-2.5a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0zM10 12a5.99 5.99 0 0 0-4.793 2.39A6.483 6.483 0 0 0 10 16.5a6.483 6.483 0 0 0 4.793-2.11A5.99 5.99 0 0 0 10 12z" clip-rule="evenodd" />
          </svg>
        </.avatar_fallback>
      </.avatar>
  """
  use Cognit, :component

  @doc """
  Renders an avatar container.

  The avatar container is a wrapper that holds the avatar image and fallback content.

  ## Options

  * `:size` - The avatar dimensions, from `"2xs"` (20px) up to `"6xl"` (128px). Defaults to `"md"` (40px).
  * `:shape` - `"circle"` (default) or `"rounded"` for a rounded-square avatar.
  * `:class` - Additional CSS classes to apply to the avatar container.

  ## Examples

      <.avatar>
        <.avatar_image src="/images/profile.jpg" alt="User avatar" />
        <.avatar_fallback>JD</.avatar_fallback>
      </.avatar>

      <.avatar size="lg" shape="rounded">...</.avatar>
  """
  attr :class, :any, default: nil

  attr :size, :string,
    values: ~w(2xs xs sm md lg xl 2xl 3xl 4xl 5xl 6xl),
    default: "md",
    doc: "the avatar dimensions"

  attr :shape, :string,
    values: ~w(circle rounded),
    default: "circle",
    doc: "the avatar outline shape"

  attr :rest, :global
  slot :inner_block, required: false

  def avatar(assigns) do
    assigns =
      assigns
      |> assign(:size_class, avatar_size_class(assigns.size))
      |> assign(:shape_class, avatar_shape_class(assigns.shape, assigns.size))

    ~H"""
    <span
      class={classes(["relative shrink-0 overflow-hidden", @size_class, @shape_class, @class])}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  defp avatar_size_class("2xs"), do: "size-5"
  defp avatar_size_class("xs"), do: "size-6"
  defp avatar_size_class("sm"), do: "size-8"
  defp avatar_size_class("md"), do: "size-10"
  defp avatar_size_class("lg"), do: "size-12"
  defp avatar_size_class("xl"), do: "size-14"
  defp avatar_size_class("2xl"), do: "size-16"
  defp avatar_size_class("3xl"), do: "size-20"
  defp avatar_size_class("4xl"), do: "size-24"
  defp avatar_size_class("5xl"), do: "size-28"
  defp avatar_size_class("6xl"), do: "size-32"

  defp avatar_shape_class("circle", _size), do: "rounded-full"
  defp avatar_shape_class("rounded", "2xs"), do: "rounded-sm"
  defp avatar_shape_class("rounded", size) when size in ~w(xs sm), do: "rounded-md"
  defp avatar_shape_class("rounded", _size), do: "rounded-lg"

  @doc """
  Renders an avatar image.

  The image is set to display only after it has loaded, preventing layout shifts
  and allowing the fallback to show during loading.

  ## Options

  * `:src` - The URL of the avatar image.
  * `:alt` - The alt text for the image for accessibility.
  * `:class` - Additional CSS classes to apply to the image.

  ## Examples

      <.avatar_image src="/images/profile.jpg" alt="User profile" />
      <.avatar_image src={@user.avatar_url} alt={@user.name} class="border-2" />
  """
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(alt src)

  def avatar_image(assigns) do
    ~H"""
    <img
      class={classes(["aspect-square h-full w-full object-cover", @class])}
      {@rest}
      phx-update="ignore"
      style="display:none"
      onload="this.style.display=''"
    />
    """
  end

  @doc """
  Renders an avatar fallback element.

  The fallback is displayed when the avatar image is not available or during image loading.
  This can contain text (like user initials) or an icon.

  ## Options

  * `:class` - Additional CSS classes to apply to the fallback element.

  ## Examples

      <.avatar_fallback>JD</.avatar_fallback>

      <.avatar_fallback class="bg-primary text-primary-foreground">
        <svg><!-- User icon SVG --></svg>
      </.avatar_fallback>
  """
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: false

  def avatar_fallback(assigns) do
    ~H"""
    <span
      class={
        classes([
          "flex h-full w-full items-center justify-center rounded-[inherit] bg-muted text-sm text-foreground",
          @class
        ])
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end
end
