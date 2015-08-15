class Utils
  constructor: (settings) ->
    console.log 'Utils'

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


if typeof module != "undefined" && module.exports
  exports.Utils = Utils
else
  window.Utils = Utils
