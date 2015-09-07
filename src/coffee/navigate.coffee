
class Reader.Navigate extends Reader
  constructor: (
    @settings
    @currentPos
    @currentIdx
    @currentSection
    @increment
    @elem = $(@settings.innerContainer)
  ) ->

  setTotalLen: (len) =>
    @totalLen = len

  getTotalLen: (len) =>
    -@totalLen

  setCurrentPos: (pos) =>
    @currentPos = pos
  getCurrentPos: =>
    @currentPos

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

  getNextPos: =>
    nextIdx = @getCurrentIdx() + 1
    elem = $("[data-idx=#{nextIdx}]")
    if elem.length
      pos = ~~elem.find("[data-page-offset]").attr("data-page-offset")
      return -pos

  getPrevPos: =>
    prevIdx = @getCurrentIdx() - 1
    elem = $("[data-idx=#{prevIdx}]")
    if elem.length
      pos = ~~elem.find("[data-page-offset]").attr("data-page-offset")
      return -pos

  animateElem: (pos) =>
    @elem.css("#{Reader.Utils::prefix.css}transform":"translateX(#{pos}px)")

  goToNext: =>
    desiredPos = @getNextPos()
    totalLength = @getTotalLen()

    if desiredPos > totalLength
      @animateElem(desiredPos)
      idx = @getCurrentIdx()
      @setCurrentIdx(idx + 1)


  goToPrev: =>
    desiredPos = @getPrevPos()
    if desiredPos <= 0
      @animateElem(desiredPos)
      idx = @getCurrentIdx()
      @setCurrentIdx(idx - 1)

  goToIdx: (idx) =>

  goToStart: =>
    @animateElem(0)
    @setCurrentPos(0)
    @setCurrentIdx(0)
    @setCurrentSection(0)

  goToEnd: =>
    totalLength = @getTotalLen()
    inc = @getIncrement()
    dest = totalLength - inc
    @animateElem(dest)
    # @setCurrentPos()
    # @setCurrentIdx()

  goToChapter: (idx) =>



