$ ->
  $("#index_table_user_apps .reject_link").on("ajax:success", (e, data, status, xhr) ->
    $row = $(this).closest('tr')
    $row.html('<td> Отклонено! Тут можно вставить ссылку на отмену действия </td>')
  ).bind "ajax:error", (e, xhr, status, error) ->
    alert xhr.responseText

  bindDialogOnClick $(".accept_link"), "Утверждение заявки"


  $("body").on "app-status-change", (event, app_id, status) ->
#    if current_scope does not include status

    $(".accept_link[data-user-app-id=#{app_id}]").remove() #прячем линк на действие - для страницы просмотра заявки
    $row = $("#user_app_"+app_id)
    $row.fadeOut()

  $(document).on 'paste', 'table.many-new input', (e) ->
    txt = e.originalEvent.clipboardData.getData('text/plain')
    rows = txt.split("\n")
    first_row_length = rows[0].split("\t").length
    $tbody = $(this).closest('tbody')
    if first_row_length > 1
      $.each rows, () ->
        row = this.split("\t")
        $tbody.one 'cocoon:after-insert', (ev) ->
          $tr = $tbody.find('tr:last')
          $tr.find('input:visible').each (i) ->
            $(this).val(row[i])
        $tbody.closest('form').find('.add_fields').click()
      return false;
