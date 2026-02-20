defmodule Storybook.CognitComponents.DataTablePagination do
  @moduledoc false
  use PhoenixStorybook.Story, :component

  alias Cognit.Components.Pagination

  def function, do: &Pagination.pagination/1
  def layout, do: :one_column

  def variations do
    [
      %Variation{
        id: :first_page,
        description: "First page — previous/first buttons disabled",
        attributes: %{
          page: 1,
          total_pages: 7,
          total_entries: 100,
          page_size: 10,
          page_sizes: [10, 20, 30, 50]
        }
      },
      %Variation{
        id: :middle_page,
        description: "Middle page — all buttons enabled",
        attributes: %{
          page: 4,
          total_pages: 7,
          total_entries: 100,
          page_size: 10,
          page_sizes: [10, 20, 30, 50]
        }
      },
      %Variation{
        id: :last_page,
        description: "Last page — next/last buttons disabled",
        attributes: %{
          page: 7,
          total_pages: 7,
          total_entries: 100,
          page_size: 10,
          page_sizes: [10, 20, 30, 50]
        }
      }
    ]
  end
end
