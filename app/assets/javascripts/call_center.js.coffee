//= require jquery
//= require select2
//= require handlebars

jQuery ->
  setCustomField = (inputName, val)->
    form = $("#new_call_center_report")
    input = form.find("input[name='#{inputName}']")
    if input.length
      if val != null
        input.val val
      else
        input.remove()
    else
      form.append "<input name='#{inputName}' type='hidden' value='#{val}'>"
  setUnknownUserWillBeSavedNotice = (fio)->
    text = "<span>Будет сохранён: </span><span class='value'>#{fio}</span>"
    form = $("#new_call_center_report")
    notice = form.find("#unknown-user-will-be-saved")
    if notice.length
      notice.html text
    else
      form.find("#call_center_report_reporter_attributes_user_id_input > .controls").prepend "<p id='unknown-user-will-be-saved'>#{text}</p>"

  $(".select2").each (i, e) ->
    select = $(e)
    options = {dropdownCssClass: "bigdrop"}
    if select.hasClass("ajax")
      options.ajax =
        url: select.data("source")
        dataType: "json"
        data: (term, page) ->
          q: term
          page: page
          per: 10
        results: (data, page) ->
          results: data

      options.initSelection = (element, callback) ->
        id = $(element).val()
        if id isnt "" && !!parseInt(id)
          $.ajax
            url: select.data("init-source")
            dataType: "json"
            data:
              id: id
            success: (data)->
              callback data

      # Save unknown reporter's name
      if select.attr("id") == "call_center_report_reporter_attributes_user_id"
        options.formatNoMatches = (term)->
          setUnknownUserWillBeSavedNotice term
          select.select2 "val", ""
          fio = term.split(" ")
          setCustomField "call_center_report[reporter_attributes][last_name]", fio[0]
          setCustomField "call_center_report[reporter_attributes][first_name]", fio[1]
          setCustomField "call_center_report[reporter_attributes][patronymic]", fio[2]
          Handlebars.compile($("#notice-save-unknown-reporter-template").html())
            last_name: fio[0]
            first_name: fio[1]
            patronymic: fio[2]
        select.on "select2-opening", ()->
          if $("#unknown-user-will-be-saved").length
            $(".select2-drop .select2-search input").val $("#unknown-user-will-be-saved .value").html()
        select.on "change", (e)->
          $("#unknown-user-will-be-saved").remove()
          setCustomField "call_center_report[reporter_attributes][last_name]", null
          setCustomField "call_center_report[reporter_attributes][first_name]", null
          setCustomField "call_center_report[reporter_attributes][patronymic]", null
        # Autofill data on change
        select.on "change", (e)->
          $('#call_center_report_reporter_attributes_phone').val(e.added.phone) if e.added
          select_uic = $('#call_center_report_reporter_attributes_uic_id')
          select_role = $('#call_center_report_reporter_attributes_current_role_id')
          $.ajax
            url: select.data('uic-by-user')
            data:
              user_id:  select.val()
            dataType: "json"
            success: (response) ->
              if response.uic
                select_uic.select2('val', response.uic.id, true)
              else
                select_uic.select2('val', '')
              select_role.select2('val', response.role_id)
        $(document). on "click", "#unknown-user-will-be-saved", ()->
          select.select2 "open"


    select.select2 options

  # Display uic panel on change it's number in form
  $("#call_center_report_reporter_attributes_uic_id").on "change", ()->
    select = $(this)
    $.ajax
      url: select.data("single-source").replace(":id", select.val())
      dataType: "html"
      success: (response)->
        $("#uic").replaceWith $(response).find("#uic")

  # Autofill reporter fields, when his phone is updated
  $('#call_center_report_reporter_attributes_phone').keyup ->
    $.ajax
      url: $(this).data('source')
      data:
        phone: $(this).val()
      dataType: "json"
      success: (response) ->
        select = $('#call_center_report_reporter_attributes_user_id')
        if response
          select.select2('val', response.id)
        else
          select.select2('val', '')
        select.trigger('change')

  $('input[type="submit"]').click ->
    window.external.WACMD("UNHOLD")

  $('#redirect-to-jurist, #redirect-to-mobile-group-dispatcher').click ->
    window.external.WACMD("TRANSFER", '9260121530')
