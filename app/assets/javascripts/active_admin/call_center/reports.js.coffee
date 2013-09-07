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