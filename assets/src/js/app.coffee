React = require 'react'
ReactDOM = require 'react-dom'

# TODO Pouzit Closure komponentu
Object.prototype.extend = (obj) ->
  for key, value of obj
    @[key] = value if obj.hasOwnProperty key

Microchart = React.createFactory React.createClass (`/** @lends {React.ReactComponent.prototype} */`)
  propTypes:
    'name': React.PropTypes.string.isRequired
    'baseClassName': React.PropTypes.string
    'customClassNames': React.PropTypes.array
    'animate': React.PropTypes.bool
    'animationDelay': React.PropTypes.number

  render: ->
    cssClasses = @props['customClassNames'].slice 0
    if @props['animate'] and not @state['animated']
      cssClasses.push 's-animate'

    React.DOM.svg {
      'key': "microchart-#{@props['name']}"
      'width': @props['width']
      'height': @props['width']
      'className': @props['baseClassName'].concat(' ', cssClasses.join(' ')) # TODO Pouzit Closure komponentu
    }, @props['children']

  componentDidMount: ->
    # Chart animation
    if @props['animate']
      @timeout = setTimeout(()=>
        @setState {'animated': yes}
      , @props['animationDelay'])
    return

  componentWillUnmount: ->
    clearTimeout @timeout if @timeout

  getInitialState: ->
    'animated': no

  getDefaultProps: ->
    'baseClassName': 's-microchart'
    'customClassNames': null
    'name': null
    'animate': no
    'animationDelay': 50

MicrochartPie = React.createFactory React.createClass (`/** @lends {React.ReactComponent.prototype} */`)
  propTypes:
    'name': React.PropTypes.string.isRequired
    'baseClassName': React.PropTypes.string
    'customClassNames': React.PropTypes.array
    'width': React.PropTypes.number
    'emptyColor': React.PropTypes.string
    'color': React.PropTypes.string
    'stroke': React.PropTypes.number
    'animate': React.PropTypes.bool

  render: ->
    props = 
      'customClassNames': @props['customClassNames']
      'width': @props['width']
      'height': @props['width']
      'animate': @props['animate']

    if @props['animationDelay']
      # TODO Pouzit Closure komponentu
      props.extend {
        'animationDelay': @props['animationDelay']
      }

    Microchart props, @renderChart()

  renderChart: ->
    radius = @props['width']/2
    progress = @props['value']/100 * Math.round(radius*2*Math.PI)

    React.DOM.circle {
      'key': "pie-#{@props['name']}-color"
      'r': radius
      'cx': radius
      'cy': radius
      'fill': @props['emptyColor']
      'stroke': @props['color']
      'strokeWidth': @props['width']
      'strokeDasharray': "#{progress} 100"
      'className': 's-animatable'
    }

  getInitialState: ->
    'animated': no

  getDefaultProps: ->
    'customClassNames': ['s-microchart--pie']
    'width': 24
    'emptyColor': '#f5f5f5'
    'color': '#5394DF'
    'animate': no

MicrochartDonut = React.createFactory React.createClass (`/** @lends {React.ReactComponent.prototype} */`)
  propTypes:
    'name': React.PropTypes.string.isRequired
    'baseClassName': React.PropTypes.string
    'customClassNames': React.PropTypes.array
    'width': React.PropTypes.number
    'emptyColor': React.PropTypes.string
    'color': React.PropTypes.string
    'stroke': React.PropTypes.number
    'animate': React.PropTypes.bool

  render: ->
    props = 
      'customClassNames': @props['customClassNames']
      'width': @props['width']
      'height': @props['width']
      'animate': @props['animate']

    if @props['animationDelay']
      # TODO Pouzit Closure komponentu
      props.extend {
        'animationDelay': @props['animationDelay']
      }

    Microchart props, @renderChart()

  renderChart: ->
    radius = @props['width']/2
    progress = @props['value']/100 * Math.round(radius*2*Math.PI)

    React.DOM.g {}, [
      React.DOM.circle {
        'key': "donut-#{@props['name']}-background"
        'r': radius
        'cx': radius
        'cy': radius
        'fill': 'none'
        'stroke': @props['emptyColor']
        'strokeWidth': @props['width']/2
        'strokeDasharray': "500 1000"
      }
      React.DOM.circle {
        'key': "donut-#{@props['name']}-color"
        'r': radius
        'cx': radius
        'cy': radius
        'fill': 'none'
        'stroke': @props['color']
        'strokeWidth': @props['width']/2
        'strokeDasharray': "#{progress} 1000"
        'className': 's-animatable'
      }
    ]

  getDefaultProps: ->
    'customClassNames': ['s-microchart--donut']
    'width': 24
    'emptyColor': '#f5f5f5'
    'color': '#5394DF'
    'animate': no

