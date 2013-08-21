$ ->
  $("#index_table_user_apps .reject_link").on("ajax:success", (e, data, status, xhr) ->
    $row = $(this).closest('tr')
    $row.html('<td> Отклонено! Тут можно вставить ссылку на отмену действия </td>')
  ).bind "ajax:error", (e, xhr, status, error) ->
    alert xhr.responseText

  bindDialogOnClick $(".accept_link"), "Утверждение заявки"


  $("body").on "app-status-change", (event, app_id, status) ->
#    if current_scope does not include status

#   $(".accept_link[data-user-app-id=#{app_id}]").remove() - спрятать действие
    $row = $("#user_app_"+app_id)
    $row.fadeOut()
