$ ->
  bindDialogOnClick $(".accept_link"), "Утверждение заявки"
  bindDialogOnClick $(".reject_link"), "Отклонение заявки", null, () ->
    $dialog = $(this)
    $dialog.find('form').attr('data-remote', true).
      on('ajax:success', (e, data) ->
        $dialog.dialog('close')
        if data.id
          $row = $('#user_app_'+ data.id).closest('tr')
          $row.find('td').html('<del>отклонено</del>')
        true
      )
    $dialog.find('form :input:visible:first').change().focus()

  $(document).on 'change keyup', '.reject-form #reason', () ->
    $submit = $(this).closest('form').find(':submit')
    $submit.attr('disabled', $(this).val().trim().length < 3)
    true

  $(document).on 'paste', 'table.many-new input', (e) ->
    txt = e.originalEvent.clipboardData.getData('text/plain')
    rows = txt.split("\n").filter (r) -> r.trim().length > 0
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

  $("#collection_selection").submit ->
    if $("#batch_action").val() == "group_accept"
      dialog_url = '/users/group_new?'+ $(this).serialize();
      openDialog "group_accept", dialog_url, "Принять выбранные заявки"
      false
