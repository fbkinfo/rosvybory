$ ->
  $("#index_table_user_apps .reject_link").on("ajax:success", (e, data, status, xhr) ->
    $row = $("#user_app_"+$(this).data('user-app-id'))
    $row.html('<td> Отклонено! Тут можно вставить ссылку на отмену действия </td>')
  ).bind "ajax:error", (e, xhr, status, error) ->
    alert xhr.responseText

  bindDialogOnClick $("#index_table_user_apps .accept_link"), "Утверждение заявки"


  $("body").on "app-status-change", (event, app_id, status) ->
#    if current_scope does not include status
#      #        $("#user_app_"+gon.user_app_id).remove() - убрать всю строчку
##        $(this).closest("tr").fadeOut(
## -> $(this).remove(); ) - убрать всю строчку
#    else

    $(".accept_link[data-user-app-id=#{app_id}]").remove()

