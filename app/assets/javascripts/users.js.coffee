
uicRoles = ["psg", "prg"]
regionRoles = ["psg_tic", "prg_tic"]

updateRoleFields = (el) ->
  role = gon.current_roles[el.find("[data-role=current-role]").val()]
  $uic = el.find("[data-role=uic]").parent()
  $region = el.find("[data-role=region-select]").parent()
  $admRegion = el.find("[data-role=adm-region-select]").parent()

  if ($.inArray(role, uicRoles) != -1)
    $uic.show()
  else
    $uic.hide()

  if ($.inArray(role, regionRoles) != -1)
    $admRegion.show()
    $region.show()
  else
    $admRegion.hide()
    $region.hide()

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

  $(".formtastic.user").on "click", ".add_fields", ->
    setTimeout (->
      el = $("[data-role=user-fields-container]:last")
      updateRoleFields el
      el.change ->
        updateRoleFields $(this)

      selectify($("[data-role=user-fields-container] select"))
  #    el.find("[data-role=uic]").select2()
    ), 0

  $(".formtastic.user #user_role_ids").on "click", ->
    el =$("[data-role=observer-roles]")
    if ($.inArray(gon.observer_role_id + '', $(this).val()) != -1)
      el.removeClass("hidden")
    else
      el.addClass("hidden")

