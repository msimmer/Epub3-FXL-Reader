

Reader = window.Reader ?= {}

class Reader.Navbar extends Reader
  constructor: (
    @settings
    @elem = $(@settings.innerContainer)
  ) ->

  append: ->
    console.log $('body').append(@navbar)
