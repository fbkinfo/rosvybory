$(function() {
  var source, undefined;
  $('.enable-live-reports-link').click(function() {
    var $cfg = $(this).data();
    if (source) {
      source.close();
      source = undefined;
    } else {
      source = new EventSource('/events?'+ $('#new_q').serialize());
      // source.addEventListener('error', function () { alert("Ошибка связи. Свяжитесь с тех. поддержкой.") });

      source.addEventListener('message', function(d) {
        var report = JSON.parse(d.data),
            $table = $('.control_call_center_reports #index_table_call_center_reports'),
            path = $cfg.reloadUrl +'?'+ $.param($.extend(true, $cfg.reloadParams, {q: {id_eq: report.id}}));

        $.get(path, function(html) {
          var $html = $(html),
              $tr = $html.find('#call_center_report_'+ report.id);
          if ($tr.length > 0) {
            $tr.insertBefore($table.find('tbody tr:first'))
            $tr.hide();
            $tr.show('fast');
            $table.find('tbody tr').each(function(i) {
              $(this).removeClass('even odd').addClass(i % 2 ? 'even' : 'odd');
            })
          }
        });
      })
    }
    return false;
  });
  // $('.enable-live-reports-link').click(); // turn on by default
});
