window.Reader ?= {}
class window.Reader.Http
  constructor: (settings) ->
    console.log 'Http'


  getHTML: (url, cb) ->
    return $.get(url, -> cb())

  getXML: (url, cb) ->
    return $.get(url, -> cb())





