$(function() {
  $.fn.editable.defaults.mode = 'inline';

  $('.control_dislocations .inplace').editable({emptytext: '&nbsp;&nbsp;&nbsp;',
    send: 'always',
    params: function(params) {
      params.dislocation = $(this).data('dislocation') || {};
      params.dislocation[params.name] = params.value;
      return params;
    },
    success: function(response, value) {
      var $input = $(this),
          $row = $input.closest('tr'),
          $inplaces = $row.find('.inplace');
      if (response.errors.length > 0) {
        $inplaces.each(function() {
          $(this).data('dislocation', response.dislocation).addClass('unsaved');
        })
        setTimeout(function() {
          $inplaces.filter('[data-name='+ response.errors[0] +']').editable('show');
        }, 44)
      } else {
        $inplaces.each(function() {
          $(this).removeClass('unsaved').removeData('dislocation').data('url', response.url);
        })
      };
      if (response.message) {
        setTimeout(function() {
          alert(response.message);
        }, 22)
      }
    }
  });
})
