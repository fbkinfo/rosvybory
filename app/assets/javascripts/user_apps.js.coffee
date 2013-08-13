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

  updateUicState()
  updateExpCounterState()
  updateSubmitState()

