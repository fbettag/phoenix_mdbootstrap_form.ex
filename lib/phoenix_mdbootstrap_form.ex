defmodule PhoenixMDBootstrapForm do
  @moduledoc """
  Documentation for `PhoenixMDBootstrapForm` which provides helper methods for creating beautiful looking Material Design Bootstrap forms in Phoenix.

  ## Installation

  This package can be installed by adding `rrpproxy` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [
      {:phoenix_mdbootstrap_form, "~> 0.1.2"}
    ]
  end
  ```

  You may also alias this module in `web.ex`, so it's shorter to type in templates.

  ```elixir
  alias PhoenixMDBootstrapForm, as: MDF
  ```

  ## Usage

  In order to change markup of form elements to bootstrap-style, all you need is to prefix regular methods you aleady have with `PhoenixMDBootstrapForm`, or `MDF` if you created an alias.

  For example:

  ```elixir
  <%= form_for @changeset, "/", fn f -> %>
    <%= MDF.text_input f, :value %>
    <%= MDF.submit f %>
  <% end %>
  ```

  Becomes bootstrap-styled:

  ```html
  <form accept-charset="UTF-8" action="/" method="post">
    <div class="form-group row">
      <label class="col-form-label text-sm-right col-sm-2" for="record_value">
        Value
      </label>
      <div class="col-sm-10">
        <input class="form-control" id="record_value" name="record[value]" type="text">
      </div>
    </div>
    <div class="form-group row">
      <div class="col-sm-10 ml-auto">
        <button class="btn" type="submit">Submit</button>
      </div>
    </div>
  </form>
  ```

  This library generates [horizonal form](https://mdbootstrap.com/docs/jquery/forms/basic/) layout that collapses down on small screens.

  You can always fall-back to default [Phoenix.HTML.Form](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html) methods if bootstrapped ones are not good enough.

  Currently this module supports following methods:

  * text_input
  * file_input
  * email_input
  * password_input
  * textarea
  * telephone_input
  * number_input
  * select
  * time_select
  * date_select
  * datetime_select
  * multi_select
  * checkbox
  * checkboxes
  * radio_buttons
  * submit
  * static

  [For quick reference you can look at this template](demo/lib/demo_web/templates/page/index.html.eex).
  You can `mix phx.server` inside demo folder to see this reference template rendered.

  ### Labels

  To set your own label you can do something like this:

  ```elixir
  <%= MDF.text_input f, :value, label: [text: "Custom"] %>
  ```

  ### CSS Classes

  To add your own css class to the input element / controls do this:

  ```elixir
  <%= MDF.text_input f, :value, input: [class: "custom"] %>
  ```

  ### Help Text

  You can add help text under the input. It could also be rendered template with
  links, tables, and whatever else.

  ```elixir
  <%= MDF.text_input f, :value, input: [help: "Help text"] %>
  ```

  ### Prepending and Appending Inputs

  ```elixir
  <%= MDF.text_input f, :value, input: [prepend: "$", append: ".00"] %>
  ```

  ### Radio Buttons

  You don't need to do multiple calls to create list of radio buttons. One method
  will do them all:

  ```elixir
  <%= MDF.radio_buttons f, :value, ["red", "green"] %>
  ```

  or with custom labels:

  ```elixir
  <%= MDF.radio_buttons f, :value, [{"R", "red"}, {"G", "green"}] %>

  ```

  or rendered inline:

  ```elixir
  <%= MDF.radio_buttons f, :value, ["red", "green", "blue"], input: [inline: true] %>
  ```

  ### Select

  Works just like the standard `select` or `multiple_select` provided by Phoenix:

  ```elixir
  <%= MDF.select f, :value, ["red", "green", "blue"] %>
  ```

  or use a multiple select field:

  ```elixir
  <%= MDF.multiple_select f, :value, ["red", "green", "blue"] %>
  ```

  ### Checkboxes

  Very similar to `multiple_select` in functionality, you can render collection of
  checkboxes. Other options are the same as for `radio_buttons`

  ```elixir
  <%= MDF.checkboxes f, :value, ["red", "green", "blue"], selected: ["green"] %>
  ```


  ### Submit Buttons

  Besides simple `MDF.submit f` you can define custom label and content that goes
  next to the button. For example:

  ```elixir
  <% cancel = link "Cancel", to: "/", class: "btn btn-link" %>
  <%= MDF.submit f, "Smash", class: "btn-primary", alternative: cancel %>
  ```

  ### Static Elements

  When you need to render a piece of content in the context of your form. For example:

  ```elixir
  <%= MDF.static f, "Current Avatar", avatar_image_tag %>
  ```

  ### Form Errors

  If changeset is invalid, form elements will have `.is-invalid` class added and
  `.invalid-feedback` container will be appended with an error message.

  In order to properly pull in i18n error messages specify `translate_error`
  function that handles it:

  ```elixir
  config :phoenix_mdbootstrap_form, [
    translate_error_function: &MyApp.ErrorHelpers.translate_error/1
  ]
  ```

  ### Custom Grid and Label Alignment

  By default `.col-sm-2` and `.col-sm-10` used for label and control colums respectively.
  You can change that by passing `label_col` and `control_col` with `form_for` like this:

  ```elixir
  <% opts = [label_col: "col-sm-4", control_col: "col-sm-8", label_align: "text-sm-left"] %>
  <%= form_for @changeset, "/", opts, fn f -> %>

  ```

  If you need to change it application-wide just edit your `config.exs` and play around with these:

  ```elixir
  config :phoenix_mdbootstrap_form,
    label_col_class:    "col-form-label col-sm-2",
    control_col_class:  "col-sm-10",
    label_align_class:  "text-sm-right",
    form_group_class:   "form-group row"

  ```

  ### Credit

  This repository has been forked from [GBH's phoenix_bootstrap_form](https://github.com/GBH/phoenix_bootstrap_form) and i just adjusted it for Material Design Bootstrap.

  """

  alias Phoenix.HTML
  alias Phoenix.HTML.{Tag, Form}

  @label_col_class "col-form-label col-sm-2"
  @control_col_class "col-sm-10"
  @label_align_class "text-sm-right"
  @form_group_class "form-group row"

  defp special_select(form = %Form{}, field, icon, class, opts) do
    input =
      Tag.content_tag :div, class: control_col_class(form) do
        is_valid_class = is_valid_class(form, field)

        input_opts =
          [class: "form-control #{is_valid_class} #{class}"] ++
            Keyword.get(opts, :input, []) ++
            Keyword.get(opts, :multiple, [])

        prepend = Tag.content_tag(:i, "", class: "fas input-prefix #{icon}")
        {help, input_opts} = Keyword.pop(input_opts, :help)

        input =
          draw_input(:text_input, form, field, nil, input_opts)
          |> draw_input_group(prepend, nil)

        help = draw_help(help)
        error = draw_error_message(get_error(form, field))

        [input, error, help]
      end

    Tag.content_tag :div, class: form_group_class(opts) do
      [
        draw_label(form, field, opts),
        input
      ]
    end
  end

  @doc "Creates a time-select field."
  def time_select(form = %Form{}, field, opts \\ []) do
    special_select(form, field, "fa-clock", "time-picker", opts)
  end

  @doc "Creates a date-select field."
  def date_select(form = %Form{}, field, opts \\ []) do
    special_select(form, field, "fa-calendar", "date-picker", opts)
  end

  @doc "Creates a datetime-select field."
  def datetime_select(form = %Form{}, field, opts \\ []) do
    special_select(form, field, "fa-calendar", "date-time-picker", opts)
  end

  @doc "Creates a select field."
  def select(form = %Form{}, field, options, opts \\ []) do
    draw_generic_input(:select, form, field, options, opts)
  end

  @doc "Creates a multiple-select field."
  def multiple_select(form = %Form{}, field, options, opts \\ []) do
    multi_opts = Keyword.put_new(opts, :multiple, multiple: true)
    draw_generic_input(:select, form, field, options, multi_opts)
  end

  [
    :text_input,
    :file_input,
    :email_input,
    :password_input,
    :textarea,
    :telephone_input,
    :number_input
  ]
  |> Enum.each(fn method ->
    @doc "Creates a simple form field."
    def unquote(method)(form = %Form{}, field, opts \\ []) when is_atom(field) do
      draw_generic_input(unquote(method), form, field, nil, opts)
    end
  end)

  @doc "Creates a checkbox field."
  def checkbox(form = %Form{}, field, opts \\ []) do
    {label_opts, opts} = Keyword.pop(opts, :label, [])
    {input_opts, _} = Keyword.pop(opts, :input, [])
    {help, input_opts} = Keyword.pop(input_opts, :help)

    label =
      case Keyword.get(label_opts, :show, true) do
        true -> Keyword.get(label_opts, :text, Form.humanize(field))
        false -> ""
      end

    checkbox =
      Form.checkbox(form, field, class: "form-check-input " <> is_valid_class(form, field))

    for_attr = Form.input_id(form, field)
    help = draw_help(help)
    error = draw_error_message(get_error(form, field))

    content =
      Tag.content_tag :div, class: "#{control_col_class(form)} ml-auto" do
        [
          draw_form_check(checkbox, label, for_attr, error, input_opts[:inline]),
          help
        ]
      end

    draw_form_group("", content, opts)
  end

  @doc "Creates multiple checkbox fields."
  def checkboxes(form = %Form{}, field, values, opts \\ []) when is_list(values) do
    values = add_labels_to_values(values)

    {input_opts, opts} = Keyword.pop(opts, :input, [])
    {help, input_opts} = Keyword.pop(input_opts, :help)
    {selected, opts} = Keyword.pop(opts, :selected, [])

    input_id = Form.input_id(form, field)
    help = draw_help(help)
    error = draw_error_message(get_error(form, field))

    inputs =
      values
      |> Enum.with_index()
      |> Enum.map(fn {{label, value}, index} ->
        value = elem(HTML.html_escape(value), 1)

        # error needs to show up only on last element
        input_error =
          if Enum.count(values) - 1 == index do
            error
          else
            ""
          end

        input_class = "form-check-input " <> is_valid_class(form, field)

        value_id = value |> String.replace(~r/\s/, "")
        input_id = input_id <> "_" <> value_id

        input =
          Tag.tag(
            :input,
            name: Form.input_name(form, field) <> "[]",
            id: input_id,
            type: "checkbox",
            value: value,
            class: input_class,
            checked: Enum.member?(selected, value)
          )

        draw_form_check(
          input,
          label,
          input_id,
          input_error,
          input_opts[:inline]
        )
      end)

    content =
      Tag.content_tag :div, class: "#{control_col_class(form)}" do
        [inputs, help]
      end

    opts = Keyword.put_new(opts, :label, [])
    opts = put_in(opts[:label][:span], true)

    draw_form_group(
      draw_label(form, field, opts),
      content,
      opts
    )
  end

  @doc "Creates radio buttons."
  def radio_buttons(form = %Form{}, field, values, opts \\ []) when is_list(values) do
    values = add_labels_to_values(values)

    {input_opts, opts} = Keyword.pop(opts, :input, [])
    {help, input_opts} = Keyword.pop(input_opts, :help)

    input_id = Form.input_id(form, field)
    help = draw_help(help)
    error = draw_error_message(get_error(form, field))

    inputs =
      values
      |> Enum.with_index()
      |> Enum.map(fn {{label, value}, index} ->
        value = elem(HTML.html_escape(value), 1)

        # error needs to show up only on last element
        radio_error =
          if Enum.count(values) - 1 == index do
            error
          else
            ""
          end

        radio_class = "form-check-input " <> is_valid_class(form, field)

        value_id = value |> String.replace(~r/\s/, "")
        input_id = input_id <> "_" <> value_id

        draw_form_check(
          Form.radio_button(form, field, value, class: radio_class),
          label,
          input_id,
          radio_error,
          input_opts[:inline]
        )
      end)

    content =
      Tag.content_tag :div, class: "#{control_col_class(form)}" do
        [inputs, help]
      end

    opts = Keyword.put_new(opts, :label, [])
    opts = put_in(opts[:label][:span], true)

    draw_form_group(
      draw_label(form, field, opts),
      content,
      opts
    )
  end

  @doc "Creates submit button."
  def submit(form = %Form{}, opts) when is_list(opts), do: draw_submit(form, nil, opts)

  @doc "Creates submit button."
  def submit(form = %Form{}, label), do: draw_submit(form, label, [])

  @doc "Creates submit button."
  def submit(form = %Form{}, label, opts \\ []), do: draw_submit(form, label, opts)

  @doc "Creates submit button."
  def submit(form = %Form{}), do: draw_submit(form, nil, [])

  @doc "Creates static form field without any field required in the changeset."
  def static(form = %Form{}, label, content) do
    label =
      Tag.content_tag(
        :label,
        label,
        class: "#{label_col_class(form)} #{label_align_class(form)}"
      )

    content =
      Tag.content_tag(:div, content, class: "form-control-plaintext #{control_col_class(form)}")

    draw_form_group(label, content, [])
  end

  # -- Private methods ---------------------------------------------------------
  defp label_col_class(form) do
    default = Application.get_env(:phoenix_mdbootstrap_form, :label_col_class, @label_col_class)
    Keyword.get(form.options, :label_col, default)
  end

  defp control_col_class(form) do
    default =
      Application.get_env(:phoenix_mdbootstrap_form, :control_col_class, @control_col_class)

    Keyword.get(form.options, :control_col, default)
  end

  defp label_align_class(form) do
    default =
      Application.get_env(:phoenix_mdbootstrap_form, :label_align_class, @label_align_class)

    Keyword.get(form.options, :label_align, default)
  end

  defp form_group_class(opts) do
    default = Application.get_env(:phoenix_mdbootstrap_form, :form_group_class, @form_group_class)
    Keyword.get(opts, :form_group, default)
  end

  defp merge_css_classes(opts) do
    {classes, rest} = Keyword.split(opts, [:class])

    class =
      classes
      |> Keyword.values()
      |> Enum.join(" ")

    [class: class] ++ rest
  end

  defp is_valid_class(form, field) do
    case has_error?(form, field) do
      true -> "is-invalid"
      _ -> ""
    end
  end

  defp has_error?(%Form{errors: errors}, field), do: Keyword.has_key?(errors, field)
  defp has_error?(_, _), do: false

  defp get_error(form, field) do
    case has_error?(form, field) do
      true ->
        msg = form.errors[field] |> elem(0)
        opts = form.errors[field] |> elem(1)
        translate_error(msg, opts)

      _ ->
        nil
    end
  end

  defp add_labels_to_values(values) when is_list(values) do
    Enum.into(values, [], fn value ->
      case value do
        {k, v} -> {k, v}
        v -> {Form.humanize(v), v}
      end
    end)
  end

  defp draw_generic_input(type, form, field, options, opts) do
    draw_form_group(
      draw_label(form, field, opts),
      draw_control(type, form, field, options, opts),
      opts
    )
  end

  defp draw_control(:file_input = type, form, field, options, opts) do
    Tag.content_tag :div, class: "custom-file #{control_col_class(form)}" do
      is_valid_class = is_valid_class(form, field)

      input_opts =
        [class: "custom-file-input #{is_valid_class}"] ++
          Keyword.get(opts, :input, [])

      {prepend, input_opts} = Keyword.pop(input_opts, :prepend)
      {append, input_opts} = Keyword.pop(input_opts, :append)
      {help, input_opts} = Keyword.pop(input_opts, :help)

      input =
        draw_input(type, form, field, options, input_opts)
        |> draw_input_group(prepend, append)

      help = draw_help(help)
      error = draw_error_message(get_error(form, field))
      label = Tag.content_tag(:label, "", class: "custom-file-label")

      [input, label, error, help]
    end
  end

  defp draw_control(type, form, field, options, opts) do
    Tag.content_tag :div, class: control_col_class(form) do
      is_valid_class = is_valid_class(form, field)

      input_opts =
        [class: "form-control #{is_valid_class}"] ++
          Keyword.get(opts, :input, []) ++
          Keyword.get(opts, :multiple, [])

      {prepend, input_opts} = Keyword.pop(input_opts, :prepend)
      {append, input_opts} = Keyword.pop(input_opts, :append)
      {help, input_opts} = Keyword.pop(input_opts, :help)

      input =
        draw_input(type, form, field, options, input_opts)
        |> draw_input_group(prepend, append)

      help = draw_help(help)
      error = draw_error_message(get_error(form, field))

      [input, error, help]
    end
  end

  defp draw_input(:select, form, field, options, opts) do
    Form.select(form, field, options, merge_css_classes(opts))
  end

  defp draw_input(type, form, field, nil, opts) do
    apply(Form, type, [form, field, merge_css_classes(opts)])
  end

  defp draw_form_group(label, content, opts) do
    Tag.content_tag :div, class: form_group_class(opts) do
      [label, content]
    end
  end

  defp draw_label(form, field, opts) when is_atom(field) do
    label_opts = Keyword.get(opts, :label, [])

    if Keyword.get(label_opts, :show, true) do
      {text, label_opts} = Keyword.pop(label_opts, :text, Form.humanize(field))

      label_opts = [class: "#{label_col_class(form)} #{label_align_class(form)}"] ++ label_opts

      label_opts = merge_css_classes(label_opts)

      {is_span, label_opts} = Keyword.pop(label_opts, :span, false)

      if is_span do
        Tag.content_tag(:span, text, label_opts)
      else
        Form.label(form, field, text, label_opts)
      end
    else
      Tag.content_tag(:span, "")
    end
  end

  defp draw_input_group(input, nil, nil), do: input

  defp draw_input_group(input, prepend, append) do
    Tag.content_tag :div, class: "input-group" do
      [
        draw_input_group_addon_prepend(prepend),
        input,
        draw_input_group_addon_append(append)
      ]
    end
  end

  defp draw_input_group_addon_prepend(nil), do: ""

  defp draw_input_group_addon_prepend(content) do
    text = Tag.content_tag(:span, content, class: "input-group-text")
    Tag.content_tag(:div, text, class: "input-group-prepend")
  end

  defp draw_input_group_addon_append(nil), do: ""

  defp draw_input_group_addon_append(content) do
    text = Tag.content_tag(:span, content, class: "input-group-text")
    Tag.content_tag(:div, text, class: "input-group-append")
  end

  defp draw_help(nil), do: ""

  defp draw_help(content) do
    Tag.content_tag(:small, content, class: "form-text text-muted")
  end

  defp draw_submit(form = %Form{}, label, opts) do
    {alternative, opts} = Keyword.pop(opts, :alternative, "")
    opts = [class: "btn"] ++ opts

    content =
      Tag.content_tag :div, class: "#{control_col_class(form)} ml-auto" do
        [Form.submit(label || "Submit", merge_css_classes(opts)), alternative]
      end

    draw_form_group("", content, opts)
  end

  defp draw_form_check(input, label, for_attr, error, is_inline) do
    inline_class = if is_inline, do: "form-check-inline", else: ""
    label = Tag.content_tag(:label, label, for: for_attr, class: "form-check-label")

    Tag.content_tag :div, class: "form-check #{inline_class}" do
      [input, label, error]
    end
  end

  defp draw_error_message(nil), do: ""

  defp draw_error_message(message) do
    Tag.content_tag(:div, message, class: "invalid-feedback")
  end

  defp translate_error(msg, opts) do
    default_fn = fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end

    translate_error_fn =
      Application.get_env(:phoenix_mdbootstrap_form, :translate_error_function, default_fn)

    translate_error_fn.({msg, opts})
  end
end
