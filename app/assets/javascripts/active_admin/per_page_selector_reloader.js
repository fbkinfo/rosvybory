$(function() {
  $(document).on('change', '.per-page-selector', function() {
    document.location.search = document.location.search + '&per_page=' + $(this).val();
  })
})
