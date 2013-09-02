//= require jquery
//= require select2
jQuery ->
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
          $.ajax
            url: select.data("init-source")
            dataType: "json"
            data:
              id: id
            success: (data)->
              callback data

      options.dropdownCssClass = "bigdrop"
    select.select2 options
