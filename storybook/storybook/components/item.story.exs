defmodule Storybook.CognitComponents.Item do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Cognit.Item

  def function, do: &Cognit.Item.item/1

  def imports do
    [
      {Item,
       [
         item_actions: 1,
         item_content: 1,
         item_description: 1,
         item_footer: 1,
         item_group: 1,
         item_header: 1,
         item_media: 1,
         item_title: 1
       ]},
      {Cognit.Avatar, [avatar: 1, avatar_image: 1, avatar_fallback: 1]},
      {Cognit.Button, [button: 1]},
      {Cognit.Icon, [icon: 1]},
      {Cognit.Progress, [progress: 1]},
      {Cognit.Separator, [separator: 1]}
    ]
  end

  def variations do
    [
      %Variation{
        id: :basic,
        template: """
        <.item variant="outline" class="w-96">
          <.item_content>
            <.item_title>Basic item</.item_title>
            <.item_description>A simple item with title and description.</.item_description>
          </.item_content>
          <.item_actions>
            <.button variant="outline" size="sm">Label</.button>
          </.item_actions>
        </.item>
        """
      },
      %Variation{
        id: :variants,
        template: """
        <div class="flex w-96 flex-col gap-2">
          <.item>
            <.item_media variant="feature"><.icon name="verified" /></.item_media>
            <.item_content>
              <.item_title>Default</.item_title>
              <.item_description>No visible border.</.item_description>
            </.item_content>
          </.item>
          <.item variant="outline">
            <.item_media variant="feature"><.icon name="verified" /></.item_media>
            <.item_content>
              <.item_title>Outline</.item_title>
              <.item_description>Bordered container.</.item_description>
            </.item_content>
          </.item>
        </div>
        """
      },
      %Variation{
        id: :sizes,
        template: """
        <div class="flex w-96 flex-col gap-2">
          <.item variant="outline">
            <.item_media variant="feature"><.icon name="verified" /></.item_media>
            <.item_content>
              <.item_title>Default size</.item_title>
              <.item_description>Roomy padding.</.item_description>
            </.item_content>
            <.item_actions><.button variant="outline" size="sm">Label</.button></.item_actions>
          </.item>
          <.item variant="outline" size="small">
            <.item_media>
              <.avatar size="sm"><.avatar_fallback>CN</.avatar_fallback></.avatar>
            </.item_media>
            <.item_content>
              <.item_title>Small size</.item_title>
              <.item_description>Compact padding.</.item_description>
            </.item_content>
            <.item_actions><.button variant="outline" size="sm">Label</.button></.item_actions>
          </.item>
        </div>
        """
      },
      %Variation{
        id: :media_variants,
        template: """
        <div class="flex w-96 flex-col gap-2">
          <.item variant="outline">
            <.item_media variant="icon"><.icon name="verified" /></.item_media>
            <.item_content><.item_title>Icon</.item_title></.item_content>
          </.item>
          <.item variant="outline">
            <.item_media variant="feature"><.icon name="shield" /></.item_media>
            <.item_content><.item_title>Feature icon</.item_title></.item_content>
          </.item>
          <.item variant="outline">
            <.item_media>
              <.avatar size="sm"><.avatar_image src="https://github.com/shadcn.png" /></.avatar>
            </.item_media>
            <.item_content><.item_title>Avatar</.item_title></.item_content>
          </.item>
          <.item variant="outline">
            <.item_media variant="avatars">
              <.avatar size="sm"><.avatar_image src="https://github.com/shadcn.png" /></.avatar>
              <.avatar size="sm"><.avatar_image src="https://github.com/vercel.png" /></.avatar>
              <.avatar size="sm"><.avatar_image src="https://github.com/evilrabbit.png" /></.avatar>
            </.item_media>
            <.item_content><.item_title>Avatar group</.item_title></.item_content>
          </.item>
          <.item variant="outline">
            <.item_media variant="image">
              <img src="https://github.com/shadcn.png" alt="" />
            </.item_media>
            <.item_content>
              <.item_title>Midnight City Lights</.item_title>
              <.item_description>Neon Dreams</.item_description>
            </.item_content>
            <.item_actions>
              <span class="text-xs text-muted-foreground">3:45</span>
            </.item_actions>
          </.item>
        </div>
        """
      },
      %Variation{
        id: :group,
        template: """
        <.item_group class="w-96">
          <.item size="small">
            <.item_media>
              <.avatar size="sm"><.avatar_image src="https://github.com/shadcn.png" /></.avatar>
            </.item_media>
            <.item_content>
              <.item_title>shadcn</.item_title>
              <.item_description>shadcn@vercel.com</.item_description>
            </.item_content>
            <.item_actions>
              <.button variant="ghost" size="icon-sm"><.icon name="add" label="Add" /></.button>
            </.item_actions>
          </.item>
          <.separator />
          <.item size="small">
            <.item_media>
              <.avatar size="sm"><.avatar_fallback>ML</.avatar_fallback></.avatar>
            </.item_media>
            <.item_content>
              <.item_title>maxleiter</.item_title>
              <.item_description>maxleiter@vercel.com</.item_description>
            </.item_content>
            <.item_actions>
              <.button variant="ghost" size="icon-sm"><.icon name="add" label="Add" /></.button>
            </.item_actions>
          </.item>
          <.separator />
          <.item size="small">
            <.item_media>
              <.avatar size="sm"><.avatar_fallback>ER</.avatar_fallback></.avatar>
            </.item_media>
            <.item_content>
              <.item_title>evilrabbit</.item_title>
              <.item_description>evilrabbit@vercel.com</.item_description>
            </.item_content>
            <.item_actions>
              <.button variant="ghost" size="icon-sm"><.icon name="add" label="Add" /></.button>
            </.item_actions>
          </.item>
        </.item_group>
        """
      },
      %Variation{
        id: :header,
        template: """
        <div class="flex gap-4">
          <.item variant="outline" class="w-44">
            <.item_header>
              <img
                src="https://github.com/shadcn.png"
                alt=""
                class="h-32 w-full rounded-sm object-cover"
              />
            </.item_header>
            <.item_content>
              <.item_title>v0-1.5-sm</.item_title>
              <.item_description>Everyday tasks and UI generation.</.item_description>
            </.item_content>
          </.item>
          <.item variant="outline" class="w-44">
            <.item_header>
              <img
                src="https://github.com/vercel.png"
                alt=""
                class="h-32 w-full rounded-sm object-cover"
              />
            </.item_header>
            <.item_content>
              <.item_title>v0-1.5-lg</.item_title>
              <.item_description>Advanced thinking or reasoning.</.item_description>
            </.item_content>
          </.item>
        </div>
        """
      },
      %Variation{
        id: :footer,
        template: """
        <.item variant="outline" class="w-full max-w-[32rem]">
          <.item_media variant="feature"><.icon name="cloud_upload" /></.item_media>
          <.item_content>
            <.item_title>Uploading assets</.item_title>
            <.item_description>12 of 20 files transferred.</.item_description>
          </.item_content>
          <.item_footer>
            <div class="flex min-w-0 flex-1 items-center gap-2">
              <.avatar size="2xs"><.avatar_fallback>CN</.avatar_fallback></.avatar>
              <span class="truncate text-xs text-muted-foreground">shadcn</span>
            </div>
            <.progress value={60} class="h-2 flex-1" />
            <.button size="sm">Label</.button>
            <.button variant="ghost" size="icon-sm">
              <.icon name="chevron_right" label="Open" />
            </.button>
          </.item_footer>
        </.item>
        """
      },
      %Variation{
        id: :as_link,
        template: """
        <div class="flex w-96 flex-col gap-2">
          <.item variant="outline" navigate="/">
            <.item_content>
              <.item_title>Visit our documentation</.item_title>
              <.item_description>Learn how to get started with our components.</.item_description>
            </.item_content>
            <.item_actions><.icon name="chevron_right" class="text-muted-foreground" /></.item_actions>
          </.item>
          <.item variant="outline" as="a" href="https://example.com" target="_blank" rel="noreferrer">
            <.item_content>
              <.item_title>External resource</.item_title>
              <.item_description>Opens in a new tab with security attributes.</.item_description>
            </.item_content>
            <.item_actions><.icon name="open_in_new" class="text-muted-foreground" /></.item_actions>
          </.item>
        </div>
        """
      }
    ]
  end
end
