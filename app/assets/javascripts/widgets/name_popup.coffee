class AntCat.NamePopup extends AntCat.NestedForm

  constructor: (@parent_element, @options = {}) ->
    @element = @parent_element.find('> .antcat_name_popup')
    @options.button_container = '.buttons'
    super @element, @options
    console.log 'NamePopup ctor: no @element' unless @element.size() == 1

    @id = @element.find('#id').val()
    @original_id = @id
    if @id
      @load ''
    else
      @initialize()
    @

  form: =>
    AntCat.NestedForm.create_form_from @element.find '.nested_form'

  load: (url = '') =>
    if url.indexOf('/name_popup') is -1
      url = '/name_popup?' + url
    url = url + '&' + $.param id: @id if @id
    @start_throbbing()
    $.ajax
      url: url
      dataType: 'html'
      success: (data) =>
        @element.replaceWith data
        @element = @parent_element.find '> .antcat_name_popup'
        @initialize
        @element.find('#id').val(@id)
      error: (xhr) => debugger

  initialize: =>
    @textbox = @element.find('input[type=text]')
    console.log 'NamePopup initialize: no @textbox' unless @textbox.size() == 1
    @setup_autocomplete @textbox
    @textbox.focus()

  start_throbbing: =>
    @element.find('.throbber img').show()
    @element.find('> .controls').disable()

  submit: =>
    return false if @textbox.val().length == 0
    @element.find('.error_messages').text('')
    super
    false

  before_submit: (form, options) =>
    # form is an array of name-value pairs (from jQuery Form)
    alert '4th element is not add_name' unless form[4].name == 'add_name'
    if @deciding_whether_to_add_name
      form[4].value = 'true'
    else
      form[4].value = ''
    true

  handle_success: (data) =>
    @element.find('.buttons .submit').val('OK')
    @id = data.id
    @element.find('#id').val @id
    @element.find('#name').val data.name
    @element.find('#taxt').val data.taxt
    @element.find('#taxon_id').val data.taxon_id
    super

  handle_application_error: (error_message) =>
    # an error means that the name the user entered doesn't exist
    # we ask if they want to add it
    @element.find('.buttons .submit').val('Add this name')
    @element.find('.error_messages').text error_message
    @deciding_whether_to_add_name = true

  cancel: =>
    @element.find('.error_messages').text ''
    if @deciding_whether_to_add_name
      @element.find('.buttons .submit').val('OK')
    @id = @original_id
    if @id
      @load '',
    else
      @initialize
    super unless @deciding_whether_to_add_name
    @deciding_whether_to_add_name = false
    false

  # -----------------------------------------
  setup_autocomplete: ($textbox) =>
    console.log 'NamePopup setup_autocomplete: no $textbox' unless $textbox.size() == 1
    return if AntCat.testing
    $textbox.autocomplete(
        autoFocus: true,
        source: "/name_popups",
        minLength: 3)
      .data('autocomplete')._renderItem = @render_item

  # this is required to display HTML in the list
  render_item: (ul, item) =>
    $("<li>")
      .data('item.autocomplete', item)
      .append('<a>' + item.label + '</a>')
      .appendTo ul