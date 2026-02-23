defmodule Storybook.CognitComponents.DataTablePagination do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Cognit.Components.Pagination

  def function, do: &Pagination.pagination/1
  def layout, do: :one_column

  def description do
    """
    The pagination component supports two modes:

    **URL mode** (default) — omit `on_change`. Navigation patches `?page=X&page_size=Y`
    query params into the URL via a JS hook. Handle pagination in `handle_params/3`.
    Enables bookmarkable/shareable URLs.

    **Event mode** — pass `on_change` as a string event name. The component pushes
    `%{page: integer, page_size: integer}` via `JS.push`. Handle in `handle_event/3`.
    Use `target` to direct the event to a specific LiveComponent.
    """
  end

  def variations do
    [
      %VariationGroup{
        id: :url_mode,
        description: "URL mode — patches ?page=&page_size= query params (default)",
        variations: [
          %Variation{
            id: :url_mode_default,
            description: "Omit on_change to use URL mode. Requires id for the JS hook.",
            attributes: %{
              id: "url-pagination",
              page: 3,
              total_pages: 10,
              total_entries: 100,
              page_size: 10,
              page_sizes: [10, 20, 30, 50]
            }
          }
        ]
      },
      %VariationGroup{
        id: :event_mode,
        description: "Event mode — pushes LiveView events via JS.push",
        variations: [
          %Variation{
            id: :event_mode_default,
            description:
              "Pass on_change=\"paginate\" to use event mode. Pushes %{page: int, page_size: int}.",
            attributes: %{
              page: 3,
              total_pages: 10,
              total_entries: 100,
              page_size: 10,
              page_sizes: [10, 20, 30, 50],
              on_change: "paginate"
            }
          },
          %Variation{
            id: :event_mode_with_target,
            description: "Use target={@myself} to direct events to a LiveComponent.",
            attributes: %{
              page: 1,
              total_pages: 5,
              total_entries: 50,
              page_size: 10,
              page_sizes: [10, 20, 50],
              on_change: "paginate"
            }
          }
        ]
      },
      %VariationGroup{
        id: :button_states,
        description: "Navigation buttons disable at boundaries",
        variations: [
          %Variation{
            id: :first_page,
            description: "First page — previous/first disabled",
            attributes: %{
              page: 1,
              total_pages: 7,
              total_entries: 100,
              page_size: 10,
              on_change: "paginate"
            }
          },
          %Variation{
            id: :last_page,
            description: "Last page — next/last disabled",
            attributes: %{
              page: 7,
              total_pages: 7,
              total_entries: 100,
              page_size: 10,
              on_change: "paginate"
            }
          }
        ]
      }
    ]
  end
end
