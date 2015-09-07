
class Reader.Utils

  # http://davidwalsh.name/vendor-prefix
  prefix: do ->
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
  waitForFinalEvent: do ->
    timers = {}
    (callback, ms, uniqueId) ->
      if !uniqueId
        uniqueId = 'Don\'t call this twice without a uniqueId'
      if timers[uniqueId]
        clearTimeout timers[uniqueId]
      timers[uniqueId] = setTimeout(callback, ms)
      return


  # http://stackoverflow.com/questions/21912684/how-to-get-value-of-translatex-and-translatey
  getComputedTranslateY: (obj) ->
    if !window.getComputedStyle
      return
    style = getComputedStyle(obj)
    transform = style.transform or style.webkitTransform or style.mozTransform
    mat = transform.match(/^matrix3d\((.+)\)$/)
    if mat
      return parseFloat(mat[1].split(', ')[13])
    mat = transform.match(/^matrix\((.+)\)$/)
    if mat then parseFloat(mat[1].split(', ')[5]) else 0

  getComputedTranslateX: (obj) ->
    if !window.getComputedStyle
      return
    style = getComputedStyle(obj)
    transform = style.transform or style.webkitTransform or style.mozTransform
    mat = transform.match(/^matrix3d\((.+)\)$/)
    if mat
      return parseFloat(mat[1].split(', ')[12])
    mat = transform.match(/^matrix\((.+)\)$/)
    if mat then parseFloat(mat[1].split(', ')[4]) else 0
