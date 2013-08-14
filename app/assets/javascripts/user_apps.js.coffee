# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  updateSubmitState = ->
    submit_enabled = $("#user_app_data_processing_allowed").prop('checked')
    $(".form-actions input[type=submit]")
      .prop('disabled', !submit_enabled)
      .toggleClass('btn-primary', submit_enabled)

  updateExpCounterState = ->
    has_exp = $("#experience :checkbox:checked").length > 0
    $count = $("#user_app_experience_count")
      .prop('disabled', !has_exp)
      .prop 'min', +has_exp
    if has_exp && $count.val() == "0"
      $count.val 1
    else if !has_exp && $count.val() != "0"
      $count.val 0

  updateUicState = ->
    uic_enabled = $('#user_app_can_be_observer').prop('checked')
    $('#user_app_uic').prop('disabled', !uic_enabled)

  updateCurrentRoles = ->
    $(".js-current-role-checked").trigger("change")

  $('#user_app_adm_region_id').select2
    placeholder: "Начните вводить название"

  $('#user_app_region_id').select2
    placeholder: "Не важен/любой из округа"
    allowClear: true

  $("#user_app_adm_region_id").on "change", (e) ->
    chosen_val = $(@).val()
    $el = $("#user_app_region_id")
    $el.empty(); # remove old options
    $el.append $("<option></option>").attr("value", "")
    $.each regions[chosen_val], (index, region) ->
      $el.append $("<option></option>").attr("value", region.id).text(region.name)
    $el.select2("val", "")

  $('#user_app_can_be_observer').change (e)->
    updateUicState()

  $("#experience :checkbox").change (e)->
    updateExpCounterState()

  $("#user_app_data_processing_allowed").change (e)->
    updateSubmitState()

  $(".js-current-role-checked").change (e) ->
    $el = $(this)
    textFieldId = $el.attr("id").replace(/keep$/, "value")
    if ($el.is(":checked"))
      $("##{textFieldId}").attr("disabled", false)
    else
      $("##{textFieldId}").attr("disabled", true)

  $('#start_verification_button').on 'click', (e)->
    e.preventDefault()
    phone_number = $('#user_app_phone').val()
    $.ajax
      url: '/verifications'
      data: $.param(phone_number: phone_number)
      method: 'POST'
      success: (data)->
        if data.success
          $('#user_app_phone').attr('readonly', 'readonly')
          $('#start_verification_button').hide()
          $('#verification_code_controls').removeClass('hidden')
          $('#phone_verification_error').addClass('hidden')
        if data.error
          $('#phone_verification_error').removeClass('hidden').html(data.error)

  $('#confirm_verification_button').on 'click', (e)->
    e.preventDefault()
    $.ajax
      url: '/verifications/confirm'
      data: $.param(verification_code: $('#verification_code').val())
      method: 'POST'
      success: (data)->
        if data.success
          $('#verification_code_controls').hide()
          $('#phone_verification_error').hide()
          console.log('confirmed!')
          alert('Телефон успешно подтвержден')
        else
          $('#phone_verification_error').removeClass('hidden').html('Неправильный код подтверждения')

  updateUicState()
  updateExpCounterState()
  updateSubmitState()
  updateCurrentRoles()

