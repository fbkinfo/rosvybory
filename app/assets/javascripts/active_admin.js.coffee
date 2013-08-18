#= require active_admin/base

#= require select2
#= require cocoon
#= require_tree ./active_admin
#= require region_select

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

$ ->
  $(".formtastic.user").on "click", ".add_fields", ->
    setTimeout (->
      el = $("[data-role=user-current-role]:last")
      updateRoleFields el
      el.change ->
        updateRoleFields $(this)
      el.find("[data-role=uic]").select2()
    ), 0

  $(".formtastic.user #user_role_ids").on "click", ->
    el =$("[data-role=observer-roles]")
    if ($.inArray(gon.observer_role_id + '', $(this).val()) != -1)
      el.removeClass("hidden")
    else
      el.addClass("hidden")
