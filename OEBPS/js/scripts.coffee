$ ->

  settings =
    spread:true
    zoom:1
    viewport:null
    resize:false
    container:'#LB-Buch-Content-Def-1'
    origin:
      x:0
      y:0



  # Helpers
  #

  # http://davidwalsh.name/vendor-prefix
  prefix = do ->
    styles = window.getComputedStyle(document.documentElement, '')
    pre = (Array::slice.call(styles).join('').match(/-(moz|webkit|ms)-/) or styles.OLink == '' and [
      ''
      'o'
    ])[1]
    dom = 'WebKit|Moz|MS|O'.match(new RegExp('(' + pre + ')', 'i'))[1]
    {
      dom: dom
      lowercase: pre
      css: '-' + pre + '-'
      js: pre[0].toUpperCase() + pre.substr(1)
    }


  # http://stackoverflow.com/a/4541963/2379542
  waitForFinalEvent = do ->
    timers = {}
    (callback, ms, uniqueId) ->
      if !uniqueId
        uniqueId = 'Don\'t call this twice without a uniqueId'
      if timers[uniqueId]
        clearTimeout timers[uniqueId]
      timers[uniqueId] = setTimeout(callback, ms)
      return


  # DOM Events
  #

  $(window).on
    'resize': ->
      settings.resize = true
      waitForFinalEvent (->
        settings.resize = false
        setZoom()
        return
      ), 500, 'some unique string'


  # Aspect Ratio
  #

  sanitizeValues = (val) ->
    switch typeof val
      when 'string'
        val = if val.match(/\d/g)
          parseInt val, 10
        else
          $.trim val
    return val


  viewportValues = do ->
    obj = {}
    arr = $('meta[name=viewport]').attr('content').split(',')
    arr.map (val) ->
      vals = val.split('=')
      prop = sanitizeValues vals[0]
      attr = sanitizeValues vals[1]
      obj[prop] = attr
    settings.viewport = obj
    return obj


  windowX = ->
    window.innerWidth
  windowY = ->
    window.innerHeight

  originalX = ->
    settings.viewport.width
  originalY = ->
    settings.viewport.height



  calcScale = ->
    x:windowX() / originalX()
    y:windowY() / originalY()


  adjustContentTo = (scale) ->
    scaleCSS = {}
    CSSproperties = [
      "#{prefix.css}transform:scale(#{scale})"
      "#{prefix.css}transform-origin:#{settings.origin.x} #{settings.origin.y}"
    ]


    for str in CSSproperties
      props = str.split(':')
      scaleCSS[props[0]] = props[1]

    console.log scaleCSS


    $(settings.container).css(scaleCSS)


  setZoom = ->
    multiplier = calcScale()
    fitX = originalX() * multiplier.x
    fitY = originalY() * multiplier.y
    fit = if fitY < fitX then multiplier.y else multiplier.x

    adjustContentTo(fit)




  init = ->
    setZoom()








  init()
