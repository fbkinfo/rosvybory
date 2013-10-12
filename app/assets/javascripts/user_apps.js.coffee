# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require jquery.maskedinput.js

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
    $('#user_app_uic').select2("enable", uic_enabled)

  updateCurrentRoles = ->
    $(".js-current-role-checked").trigger("change")

  $('select.selectify').select2
    placeholder: "Начните вводить название"

  $('#user_app_region_id').select2
    placeholder: "Не важен/любой из округа"
    allowClear: true

  $("#user_app_uic").select2
    tags:[]
    selectOnBlur: true
    formatNoMatches: ->
      "Введите номер УИК"
  
  $("#user_app_phone").mask("+7 (999) 999-99-99")

  $('#current_roles input.selectify').select2
    maximumSelectionSize: 1
    tags:[]
    selectOnBlur: true
    formatNoMatches: ->
      "Введите номер УИК"

  check_uic = (uic_str) ->
    rx = new RegExp(/^\d+$/)
    return 1 unless rx.test(uic_str)
    uic_num = parseInt( uic_str, 10 );
    return 2 unless 1 <= uic_num <= 3411 or 3601 <= uic_num <= 3792 or 4001 <= uic_num <= 4008
    return 0

  $("#user_app_uic, #current_roles input.selectify").on "select2-selecting", (e) ->
    chk = check_uic e.val
    if chk == 1
      alert "Неверный формат номера УИК!"
    else if chk == 2
      alert "Такого номера УИК в Москве не существует!"

    e.preventDefault() unless chk == 0

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
    $("##{textFieldId}").select2("enable", $el.is(":checked"))

  updateUicState()
  updateExpCounterState()
  updateSubmitState()
  updateCurrentRoles()
  verification = new PhoneVerification
