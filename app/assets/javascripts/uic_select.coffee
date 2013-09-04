$ ->
  # TODO(sinopalnikov): unify it with region_select.coffee
  regionSelector = "[data-role='region-select']"

  $("body").on "change", regionSelector, (e) ->
    region = $(@)
    currentRole = region.parents("[data-role='user-fields-container']")
    uicSelect = currentRole.find("[data-role='uic-select']")

    currentValue = region.val()

    uicSelect.empty() # remove old options
    $.each (window.uics || {})[currentValue] || region.data('uics')[currentValue], (index, uic) ->
      uicSelect.append $("<option></option>").attr("value", uic.id).text(uic.name)
    uicSelect.select2("val", "")
