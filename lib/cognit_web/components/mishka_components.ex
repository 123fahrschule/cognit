defmodule CognitWeb.Components.MishkaComponents do
  defmacro __using__(_) do
    quote do
      import CognitWeb.Components.Accordion, only: [accordion: 1, native_accordion: 1]
      import CognitWeb.Components.Alert, only: [flash: 1, flash_group: 1, alert: 1]
      import CognitWeb.Components.Avatar, only: [avatar: 1, avatar_group: 1]
      import CognitWeb.Components.Badge, only: [badge: 1]
      import CognitWeb.Components.Banner, only: [banner: 1]
      import CognitWeb.Components.Blockquote, only: [blockquote: 1]
      import CognitWeb.Components.Breadcrumb, only: [breadcrumb: 1]

      import CognitWeb.Components.Button,
        only: [button_group: 1, button: 1, input_button: 1, button_link: 1, back: 1]

      import CognitWeb.Components.Card,
        only: [card: 1, card_title: 1, card_media: 1, card_content: 1, card_footer: 1]

      import CognitWeb.Components.Carousel, only: [carousel: 1]
      import CognitWeb.Components.Chat, only: [chat: 1, chat_section: 1]
      import CognitWeb.Components.CheckboxCard, only: [checkbox_card: 1]
      import CognitWeb.Components.CheckboxField, only: [checkbox_field: 1, group_checkbox: 1]
      import CognitWeb.Components.Clipboard, only: [clipboard: 1]
      import CognitWeb.Components.ColorField, only: [color_field: 1]
      import CognitWeb.Components.Combobox, only: [combobox: 1]
      import CognitWeb.Components.DateTimeField, only: [date_time_field: 1]
      import CognitWeb.Components.DeviceMockup, only: [device_mockup: 1]
      import CognitWeb.Components.Divider, only: [divider: 1, hr: 1]
      import CognitWeb.Components.Drawer, only: [drawer: 1]

      import CognitWeb.Components.Dropdown,
        only: [dropdown: 1, dropdown_trigger: 1, dropdown_content: 1]

      import CognitWeb.Components.EmailField, only: [email_field: 1]
      import CognitWeb.Components.Fieldset, only: [fieldset: 1]
      import CognitWeb.Components.FileField, only: [file_field: 1]
      import CognitWeb.Components.Footer, only: [footer: 1, footer_section: 1]
      import CognitWeb.Components.FormWrapper, only: [form_wrapper: 1, simple_form: 1]

      import CognitWeb.Components.Gallery,
        only: [gallery: 1, gallery_media: 1, filterable_gallery: 1]

      import CognitWeb.Components.Icon, only: [icon: 1]
      import CognitWeb.Components.Image, only: [image: 1]
      import CognitWeb.Components.Indicator, only: [indicator: 1]
      import CognitWeb.Components.InputField, only: [input: 1, error: 1]
      import CognitWeb.Components.Jumbotron, only: [jumbotron: 1]
      import CognitWeb.Components.Keyboard, only: [keyboard: 1]
      import CognitWeb.Components.Layout, only: [flex: 1, grid: 1]
      import CognitWeb.Components.List, only: [list: 1, li: 1, ul: 1, ol: 1, list_group: 1]
      import CognitWeb.Components.MegaMenu, only: [mega_menu: 1]
      import CognitWeb.Components.Menu, only: [menu: 1]
      import CognitWeb.Components.Modal, only: [modal: 1]
      import CognitWeb.Components.NativeSelect, only: [native_select: 1, select_option_group: 1]
      import CognitWeb.Components.Navbar, only: [navbar: 1, header: 1]
      import CognitWeb.Components.NumberField, only: [number_field: 1]
      import CognitWeb.Components.Overlay, only: [overlay: 1]
      import CognitWeb.Components.Pagination, only: [pagination: 1]
      import CognitWeb.Components.PasswordField, only: [password_field: 1]

      import CognitWeb.Components.Popover,
        only: [popover: 1, popover_trigger: 1, popover_content: 1]

      import CognitWeb.Components.Progress,
        only: [progress: 1, progress_section: 1, semi_circle_progress: 1, ring_progress: 1]

      import CognitWeb.Components.RadioCard, only: [radio_card: 1]
      import CognitWeb.Components.RadioField, only: [radio_field: 1, group_radio: 1]
      import CognitWeb.Components.RangeField, only: [range_field: 1]
      import CognitWeb.Components.Rating, only: [rating: 1]
      import CognitWeb.Components.ScrollArea, only: [scroll_area: 1]
      import CognitWeb.Components.SearchField, only: [search_field: 1]
      import CognitWeb.Components.Sidebar, only: [sidebar: 1]
      import CognitWeb.Components.Skeleton, only: [skeleton: 1]
      import CognitWeb.Components.SpeedDial, only: [speed_dial: 1]
      import CognitWeb.Components.Spinner, only: [spinner: 1]
      import CognitWeb.Components.Stepper, only: [stepper: 1, stepper_section: 1]
      import CognitWeb.Components.Table, only: [table: 1, th: 1, tr: 1, td: 1]

      import CognitWeb.Components.TableContent,
        only: [table_content: 1, content_wrapper: 1, content_item: 1]

      import CognitWeb.Components.Tabs, only: [tabs: 1]
      import CognitWeb.Components.TelField, only: [tel_field: 1]
      import CognitWeb.Components.TextField, only: [text_field: 1]
      import CognitWeb.Components.TextareaField, only: [textarea_field: 1]
      import CognitWeb.Components.Timeline, only: [timeline: 1, timeline_section: 1]
      import CognitWeb.Components.Toast, only: [toast: 1, toast_group: 1]
      import CognitWeb.Components.ToggleField, only: [toggle_field: 1]
      import CognitWeb.Components.Tooltip, only: [tooltip: 1]

      import CognitWeb.Components.Typography,
        only: [
          h1: 1,
          h2: 1,
          h3: 1,
          h4: 1,
          h5: 1,
          h6: 1,
          p: 1,
          strong: 1,
          em: 1,
          dl: 1,
          dt: 1,
          dd: 1,
          figure: 1,
          figcaption: 1,
          abbr: 1,
          mark: 1,
          small: 1,
          s: 1,
          u: 1,
          cite: 1,
          del: 1
        ]

      import CognitWeb.Components.UrlField, only: [url_field: 1]
      import CognitWeb.Components.Video, only: [video: 1]
    end
  end
end
