$(function() {

  $('input[value=][type="checkbox"]').attr("disabled", true).attr('title', 'Сначала заполните расстановку и перезагрузите страницу! А пока отправить смс или почту таким людям можно из списка пользователей');

  $.fn.editable.defaults.mode = 'inline';

  $('.control_dislocations .inplace').editable({emptytext: 'изменить',
    highlight: false,
    send: 'always',
    params: function(params) {
      params.dislocation = $(this).data('dislocation') || {};
      params.dislocation[params.name] = params.value;
      return params;
    },
    success: function(response, value) {
      var $input = $(this),
          $row = $input.closest('tr');
      $row.find('.dislocation_errors_column .message').remove();
      setTimeout(function() {
        var $inplaces = $row.find('.inplace');
        $row.find('.current_role_uic .inplace').editable('option', 'source', response.selectable_uics);
        if (response.errors.length > 0) {
          $inplaces.data('dislocation', response.dislocation).addClass('unsaved')
            .filter('[data-name='+ response.errors[0] +']').editable('show');
          $row.find('.dislocation_errors_column').append($('<div>', {class: 'message'}).text(response.message));
        } else {
          $inplaces.removeClass('unsaved').removeData('dislocation').data('url', response.url);
          $row.find('.dislocation_errors_column').html(response.dislocation_errors);
          $row.find('.dislocation_letters_column').html(response.dislocation_letters);
        };
      }, 44);
    }
  });
})
