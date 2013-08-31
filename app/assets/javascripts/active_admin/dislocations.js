$(function() {
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
      $row.find('.dislocation_errors .message').remove();
      setTimeout(function() {
        var $inplaces = $row.find('.inplace');
        if (response.errors.length > 0) {
          $inplaces.data('dislocation', response.dislocation).addClass('unsaved')
            .filter('[data-name='+ response.errors[0] +']').editable('show');
          $row.find('.dislocation_errors').append($('<div>', {class: 'message'}).text(response.message));
        } else {
          $inplaces.removeClass('unsaved').removeData('dislocation').data('url', response.url);
        };
      }, 44);
    }
  });
})
