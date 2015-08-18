class Layout

  app = window.Reader

  constructor: (@settings, @spine = {}) ->

    @pageQueue      = []
    @pageCollection = {}



  generateArticle: (idx, pageSpread, position, section) ->
    return $('<article/>',
      'class':'spread'
      'data-idx':idx
      'data-page-spread':pageSpread
      'data-spine-position':position
    ).append($('<section/>', html: section))


  appendToDom: ($spread, n, len) ->
    console.log "      Appending spread #{n} to DOM."


    $(@settings.container).append($spread)

    if !$('article.backgrounds').length
      $backgrounds = $('<article/>', {'class':'backgrounds'})
    else
      $backgrounds = $('article.backgrounds')


    $background = $('<section/>',
      'class':'background'
      'data-background-for':''
    )

    $backgrounds.append($background)
    app.App.updateNodeCt($spread.find('*').length, n, len)




  prevSectionsExits:(idx) ->
    do =>
      for i in [0..idx - 1]
        if @pageCollection[i] is null
          console.log "    Can't render @pageCollection[#{idx}]
            because @pageCollection[#{i}] doesn't exist."
          return false
      return true


  updatePageCollection:(k, len, section, layoutProps) ->

    kInt = +k
    console.log "Attempting to render @pageCollection[#{kInt}]."

    if kInt is 0
      @pageCollection[kInt] = true
      console.log "  Laying out first section."

      $spread = @generateArticle(kInt, layoutProps, kInt, section)
      @appendToDom($spread, kInt, len)

    else if @prevSectionsExits(kInt)
      console.log "  Laying out section #{kInt}"
      @pageCollection[kInt] = true

      $spread = @generateArticle(kInt, layoutProps, kInt, section)
      @appendToDom($spread, kInt, len)

      for item, index in @pageQueue
        if @pageQueue[index] and @prevSectionsExits(index)
          @pageCollection[index] = true
          console.log "    @pageCollection[#{index}] exists in the queue,
            laying out section #{index}."

          $spread = @generateArticle(index, item.props, index, item.content)
          @appendToDom($spread, index, item.content)

          delete @pageQueue[index]
          console.log "      Deleting @pageCollection[#{index}] from queue."

    else
      if $.inArray(kInt, @pageQueue) < 0 or @pageQueue[kInt] is 'undefined'
        console.log "    Adding @pageQueue[#{kInt}] to queue."
        @pageQueue[kInt] = {content:section,props:layoutProps}



  render: ->

    $.when( app.Http::get(@settings.contentUrl, 'xml') )
    .then (data) =>
      @spine = app.Http::getSpine(data)
    .then (data) =>

      dataKeys   = Object.keys(data)
      sectionLen = +dataKeys.length - 1

      @pageCollection = dataKeys.reduce( (o, v, i) ->
        o[i] = null
        return o
      , {})

      $.each(data, (k,v) =>
        app.Http::get(v.href, 'html', (section) =>
          @updatePageCollection(k, sectionLen, section, v.properties)
        )
      )


window.Reader ?= {}
window.Reader.Layout = Layout
