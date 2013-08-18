$ ->
  admRegionSelector = "[data-role='adm-region-select']"

  $("body").on "change", admRegionSelector, (e) ->
    admRegion = $(@)
    currentRole = admRegion.parents("[data-role='user-fields-container']")
    regionSelect = currentRole.find("[data-role='region-select']")

    currentValue = admRegion.val()

    regionSelect.empty() # remove old options
    $.each regions[currentValue], (index, region) ->
      regionSelect.append $("<option></option>").attr("value", region.id).text(region.name)
    regionSelect.select2("val", "")
