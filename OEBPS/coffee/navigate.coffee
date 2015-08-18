


# TODO:
#   get total len
#   get/set offsets
#   get/set indices
#   get/set sections
#   callbacks
#   touch events
#




Reader = window.Reader ?= {}

class Reader.Navigate
  constructor: (
    @settings
    @currentPos
    @currentIdx
    @currentSection
    @increment
    @currentOffset
    @elem = $(@settings.innerContainer)
  ) ->

  setCurrentPos: (pos) =>
    @currentPos = pos
  getCurrentPos: =>
    @currentPos
  getCurrentOffset: ->
    @currentOffset
  setCurrentIdx: (idx) =>
    @currentIdx = idx
  getCurrentIdx: =>
    @currentIdx
  setCurrentSection:(section) =>
    @currentSection = section
  getCurrentSection: =>
    @currentSection
  getIncrement: =>
    @increment
  setIncrement: (inc) =>
    @increment = inc

  animateElem: (pos) =>
    console.log @elem
    @elem.css("#{Reader.Utils::prefix.css}transform":"translateX(#{pos}px)")

  goToNext: (pos) =>
    desiredPos = @getIncrement()
    totalLength = 100000
    inc = if @getCurrentOffset() + desiredPos > totalLength then totalLength else desiredPos
    @animateElem(inc)
    # @setCurrentPos()
    # @setCurrentIdx()
    # @setCurrentSection()

  goToPrev: (pos) =>
    desiredPos = @getIncrement()
    inc = if @getCurrentOffset() - desiredPos < 0 then 0 else desiredPos
    @animateElem(- inc)
    # @setCurrentPos()
    # @setCurrentIdx()
    # @setCurrentSection()

  goToIdx: (idx) =>

  goToStart: =>
    @animateElem(0)
    @setCurrentPos(0)
    @setCurrentIdx(0)
    @setCurrentSection(0)

  goToEnd: =>
    totalLength = 100000
    @animateElem(totalLength)
    # @setCurrentPos()
    # @setCurrentIdx()
    # @setCurrentSection()

  goToChapter: (idx) =>


