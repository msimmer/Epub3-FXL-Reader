
class Reader

  @debug = true
  @fsEnabled = false

  log: (args) =>
    if Reader.debug
      window.console.log args

  updatenodeCount: (nodes, currentSection, lastSection) =>
    if currentSection is lastSection
      @log "\nAll sections successfully added to the DOM."
      $(document).trigger('reader.contentReady')

  navToggle: =>
    $('#nav-toggle').toggleClass('nav-open')
    $('#nav-bar').toggleClass('nav-open')
    $(@settings.outerContainer).toggleClass('nav-open')
    $('#chapter-list').removeClass('open')


  fsToggle: =>
    elem = @settings.docElem or document.documentElement
    if not @fsEnabled
      @fsEnabled = true
      if elem.requestFullscreen
        elem.requestFullscreen()
      else if elem.mozRequestFullScreen
        elem.mozRequestFullScreen()
      else if elem.webkitRequestFullscreen
        elem.webkitRequestFullscreen()
      else if elem.msRequestFullscreen
        elem.msRequestFullscreen()
    else
      @fsEnabled = false
      if document.exitFullscreen
        document.exitFullscreen()
      else if document.mozCancelFullScreen
        document.mozCancelFullScreen()
      else if document.webkitExitFullscreen
        document.webkitExitFullscreen()


  constructor: (options)->

    defaults =
      scope:'reader'
      transitionSpeed:250
      contentUrl:null
      spread:true
      gutter:0
      hideOnResize:false
      viewport:
        width:468
        height:680
      outerContainer:'main'
      innerContainer:'#content'
      nativeScroll:false
      lazy:false
      docElem: null
      origin:
        x:0
        y:0

    @settings = $.extend({}, defaults, options)
    @utils    = new Reader.Utils
    @parser   = new Reader.Parser
    @http     = new Reader.Http
    @aspect   = new Reader.Aspect(@settings)
    @layout   = new Reader.Layout(@settings)
    @navigate = new Reader.Navigate(@settings)

    @isResizing   = false
    @isPositioned = false
    @nodeCount    = 0

    $('body').addClass('loading');

    $(document).on('reader.contentReady', =>
      @log "\nReader content has been added to the DOM."
      @nodeCount = $('*').length
      @aspect.setZoom(=>
        @aspect.adjustArticlePosition()
      )
    )

    $(document).on('reader.pagesFit', =>
      @log "\nSizing pages to `window`."
    )

    $(document).on('reader.articlesPositioned', (e, data) =>
      @isPositioned = true
      @log "\nAll articles successfully positioned."

      @navigate.setIncrement(data.inc)
      @navigate.setTotalLen(data.len)
      @navigate.setCurrentIdx(0)

      $('body').removeClass('loading')
    )

    # Bootstrap
    #
    @layout.render()


    # DOM Events
    #
    $(window).on
      'resize': =>

        if not @isPositioned then return

        @isResizing = true
        resizeTimer = null
        $body       = $('body')

        $body.addClass("#{@settings.scope}-resize #{@settings.scope}-resize-start")
        clearTimeout resizeTimer

        @utils.waitForFinalEvent (=>
          @isResizing = false
          @aspect.setZoom()
          $body.removeClass("#{@settings.scope}-resize-start")
          $body.addClass("#{@settings.scope}-resize-end")
          setTimeout(=>
            $body.removeClass("#{@settings.scope}-resize #{@settings.scope}-resize-end")
          , @settings.transitionSpeed)
          return
        ), 400, 'some unique string'



    # Navigation
    #
    $(document).on 'keydown', (e) =>
      switch e.which
        when 39 then @navigate.goToNext()
        when 37 then @navigate.goToPrev()
        when 27
          if $(@settings.outerContainer).hasClass('nav-open')
            @navToggle()

    $('#nav-toggle').on 'click', (e) =>
      e.preventDefault()
      @navToggle()

    $('.fs').on 'click', (e) =>
      e.preventDefault()
      @fsToggle()
      @navToggle()

    $('#click-nav a').on 'click', (e) =>
      e.preventDefault()
      $this = $(e.target)
      if $this.hasClass('prev') then @navigate.goToPrev()
      else if $this.hasClass('next') then @navigate.goToNext()

    $('.go-to-pos').on 'click', (e) =>
      e.preventDefault()
      @navToggle()
      @navigate.goToIdx($(e.currentTarget).attr('data-nav-pos'))

    $('#chapter-display').on 'click', (e) ->
      e.preventDefault()
      $('#chapter-list').toggleClass('open')


