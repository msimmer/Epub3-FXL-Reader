
class Reader.Navbar extends Reader
  constructor: (
    @settings
    @elem = $(@settings.innerContainer)
  ) ->

  append: ->
    $('body').append(@navbar)
