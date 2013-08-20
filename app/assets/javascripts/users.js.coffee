@getDialog = (user_app_id) ->
  $("#dialog_"+user_app_id)

@initAcceptForm = ->

  $(".verify_link").on("ajax:success", (e, data, status, xhr) ->
    $(this).closest(".unverified").html('Данные подтверждены!').fadeOut()
    $("#user_app_"+gon.user_app_id+" .status_tag.error").removeClass("error").addClass("ok")
  ).bind "ajax:error", (e, xhr, status, error) ->
    alert xhr.responseText


  $("form#new_user").bind("ajax:beforeSend", (evt, xhr, settings) ->
    $submitButton = $(this).find('input[name="commit"]')
    $submitButton.data "origText", $submitButton.attr('value')
    $submitButton.attr('value',"Сохранение...");
  )
  .bind("ajax:success", (evt, data, status, xhr) ->
    $dialog = getDialog(gon.user_app_id)
    try
      response = $.parseJSON(xhr.responseText)
      if response.status == "ok"
        $dialog.dialog('close');
        $(".accept_link[data-user-app-id=#{gon.user_app_id}]").remove()
#        $("#user_app_"+gon.user_app_id).remove() - убрать всю строчку
      else
        $dialog.html(xhr.responseText)
    catch err
      $dialog.html(xhr.responseText)
  ).bind("ajax:complete", (evt, xhr, status) ->
    $submitButton = $(this).find("input[name=\"commit\"]")
    $submitButton.attr('value',$submitButton.data("origText"));

  ).bind "ajax:error", (evt, xhr, status, error) ->
    alert "Произошла ошибка! Перезагрузите страницу и попробуйте ещё раз"
    getDialog(gon.user_app_id).html(xhr.responseText)

  selectify($("select.select2"));