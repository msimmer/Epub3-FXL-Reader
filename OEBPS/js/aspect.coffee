class Aspect
  constructor: (@settings, @utils) ->
    console.log 'Aspect'

  sanitizeValues: (val) ->
    switch typeof val
      when 'string'
        val = if val.match(/\d/g)
          parseInt val, 10
        else
          $.trim val
    return val


  getViewportValues: =>
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


  adjustContentTo: (scale) ->
    scaleCSS = {}
    CSSproperties = [
      "#{@utils.prefix.css}transform:scale(#{scale})"
      "#{@utils.prefix.css}transform-origin:#{@settings.origin.x} #{@settings.origin.y}"
    ]


    for str in CSSproperties
      props = str.split(':')
      scaleCSS[props[0]] = props[1]

    $(@settings.container).css(scaleCSS)


  setZoom: ->
    multiplier = @calcScale()
    fitX = @originalX() * multiplier.x
    fitY = @originalY() * multiplier.y
    fit = if fitY < fitX then multiplier.y else multiplier.x

    @adjustContentTo(fit)


if typeof module != "undefined" && module.exports
  exports.Aspect = Aspect
else
  window.Aspect = Aspect
