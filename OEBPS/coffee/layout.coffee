Reader = window.Reader ?= {}

class Reader.Layout

  constructor: (@settings, @spine = {}) ->

    @pageQueue      = []
    @pageCollection = {}


  generateArticle: (idx, pageSpread, position, section) =>
    return $('<article/>',
      'class':'spread'
      'data-idx':idx
      'data-page-spread':pageSpread
      'data-spine-position':position
    ).append($('<section/>', html: section))


  appendToDom: ($spread, n, len) =>
    Reader::log "      Appending spread #{n} to DOM."


    $(@settings.innerContainer).append($spread)

    if !$('article.backgrounds').length
      $backgrounds = $('<article/>', {'class':'backgrounds'}).appendTo('body')
    else
      $backgrounds = $('article.backgrounds')


    $background = $('<section/>',
      'class':'background'
      'data-background-for':n
    )

    $backgrounds.append($background)
    Reader::updatenodeCount($spread.find('*').length, n, len)




  prevSectionsExits:(idx) =>
    do =>
      for i in [0..idx - 1]
        if @pageCollection[i] is null
          Reader::log "    Can't render @pageCollection[#{idx}]
            because @pageCollection[#{i}] doesn't exist."
          return false
      return true


  updatePageCollection:(k, len, section, layoutProps) =>

    kInt = +k
    Reader::log "Attempting to render @pageCollection[#{kInt}]."

    if kInt is 0
      @pageCollection[kInt] = true
      Reader::log "  Laying out first section."

      $spread = @generateArticle(kInt, layoutProps, kInt, section)
      @appendToDom($spread, kInt, len)

    else if @prevSectionsExits(kInt)
      Reader::log "  Laying out section #{kInt}"
      @pageCollection[kInt] = true

      $spread = @generateArticle(kInt, layoutProps, kInt, section)
      @appendToDom($spread, kInt, len)

      for item, index in @pageQueue
        if @pageQueue[index] and @prevSectionsExits(index)
          @pageCollection[index] = true
          Reader::log "    @pageCollection[#{index}] exists in the queue,
            laying out section #{index}."

          $spread = @generateArticle(index, item.props, index, item.content)
          @appendToDom($spread, index, item.content)

          delete @pageQueue[index]
          Reader::log "      Deleting @pageCollection[#{index}] from queue."

    else
      if $.inArray(kInt, @pageQueue) < 0 or @pageQueue[kInt] is 'undefined'
        Reader::log "    Adding @pageQueue[#{kInt}] to queue."
        @pageQueue[kInt] = {content:section,props:layoutProps}



  render: =>

    $.when( Reader.Http::get(@settings.contentUrl, 'xml') )
    .then (data) =>
      @spine = Reader.Http::getSpine(data)
    .then (data) =>

      dataKeys   = Object.keys(data)
      sectionLen = +dataKeys.length - 1

      @pageCollection = dataKeys.reduce( (o, v, i) ->
        o[i] = null
        return o
      , {})

      $.each(data, (k,v) =>
        Reader.Http::get(v.href, 'html', (section) =>
          @updatePageCollection(k, sectionLen, section, v.properties)
        )
      )
