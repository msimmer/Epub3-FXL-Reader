window.Reader ?= {}
class window.Reader.Layout
  constructor: (@settings, @spine = {}) ->

  render: ->
    $.when( Reader.Http::get(@settings.contentUrl, 'xml') )
    .then (data) =>
      @spine = Reader.Http::getSpine(data)
    .then (data) =>

      spreadCount = 0
      sectionPos  = 'left'
      $spread     = null

      for k, v of data
        Reader.Http::get(v.href, 'html', (section) =>
          switch sectionPos
            when 'left'
              console.log 'append page left'
              $spread = $('<article/>',
                'class':'spread'
                'data-idx':spreadCount
              ).append(section)
            when 'right'
              console.log 'append page right'
              if $spread then $spread.append(section)
              else
                $spread = $('<article/>',
                  'class':'spread'
                  'data-idx':spreadCount
                ).append(section)

          $(@settings.container).append($spread)

          ++spreadCount
          sectionPos = if sectionPos is 'left' then 'right' else 'left'
        )
