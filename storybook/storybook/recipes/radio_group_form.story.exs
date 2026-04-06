defmodule Storybook.Recipes.RadioGroupForm do
  @moduledoc """
  Bug reproduction: radio_group with field binding in a LiveView form.

  When clicking a radio button, the selection flashes correctly then resets
  because `radio_group_item` computes `checked` incorrectly — all items
  end up truthy on re-render, and the DOM patch overwrites JS state.
  """
  use PhoenixStorybook.Story, :example
  use Cognit

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       form: to_form(%{"vehicle_type" => ""}, as: "empty"),
       preset_form: to_form(%{"vehicle_type" => "motorcycle"}, as: "preset")
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-12 max-w-sm space-y-8">
      <div class="space-y-4">
        <h3 class="text-sm font-medium">Empty initial value</h3>
        <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-4">
          <.form_item>
            <.form_label>Vehicle Type</.form_label>
            <.form_control>
              <.radio_group field={@form[:vehicle_type]}>
                <div class="flex flex-col space-y-2">
                  <div class="flex items-center space-x-2">
                    <.radio_group_item value="car" id="car" field={@form[:vehicle_type]} />
                    <.label for="car_car">Car</.label>
                  </div>
                  <div class="flex items-center space-x-2">
                    <.radio_group_item
                      value="motorcycle"
                      id="motorcycle"
                      field={@form[:vehicle_type]}
                    />
                    <.label for="motorcycle_motorcycle">Motorcycle</.label>
                  </div>
                  <div class="flex items-center space-x-2">
                    <.radio_group_item value="truck" id="truck" field={@form[:vehicle_type]} />
                    <.label for="truck_truck">Truck</.label>
                  </div>
                </div>
              </.radio_group>
            </.form_control>
          </.form_item>
          <.button type="submit">Save</.button>
        </.form>
        <p class="text-sm text-muted-foreground">
          Selected: {@form[:vehicle_type].value || "none"}
        </p>
      </div>

      <.separator />

      <div class="space-y-4">
        <h3 class="text-sm font-medium">With initial value (motorcycle)</h3>
        <.form
          for={@preset_form}
          phx-change="validate_preset"
          phx-submit="save_preset"
          class="space-y-4"
        >
          <.form_item>
            <.form_label>Vehicle Type</.form_label>
            <.form_control>
              <.radio_group field={@preset_form[:vehicle_type]}>
                <div class="flex flex-col space-y-2">
                  <div class="flex items-center space-x-2">
                    <.radio_group_item
                      value="car"
                      id="preset-car"
                      field={@preset_form[:vehicle_type]}
                    />
                    <.label for="preset-car_car">Car</.label>
                  </div>
                  <div class="flex items-center space-x-2">
                    <.radio_group_item
                      value="motorcycle"
                      id="preset-motorcycle"
                      field={@preset_form[:vehicle_type]}
                    />
                    <.label for="preset-motorcycle_motorcycle">Motorcycle</.label>
                  </div>
                  <div class="flex items-center space-x-2">
                    <.radio_group_item
                      value="truck"
                      id="preset-truck"
                      field={@preset_form[:vehicle_type]}
                    />
                    <.label for="preset-truck_truck">Truck</.label>
                  </div>
                </div>
              </.radio_group>
            </.form_control>
          </.form_item>
          <.button type="submit">Save</.button>
        </.form>
        <p class="text-sm text-muted-foreground">
          Selected: {@preset_form[:vehicle_type].value || "none"}
        </p>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"empty" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: "empty"))}
  end

  def handle_event("validate_preset", %{"preset" => params}, socket) do
    {:noreply, assign(socket, preset_form: to_form(params, as: "preset"))}
  end

  def handle_event("save", %{"empty" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: "empty"))}
  end

  def handle_event("save_preset", %{"preset" => params}, socket) do
    {:noreply, assign(socket, preset_form: to_form(params, as: "preset"))}
  end
end
