defmodule Cognit.Components.UserHelpers do
  use Gettext, backend: Cognit.Gettext

  def user_display_name(user) do
    first_name = Map.get(user, :first_name) || Map.get(user, "first_name")
    last_name = Map.get(user, :last_name) || Map.get(user, "last_name")
    email = Map.get(user, :email) || Map.get(user, "email")

    cond do
      first_name && last_name -> "#{first_name} #{last_name}"
      first_name -> first_name
      last_name -> last_name
      email -> email
      true -> pgettext("user menu, fallback username", "Unknown User")
    end
  end

  def user_email(user) do
    Map.get(user, :email) || Map.get(user, "email") || ""
  end
end
