# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $("#data_processing_allowed").change (e)->
    processing_allowed = $(this).prop('checked')
    $btn = $(".form-actions input[type=submit]")
    $btn.prop('disabled', !processing_allowed).toggleClass('btn-primary', processing_allowed)