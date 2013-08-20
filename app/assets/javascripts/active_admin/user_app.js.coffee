$ ->
  $(".reject_link").on("ajax:success", (e, data, status, xhr) ->
    $row = $("#user_app_"+$(this).data('user-app-id'))
    $row.html('<td> Отклонено! Тут можно вставить ссылку на отмену действия </td>')
  ).bind "ajax:error", (e, xhr, status, error) ->
    alert xhr.responseText

  $(".accept_link").on("click", (e) ->
    user_app_id = $(this).data('user-app-id')
    $dialog = $("<div id='dialog_#{user_app_id}'>Загружаю...</div>").dialog(
      autoOpen: false
      height: 500
      width: 600
      title: "Утверждение заявки"
    )

    $dialog.load(this.href).dialog('open');
    false
  )


@initAcceptForm = ->
  selectify($("select.select2"));

  $(".verify_link").on("ajax:success", (e, data, status, xhr) ->
    alert 'Данные подтверждены!'
    $("#unverified").fadeOut()
  ).bind "ajax:error", (e, xhr, status, error) ->
    alert xhr.responseText