MicrochartLine = React.createFactory React.createClass (`/** @lends {React.ReactComponent.prototype} */`)
  propTypes:
    'name': React.PropTypes.string.isRequired
    'baseClassName': React.PropTypes.string
    'customClassNames': React.PropTypes.array
    'width': React.PropTypes.number
    'height': React.PropTypes.number
    'emptyColor': React.PropTypes.string
    'stroke': React.PropTypes.number
    'animate': React.PropTypes.bool

  render: ->
    props = 
      'customClassNames': @props['customClassNames']
      'width': @props['width']
      'height': @props['width']+@props['stroke']*2
      'animate': @props['animate']

    if @props['animationDelay']
      # TODO Pouzit Closure komponentu
      props.extend {
        'animationDelay': @props['animationDelay']
      }

    Microchart props, @renderChart()

  renderChart: ->
    React.DOM.g {}, @props['series'].map @getLinechartItem

  getLinechartItem: (item, index) ->
    # Calculating line positions
    moveX = Math.round((@props['width']/(item.data.length-1))*100)/100
    minY = Math.min.apply Math, item.data
    maxY = Math.max.apply Math, item.data
    ratio = @props['height']/(maxY-minY)
    fromBottom = @props['height'] - (@props['height']-maxY*ratio) + @props['stroke']

    # Saving line positions into an array and then converting to string
    points = []
    for value, i in item.data
      points.push [(Math.round(moveX*i*100)/100), Math.round((-1*value*ratio+fromBottom)*100)/100]

    # Changing strokeWidth if specified
    strokeWidth = @props['stroke']
    strokeWidth = item.strokeWidth if item.strokeWidth

    React.DOM.polyline {
      'key': "polyline-#{index}"
      'fill': 'none'
      'stroke': item['color']
      'strokeWidth': strokeWidth
      'strokeDasharray': @props['width']*@props['height']*0.07
      'points': points.join ' '
      'className': 's-animatable'
    }

  getDefaultProps: ->
    'customClassNames': ['s-microchart--line']
    'width': 50
    'height': 30
    'stroke': 2




# Render piecharts
# 
ReactDOM.render(MicrochartDonut({
  'name': 'someChart-1'
  'width': 24
  'color': '#aba97e'
  'value': 70
  'animate': yes
}), document.getElementById('pieChart-1'))

ReactDOM.render(MicrochartPie({
  'name': 'someChart-2'
  'width': 24
  'color': '#5394DF'
  'value': 90
  'animate': yes
}), document.getElementById('pieChart-2'))

ReactDOM.render(MicrochartDonut({
  'name': 'someChart-3'
  'width': 48
  'color': '#66245f'
  'value': 53
  'animate': yes
}), document.getElementById('pieChart-3'))

ReactDOM.render(MicrochartPie({
  'name': 'someChart-4'
  'width': 18
  'color': '#3c9108'
  'value': 36
}), document.getElementById('pieChart-4'))

ReactDOM.render(MicrochartPie({
  'name': 'someChart-5'
  'width': 64
  'color': '#ffd200'
  'value': 72
  'animate': yes
}), document.getElementById('pieChart-5'))

# Render linecharts
# 
ReactDOM.render(MicrochartLine({
  'name': 'someChart-6'
  'width': 50
  'height': 30
  'series': [
    {
      'color': '#5394DF'
      'data': [50, -67, -32, -36, -23, -11, 23, 56, 120, 101, 134]
    }
    {
      'color': '#f00000'
      'data': [600, 540, 543, 510, 450, 490, 430]
    }
  ]
}), document.getElementById('lineChart-1'))

ReactDOM.render(MicrochartLine({
  'name': 'someChart-7'
  'series': [
    {
      'color': '#5f500c'
      'data': [600, 540, 543, 510, 450, 490, 430]
    }
  ]
}), document.getElementById('lineChart-2'))

ReactDOM.render(MicrochartLine({
  'name': 'someChart-8'
  'animate': yes
  'series': [
    {
      'color': '#f00000'
      'data': [50, 40, 45, 43, 47, 52]
    }
  ]
}), document.getElementById('lineChart-3'))

ReactDOM.render(MicrochartLine({
  'name': 'someChart-9'
  'animate': yes
  'series': [
    {
      'color': '#5f500c'
      'data': [1, 2, 1, 3, 1]
    }
  ]
}), document.getElementById('lineChart-4'))

ReactDOM.render(MicrochartLine({
  'name': 'someChart-10'
  'width': 50
  'height': 30
  'animate': yes
  'series': [
    {
      'color': '#5f500c'
      'data': [-30, -10, 0, 5, 30]
    }
  ]
}), document.getElementById('lineChart-5'))
