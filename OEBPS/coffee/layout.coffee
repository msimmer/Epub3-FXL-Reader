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


  updatePageCollection:(k, len, section) ->

    kInt = +k
    console.log "Attempting to render @pageCollection[#{kInt}]."

    if kInt is 0
      @pageCollection[kInt] = true
      console.log "  Laying out first section."

      $spread = @generateArticle(kInt, '', '', section)
      @appendToDom($spread, kInt, len)

    else if @prevSectionsExits(kInt)
      console.log "  Laying out section #{kInt}"
      @pageCollection[kInt] = true

      $spread = @generateArticle(kInt, '', '', section)
      @appendToDom($spread, kInt, len)

      for item, index in @pageQueue
        if @pageQueue[index] and @prevSectionsExits(index)
          @pageCollection[index] = true
          console.log "    @pageCollection[#{index}] exists in the queue,
            laying out section #{index}."

          $spread = @generateArticle(index, '', '', item)
          @appendToDom($spread, index, item)

          delete @pageQueue[index]
          console.log "      Deleting @pageCollection[#{index}] from queue."

    else
      if $.inArray(kInt, @pageQueue) < 0 or @pageQueue[kInt] is 'undefined'
        console.log "    Adding @pageQueue[#{kInt}] to queue."
        @pageQueue[kInt] = section



  render: ->

    $.when( app.Http::get(@settings.contentUrl, 'xml') )
    .then (data) =>
      @spine = app.Http::getSpine(data)
    .then (data) =>

      spreadIdx      = 0
      $spread        = null
      dataKeys       = Object.keys(data)
      sectionLen     = +dataKeys.length - 1

      @pageCollection = dataKeys.reduce( (o, v, i) ->
        o[i] = null
        return o
      , {})

      $.each(data, (k,v) =>
        app.Http::get(v.href, 'html', (section) =>

          $spread = @generateArticle(spreadIdx, v.properties, k, section)
          $background = $('<section/>',
            'class':'background'
            'data-background-for':spreadIdx
          )

          # $(@settings.container).append($spread)
          # if !$('article.backgrounds').length
          #   $backgrounds = $('<article/>', {'class':'backgrounds'})
          # $backgrounds.append($background)

          @updatePageCollection(k,sectionLen,section)
          ++spreadIdx
        )



      # for k, v of data
      #   foo = k
      #   app.Http::get(v.href, 'html', (section) =>

          # console.log k

      #     if sectionPos is 'left'
      #       $spread = @generateArticle( spreadCount, 'left', k, section )

      #     else if sectionPos is 'right'
      #       if !$spread
      #         console.warn("Appending a right-hand section at position
      #           #{spreadCount} to an empty article.")
      #         $spread = @generateArticle( spreadCount, 'right', k, section )

      #       else

      #         $spread.append($('<section/>', html: section))

          # $background = $('<section/>',
          #   'class':'background'
          #   'data-background-for':spreadCount
          # )

          # if !$('article.backgrounds').length
          #   $backgrounds = $('<article/>', {'class':'backgrounds'})
      #       $(@settings.container).append($backgrounds)
      #     else
      #       $backgrounds = $('article.backgrounds')


          # $(@settings.container).append($spread)
          # $backgrounds.append($background)

      #     ++spreadCount
      #     ++pageCount

      #     sectionPos = if sectionPos is 'left' then 'right' else 'left'
      #     app.App.updateNodeCt($(section).find('*').length, pageCount, sectionLen)

      )


window.Reader ?= {}
window.Reader.Layout = Layout
