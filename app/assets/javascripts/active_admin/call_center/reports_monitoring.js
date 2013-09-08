$(function() {
  var source, undefined;
  $('.enable-live-reports-link, .off-live-reports-link').click(function() {
    var $cfg = $(this).data();
    if (source) {
      $('.live-reports-status').hide();
      $('.enable-live-reports-link').show();
      source.close();
      source = undefined;
    } else {
      $('.live-reports-status').show();
      $('.enable-live-reports-link').hide();

      source = new EventSource('/events?'+ $('#new_q').serialize());
      // source.addEventListener('error', function () { alert("Ошибка связи. Свяжитесь с тех. поддержкой.") });

      source.addEventListener('message', function(d) {
        var report = JSON.parse(d.data),
            $table = $('.control_call_center_reports #index_table_call_center_reports'),
            path = $cfg.reloadUrl +'?'+ $.param($.extend(true, $cfg.reloadParams, {q: {id_eq: report.id}}));

        $.get(path, function(html) {
          var $html = $(html),
              $tr = $html.find('#call_center_report_'+ report.id),
              perpage = $('.per-page-selector').val();
          if ($tr.length > 0) {
            $tr.insertBefore($table.find('tbody tr:first'))
            $tr.hide();
            $tr.show('fast');
            $table.find('tbody tr').each(function(i) {
              if (i > perpage) {
                $(this).remove();
              } else {
                $(this).removeClass('even odd').addClass(i % 2 ? 'even' : 'odd');
              }
            })
          }
        });
      })
    }
    return false;
  });
  // $('.enable-live-reports-link').click(); // turn on by default
});
