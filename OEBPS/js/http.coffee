class Http
  constructor: (@settings, @utils) ->
    console.log 'Http'


if typeof module != "undefined" && module.exports
  exports.Http = Http
else
  window.Http = Http
