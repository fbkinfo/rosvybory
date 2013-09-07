jQuery ->
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
        else if response.approved == false
          approvedStatus.attr "class", "rejected"
        else if response.approved == null
          approvedStatus.attr "class", "needs-review"
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