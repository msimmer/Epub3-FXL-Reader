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

    console.log 'adjustMainContentTo'

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




  # getMaxSectionDimensions: ->
  #   multiplier = @calcScale()
  #   pos =
  #     w:@originalX() * multiplier.x
  #     h:@originalY() * multiplier.y
  #   return pos


  adjustArticlePosition:() ->
    sectionWidth = @originalX() * @calcScale().x
    $('section').each( (i) ->
      sectionPos =
        "#{Reader.Utils::prefix.css}transform":"translateX(#{i*sectionWidth}px)"
      $(@).css(sectionPos)
    )
    $(document).trigger('reader.articlesPositioned')


  setZoom: (cb) ->
    multiplier = @calcScale()
    fitX = @originalX() * multiplier.x
    fitY = @originalY() * multiplier.y
    fit = if fitY < fitX then multiplier.y else multiplier.x

    @adjustMainContentTo(fit, ->
      $(document).trigger('reader.pagesFit')
      if cb then cb()
    )


window.Reader ?= {}
window.Reader.Aspect = Aspect
