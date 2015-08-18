class Aspect
  constructor: (@settings) ->

  @sanitizeValues: (val) ->
    switch typeof val
      when 'string'
        val = if val.match(/\d/g)
          parseInt val, 10
        else
          $.trim val
    return val


  getViewportValues: ->
    obj = {}
    arr = $('meta[name=viewport]').attr('content').split(',')
    arr.map (val) =>
      vals = val.split('=')
      prop = @sanitizeValues vals[0]
      attr = @sanitizeValues vals[1]
      obj[prop] = attr
    @settings.viewport = obj
    return obj


  windowX: ->
    window.innerWidth
  windowY: ->
    window.innerHeight

  originalX: ->
    @settings.viewport.width
  originalY: ->
    @settings.viewport.height



  calcScale: ->
    x:@windowX() / @originalX()
    y:@windowY() / @originalY()


  adjustMainContentTo: (scale, cb) ->
    scaleCSS = {}
    CSSproperties = [
      "#{Reader.Utils::prefix.css}transform:scale(#{scale})"
      "#{Reader.Utils::prefix.css}transform-origin:#{@settings.origin.x} #{@settings.origin.y}"
    ]

    for str in CSSproperties
      props = str.split(':')
      scaleCSS[props[0]] = props[1]

    $(@settings.container).css(scaleCSS)

    if cb then cb()


  getScale: ->
    multiplier = @calcScale()
    fitX = @originalX() * multiplier.x
    fitY = @originalY() * multiplier.y
    fit = if fitY < fitX then multiplier.y else multiplier.x
    return{
      fitX:fitX
      fitY:fitY
      fit:fit
    }


  adjustArticlePosition: ->
    pageWidth = @getScale().fit * @originalX() + @settings.gutter
    $sections = $('article.spread section')
    len = $sections.length - 1
    $sections.each( (i) ->
      increment = i*pageWidth
      sectionPos =
        "#{Reader.Utils::prefix.css}transform":"translateX(#{increment}px)"
      $(@).css(sectionPos).attr('data-page-offset', increment)
      if i is len then $(document).trigger('reader.articlesPositioned')
    )


  setZoom: (cb) ->
    scale = @getScale()
    @adjustMainContentTo(scale.fit, =>
      $(document).trigger('reader.pagesFit')
      if cb then cb()
    )


window.Reader ?= {}
window.Reader.Aspect = Aspect
