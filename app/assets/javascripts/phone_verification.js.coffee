class PhoneVerification
  constructor: ->
    unless @confirmed()
      @init_form()
      @init_controls()

  confirmed: =>
    confirmed = $("#user_app_phone").data('confirmed')
    @success_message()
    $("#user_app_phone").attr('readonly', 'readonly')
    confirmed

  init_form: =>
    $('#user_app_phone_input .controls').append('
    <input type="button" id="verification_start_button" class="btn btn-warning" value="Подтвердить">
    <div id="verification_controls">
      <input type="text" id="verification_code" class="input-small" placeholder="Код"/>
      <input type="button" name="" class="btn btn-warning" id="verification_confirm_button" value="Отправить"/>
    </div>')

  init_controls: =>
    $('#verification_start_button').on 'click', (e)=>
      e.preventDefault()
      $(this).attr('disabled', 'disabled')
      number = $('#user_app_phone').attr('readonly', 'readonly').val()
      @start_verification(number)

    $('#verification_confirm_button').on 'click', (e)=>
      e.preventDefault()
      $(this).attr('disabled', 'disabled')
      code = $('#verification_code').val()
      @complete_verification(code)

  start_verification: (number)=>
    $.ajax
      url: '/verifications'
      data: $.param(phone_number: number)
      method: 'POST'
      success: (data)=>
        @on_success(data)
      error: =>
        @on_error()

  complete_verification: (code)=>
    $.ajax
      url: '/verifications/confirm'
      data: $.param(verification_code: code)
      method: 'POST'
      success: (data)=>
        if data.success
          $('#verification_controls').hide()
          @hide_error()
          @success_message()
        else
          @error_message('Неправильный код подтверждения')
          $('#verification_confirm_button').removeAttr('disabled')

  on_success: (data)=>
    if data.success
      $('#verification_start_button').hide()
      $('#verification_controls').css('display', 'inline-block')
      @hide_error()
    if data.error
      @error_message(data.error)
      @restore()

  on_error: =>
    alert('Ошибка отправки запроса')
    @restore()

  restore: =>
    $('#user_app_phone').removeAttr('readonly')

  success_message: =>
    span = $(' <span class="help-inline label label-success"></span>')
    $("#user_app_phone_input .controls").append(span)
    span.html('Успешно подтвержден')

    # HOOK HERE чтобы задействовать кнопку для отправки формы

  error_message: (message)=>
    span = $("#user_app_phone_input span.help-inline")
    if span.length == 0
      span = $('<span class="help-inline label label-warning"></span>')
      $("#user_app_phone_input .controls").append(span)
    span.html(message)

  hide_error: =>
    $("#user_app_phone_input span.help-inline").hide()


window.PhoneVerification = PhoneVerification
