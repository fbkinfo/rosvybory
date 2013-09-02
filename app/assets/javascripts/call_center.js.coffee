//= require jquery
//= require select2
$ ->
  $(".select2").each (i, e) ->
    select = $(e)
    options = {}
    if select.hasClass("ajax")
      options.ajax =
        url: select.data("source")
        dataType: "json"
        data: (term, page) ->
          q: term
          page: page
          per: 10

        results: (data, page) ->
          results: data
      options.initSelection = (element, callback) ->
          id = $(element).val()
          if id isnt "" && !!parseInt(id)
            $.ajax("/call_center/current_user/",
              data:
                id: id
              dataType: "json"
            ).done (data) ->
              callback data

      options.dropdownCssClass = "bigdrop"
    select.select2 options
