$(function() {
  $('.control_work_logs [data-json]').each(function() {
    var $pre= $('<pre>').appendTo($(this)).text(JSON.stringify($(this).data('json'), undefined, 2));
  })
})
