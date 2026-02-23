defmodule Cognit.PaginationParams do
  @moduledoc """
  Struct for normalized pagination parameters.

  Provides a consistent interface for pagination data regardless of source.
  Use `from/1` to convert from different pagination sources.

  ## Examples

      # From Scrivener.Page
      page = Repo.paginate(query, page: 1, page_size: 10)
      params = PaginationParams.from(page)

      # From a plain map
      params = PaginationParams.from(%{page: 1, total_pages: 10, total_entries: 100})

      # From a keyword list
      params = PaginationParams.from(page: 1, total_pages: 10, total_entries: 100)

  Designed for use with LiveView streams — extract pagination metadata
  at the assign boundary, keep entries out of assigns:

      page = Repo.paginate(query, params)

      socket
      |> stream(:rows, page.entries, reset: true)
      |> assign(pagination: PaginationParams.from(page))
  """

  defstruct page: 1, total_pages: 1, total_entries: 0, page_size: 10

  @type t :: %__MODULE__{
          page: pos_integer(),
          total_pages: non_neg_integer(),
          total_entries: non_neg_integer(),
          page_size: pos_integer()
        }

  @doc """
  Creates a `%PaginationParams{}` from various pagination sources.

  Accepts:
  - `%PaginationParams{}` — returned as-is
  - `%Scrivener.Page{}` — extracts pagination fields, discards entries
  - `%{page: _, total_pages: _, ...}` — plain map with pagination keys
  - keyword list — converted to map first
  """
  def from(%__MODULE__{} = params), do: params

  def from(page) when is_struct(page, Scrivener.Page) do
    %__MODULE__{
      page: page.page_number,
      total_pages: page.total_pages,
      total_entries: page.total_entries,
      page_size: page.page_size
    }
  end

  def from(%{} = map) do
    %__MODULE__{
      page: map[:page] || 1,
      total_pages: map[:total_pages] || 1,
      total_entries: map[:total_entries] || 0,
      page_size: map[:page_size] || 10
    }
  end

  def from(opts) when is_list(opts) do
    from(Map.new(opts))
  end
end
