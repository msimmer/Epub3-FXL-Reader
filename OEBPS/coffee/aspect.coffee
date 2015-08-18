

# allow for w > h page size
# explicitly set `section` height
  # explicitly set `main` height
# center `main`
# adjust size of `main` to only show 2 pages
#
#
#




class Aspect

  reader = window.Reader

  constructor: (@settings) ->

  @sanitizeValues: (val) ->
    switch typeof val
      when 'string'
        val = if val.match(/\d/g)
          parseInt val, 10
        else
          $.trim val
    return val


  # getViewportValues: ->
  #   obj = {}
  #   arr = $('meta[name=viewport]').attr('content').split(',')
  #   arr.map (val) =>
  #     vals = val.split('=')
  #     prop = @sanitizeValues vals[0]
  #     attr = @sanitizeValues vals[1]
  #     obj[prop] = attr
  #   @settings.viewport = obj
  #   return obj


  windowX: ->
    @windowDimensions().x
  windowY: ->
    @windowDimensions().y

  originalX: ->
    @settings.viewport.width
  originalY: ->
    @settings.viewport.height



  calcScale: ->
    x:@windowX() / @originalX()
    y:@windowY() / @originalY()

  windowDimensions:->
    w = window
    d = document
    e = d.documentElement
    b = d.getElementsByTagName('body')[0]
    x = w.innerWidth || e.clientWidth || b.clientWidth
    y = w.innerHeight|| e.clientHeight|| b.clientHeight
    return {
      x:x
      y:y
    }


  adjustMainContentTo: (scale, cb) ->
    scaleCSS   = {}
    windowDims = @windowDimensions()
    CSSproperties = [
      "#{Reader.Utils::prefix.css}transform:scale(#{scale})"
      "#{Reader.Utils::prefix.css}transform-origin:#{@settings.origin.x} #{@settings.origin.y}"
      "height:#{windowDims.y / scale}"
      "width:#{windowDims.x / scale}"
    ]

    for str in CSSproperties
      props = str.split(':')
      scaleCSS[props[0]] = props[1]

    $(@settings.container).css(scaleCSS)

    if cb then cb()


  getScale: ->

    multiplier = @calcScale()
    windowDims = @windowDimensions()

    maxX = @originalX() * multiplier.x
    maxY = @originalY() * multiplier.y

    fit = null

    if maxY >= windowDims.y
      reader.App::log "  Scaling content: Y > X, choosing Y."
      fit = multiplier.y
    else if maxX > windowDims.x
      reader.App::log "  Scaling content: X > Y, choosing X."
      fit = multiplier.x
    else
      reader.App::log "  Scaling content: defaulting to Y"
      fit = multiplier.y



    return{
      fitX:multiplier.x
      fitY:multiplier.y
      fit:fit
    }


  adjustArticlePosition: ->
    pageWidth  = @getScale().fit * @originalX() + @settings.gutter
    pageHeight = @getScale().fit * @originalY()


    $sections = $('article.spread section')
    len = $sections.length - 1
    wx = pageWidth/@getScale().fit
    wy = @windowY()/@getScale().fit
    $sections.each( (i) ->

      idx             = $(@).closest('article').attr('data-idx')
      scaledIncrement = i*wx
      windowIncrement = i*pageWidth

      sectionPos =
        "#{Reader.Utils::prefix.css}transform":"translateX(#{scaledIncrement}px)"
        position:'absolute'
        width:wx
        height:wy
      bgPos =
        left:windowIncrement
        width:pageWidth
        height:pageHeight

      $(@).css(sectionPos).attr('data-page-offset', scaledIncrement)
      $('.background[data-background-for="'+idx+'"]').css(bgPos)


      if i is len
        $(document).trigger('reader.articlesPositioned')

    )


  setZoom: (cb) ->
    scale = @getScale()
    @adjustMainContentTo(scale.fit, =>
      $(document).trigger('reader.pagesFit')
      if cb then cb()
    )


window.Reader ?= {}
window.Reader.Aspect = Aspect
