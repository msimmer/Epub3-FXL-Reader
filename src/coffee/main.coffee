
class window.Reader

  @debug = false

  log: (args) =>
    if Reader.debug
      window.console.log args

  updatenodeCount: (nodes, currentSection, lastSection) =>
    if currentSection is lastSection
      @log "\nAll sections successfully added to the DOM."
      $(document).trigger('reader.contentReady')


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
    @navbar   = new Reader.Navbar(@settings)

    @isResizing   = false
    @isPositioned = false
    @nodeCount    = 0

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
      @navigate.setCurrentPos(0)
      @navigate.setCurrentIdx(0)

      @navbar.append()
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
        ), 500, 'some unique string'



    # Navigation
    #
    $(document).on 'keydown', (e) =>
      switch e.which
        when 39 then @navigate.goToNext()
        when 37 then @navigate.goToPrev()

    $('#nav-toggle').on 'click', (e) ->
      e.preventDefault()
      $(@).toggleClass('nav-open')
      $('#nav-bar').toggleClass('nav-open')
      $('main').toggleClass('nav-open')

