# TODO replace with must_have_tic?/uic?
# uicRoles = ["psg", "prg", "observer", "journalist"]
# ticRoles = ["psg_tic", "prg_tic"]

updateRoleFields = ->
#  $(".user-current-role").change ->
#    updateRoleFields()
  $(".user-current-role").each (index, element)->
    $el = $(element)
    role = gon.current_roles[$el.find("[data-role=current-role]").val()]
    $uic = $el.find("[data-role=uic]").parent()

    # TODO reload uics list

    # TODO убрать лишнее
    # if ($.inArray(role, uicRoles) != -1)
    #   $uic.show()
    #   $tic.hide()
    # else
    #   $tic.show()
    #   $uic.hide()

    # FIXME зачем?
    # if ($.inArray(role, ticRoles) != -1)
    # else
    #   $region.find("select").select2('val', '');


checkForObserverRole = ->
  el =$("[data-role=observer-roles]")
  if ($.inArray(gon.observer_role_id + '', $(".formtastic.user #user_role_ids").val()) != -1) or $('.user-current-role').length != 0
    el.removeClass("hidden")
  else
    el.addClass("hidden")

initRoles = ->

  $(".formtastic.user").on "change", ".user-current-role", ->
    updateRoleFields()

  $(".formtastic.user").on "click", ".add_fields", ->
    setTimeout (->
      updateRoleFields()
      selectify($("[data-role=user-fields-container] select.select2"))
    ), 0

  $(".formtastic.user #user_role_ids").on "click", ->
    checkForObserverRole()
  checkForObserverRole()
  updateRoleFields()

@initUserForm = ->
  if gon.user_app_id
    $(".verify_link").on("ajax:success", (e, data, status, xhr) ->
      if data.success
        $(this).closest(".unverified").html('Данные подтверждены!').fadeOut()
        $("#user_app_"+gon.user_app_id+" .status_tag.error").removeClass("error").addClass("ok")
      else
        $(this).closest(".unverified").find(".error-message").html(data.error)
        $(this).closest(".unverified").find(".errors").fadeIn()
    ).bind "ajax:error", (e, xhr, status, error) ->
      alert xhr.responseText
    $form = $("form#new_user")
  else
    $form = $("form#edit_user_"+gon.user_id)

  $form.bind("ajax:beforeSend", (evt, xhr, settings) ->
    $submitButton = $(this).find('input[name="commit"]')
    $submitButton.data "origText", $submitButton.attr('value')
    $submitButton.attr('value',"Сохранение...");
  )
  .bind("ajax:success", (evt, data, status, xhr) ->
    $dialog = $(this).closest('.ui-dialog-content')
    try
      response = $.parseJSON(xhr.responseText)
      if response.status == "ok"
        window.location.reload()
      else
        $dialog.html(xhr.responseText)
    catch err
      $dialog.html(xhr.responseText)
  ).bind("ajax:complete", (evt, xhr, status) ->
    $submitButton = $(this).find("input[name=\"commit\"]")
    $submitButton.attr('value',$submitButton.data("origText"));

  ).bind "ajax:error", (evt, xhr, status, error) ->
    alert "Произошла ошибка! Перезагрузите страницу и попробуйте ещё раз"
    $(this).closest('.ui-dialog-content').html(xhr.responseText)

  selectify($("select.select2"))
  initRoles()
