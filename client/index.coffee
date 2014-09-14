class Plot
  constructor: (@commitsCsvFile) ->
    @data = null
    @logBase = 8
    @minSize = 2
    @minDate = Number.MAX_VALUE
    @maxDate = -Number.MAX_VALUE
    @infobox = null
    @infoboxWidth = 300
    @width = $(window).width()
    @height = $(window).height() * 0.5
    @verticalScale = @height / @width
    @padding = 0.01

  load: ->
    @infobox = $ '<div class="infobox"/>'
    .css 'width', @infoboxWidth
    .appendTo $ 'body'
    @infobox.hide()

    d3.csv @commitsCsvFile, (err, data) =>
      throw err if err
      @commits = data
      @processCommits()
      @plotCommits()

  processCommits: ->
    inADay = 1000 * 60 * 60 * 24
    vpadding = @padding / @verticalScale
    for commit in @commits
      commit.added = Number commit.added
      commit.deleted = Number commit.deleted
      commit.date = Number commit.date
      commit.dateObj = new Date commit.date
      commit.y = (((commit.date % inADay) / inADay) * (1 - 2 * vpadding) + vpadding) * @verticalScale
      @minDate = commit.date if commit.date < @minDate
      @maxDate = commit.date if commit.date > @maxDate

    for commit, i in @commits
      commit.x = (i / @commits.length) * (1 - 2 * @padding) + @padding
    return

  plotCommits: ->
    svg = d3.select '#plot'
    .append 'svg'
    .attr 'width', @width
    .attr 'height', @height
    .attr 'viewBox', '0 0 1 ' + @verticalScale

    svg.selectAll '.commit'
    .data @commits
    .enter()
    .append 'circle'
    .attr 'class', 'commit'
    .attr 'cx', (c) -> c.x
    .attr 'cy', (c) -> c.y
    .attr 'r', @radiusFunc.bind this
    .attr 'style', (c) => "fill: #{@colorFunc(c)}"
    .on 'mouseover', @showInfo.bind this
    .on 'mousemove', @moveInfo.bind this
    .on 'mouseout', @hideInfo.bind this

  radiusFunc: (c) ->
    r = c.added + c.deleted
    r = if r is 0 then 1 else r
    r = @minSize + Math.log(r) / Math.log(@logBase)
    return r * 0.001

  colorFunc: (c) ->
    total = c.added + c.deleted
    if total > 0
      hue = (c.added / total) * 120
    else
      color = 120
    return d3.hsl(hue, 0.8, 0.4)

  showInfo: (c) ->
    @infobox.show()
    @infobox.html """
      <p class="date">#{@getFormatedDate c}</p>
      <p class="changes">
        <span class="added">+#{c.added}</span>,
        <span class="deleted">–#{c.deleted}</span>
      </p>
      <p class="message">#{c.message}</p>
    """
    @moveInfo c

  moveInfo: (c) ->
    padding = 10
    x =
      if d3.event.pageX + @infoboxWidth + 2 * padding > @width
        d3.event.pageX - @infoboxWidth - padding
      else
        d3.event.pageX + padding
    @infobox.css
      left: x + 'px'
      top: (d3.event.pageY + padding) + 'px'

  getFormatedDate: (c) ->
    c.dateObj.toISOString().replace('T', ' ').replace '.000Z', ''

  hideInfo: (c) ->
    @infobox.hide()

main = ->
  plot = new Plot window.commitsCsvFile
  plot.load()

$(document).ready main
