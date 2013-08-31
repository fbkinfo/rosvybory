# Opens dialog
# Depending on 'url' it opens inline or remote content.
#
# If 'url' starts with '#', url is treated as the element selector to show inline content
# Otherwise, 'url' is treated as a remote url to load into dialog
#
@openDialog = (dialog_id_posfix, url, title)->

  if getDialog(dialog_id_posfix).length != 0
    getDialog(dialog_id_posfix).dialog('close');
  else

  if /^#.*/.test url
    # inline content
    #
    #$("<div id='dialog_lalala'>хелло</div>").dialog(
    $(url).dialog(
      title: title
      buttons: {
        Ok: ()->
          $(this).dialog( "close" )
      }
    ).dialog('open')
  else
    # remote content
    $dialog = $("<div id='dialog_#{dialog_id_posfix}'>Загружаю...</div>").dialog(
      autoOpen: false
      height: 500
      width: 600
      title: title
      hide: {
        effect: "fadeOut",
        duration: 200
      }
      close: (ev, ui)->
        $(this).remove()
    )
    $dialog.load(url).dialog('open');

@getDialog = (dialog_id_posfix = null) ->
  if dialog_id_posfix
    $("#dialog_"+dialog_id_posfix)
  else
    $(this).closest('.ui-dialog-content')

@bindDialogOnClick = ($el, title, dialog_id_posfix = null)->
  $el.on("click", (e) ->
    dialog_id_posfix_current = $(this).closest("tr").attr("id") unless dialog_id_posfix
    openDialog dialog_id_posfix_current, $(this).attr("href"), title
    false
  )