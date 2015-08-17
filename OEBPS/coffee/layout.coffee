class Layout
  constructor: (@settings, @spine = {}) ->

  app = window.Reader

  render: ->

    nodeCt = 0

    $.when( app.Http::get(@settings.contentUrl, 'xml') )
    .then (data) =>
      @spine = app.Http::getSpine(data)
    .then (data) =>

      spreadCount = 0
      pageCount   = 0
      sectionPos  = 'left'
      $spread     = null

      for k, v of data
        app.Http::get(v.href, 'html', (section) =>
          switch sectionPos
            when 'left'
              $spread = $('<article/>',
                'class':'spread'
                'data-idx':spreadCount
              ).append($('<section/>', html: section))
            when 'right'
              if $spread then $spread.append($('<section/>', html: section))
              else
                console.warn("Appending a right-hand section at position
                  #{spreadCount} to an empty article.")
                $spread = $('<article/>',
                  'class':'spread'
                  'data-idx':spreadCount
                ).append($('<section/>', html: section))

          $(@settings.container).append($spread)

          ++spreadCount
          ++pageCount
          sectionPos = if sectionPos is 'left' then 'right' else 'left'
          app.App.updateNodeCt($(section).find('*').length, pageCount, Object.keys(data).length)

        )


window.Reader ?= {}
window.Reader.Layout = Layout
