jQuery ->
  markRowOfElemAs = (elem, cssClass)->
    row = elem.closest("tr")
    $(["approved", "needs-review", "rejected"]).each (index, item)->
      row.removeClass item
    row.addClass cssClass

  # Styling
  $(".control_call_center_reports.index td .rejected").each ()->
    markRowOfElemAs $(this), "rejected"

  $(document).on "change", ".control_call_center_reports.index td.approved select", ()->
    select = $(this)
    approvedStatus = $(this).closest("div")
    $.ajax
      method: "patch"
      url: select.data("path")
      dataType: "json"
      data:
        call_center_report:
          approved: select.val()
      success: (response)->
        if response.approved == true
          approvedStatus.attr "class", "approved"
          markRowOfElemAs select, "approved"
        else if response.approved == false
          approvedStatus.attr "class", "rejected"
          markRowOfElemAs select, "rejected"
        else if response.approved == null
          approvedStatus.attr "class", "needs-review"
          markRowOfElemAs select, "needs-review"
      error: (response)->
        alert "Ошибка: " + response.substr(0,200)

  $(document).on "change", ".control_call_center_reports.index select#change_violation_type", ()->
    select = $(this)
    div = $(this).closest("div")
    $.ajax
      method: "patch"
      url: select.data("path")
      dataType: "json"
      data:
        call_center_report:
          violation_attributes:
            violation_type_id: select.val()
      success: (response)->
        div.find("p.violation_type_name").html response.violation.violation_type.name
      error: (response)->
        alert "Ошибка: " + response.substr(0,200)