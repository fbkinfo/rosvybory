
uicRoles = ["psg", "prg", "observer", "journalist"]
regionRoles = ["psg_tic", "prg_tic"]

updateRoleFields = ->
#  $(".user-current-role").change ->
#    updateRoleFields()
  $(".user-current-role").each (index, element)->
    $el = $(element)
    role = gon.current_roles[$el.find("[data-role=current-role]").val()]
    $uic = $el.find("[data-role=uic]").parent()
    $region = $el.find("[data-role=region-select]").parent()

    if ($.inArray(role, uicRoles) != -1)
      $uic.show()
    else
      $uic.find("select").select2('val', '');
      $uic.hide()


    if ($.inArray(role, regionRoles) != -1)
      $region.show()
    else
      $region.find("select").select2('val', '');
      $region.hide()


checkForObserverRole = ->
  el =$("[data-role=observer-roles]")
  if ($.inArray(gon.observer_role_id + '', $(".formtastic.user #user_role_ids").val()) != -1)
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
        $dialog.dialog('close');
        if gon.user_app_ids
          $("body").trigger "app-status-change", [id, "approved"] for id in gon.user_app_ids
        else
          $("body").trigger "app-status-change", [gon.user_app_id, "approved"] if gon.user_app_id
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

  $form.find("#user_adm_region_id").on "change", (e) ->
    chosen_val = $(@).val()
    $el = $form.find("#user_region_id")
    $el.empty(); # remove old options
    $el.append $("<option></option>").attr("value", "")
    $.each gon.regions[chosen_val], (index, region) ->
      $el.append $("<option></option>").attr("value", region.id).text(region.name)
    $el.select2("val", "")

  selectify($("select.select2"))

  initRoles()
