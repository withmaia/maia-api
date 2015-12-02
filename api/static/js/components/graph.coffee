Kefir = require 'kefir'
_ = require 'underscore'
d3 = require 'd3'
moment = require 'moment'
React = require 'react'

GRAPH_PADDING = 40
GRAPH_HEIGHT = 150
default_blue = '#39d'

Graph = React.createClass

    setupGraph: ->
        svg_el = @refs.main
        @svg = d3.select(svg_el)
        @w = svg_el.offsetWidth
        @h = GRAPH_HEIGHT
        @x = d3.time.scale().range([GRAPH_PADDING, @w-GRAPH_PADDING])
        @y = d3.scale.linear().range([@h-GRAPH_PADDING, GRAPH_PADDING/2])
        console.log "[renderGraph]"

        # Container
        @svg.selectAll('*').remove()
        @svg
            .attr 'width', @w
            .attr 'height', @h
            .style 'background', '#fff'
            .append('g')

    setupAxes: (x_data, y_data, to_zero=false) ->
        #x.domain(d3.extent data, (d) -> d.t)
        x_extent = d3.extent _.flatten(x_data), (d) -> d.t
        #x.domain([data.start, data.end])
        @x.domain(x_extent)
        y_extent = d3.extent _.flatten(y_data), (d) -> d.value
        #y.domain([y_extent[0], y_extent[1]])
        if to_zero
            @y.domain([0, y_extent[1]])
        else
            @y.domain(y_extent)

    drawAxes: ->
        # Axes

        yAxis = d3.svg.axis()
            .scale(@y)
            .orient('left')
            .ticks(5)

        xAxis = d3.svg.axis()
            .scale(@x)
            .orient('bottom')
            .ticks(5)
            .tickFormat(d3.time.format('%H:%M'))

        # Draw Axes

        @svg.append('g')
            .attr('class', 'y axis')
            .attr('transform', "translate(#{GRAPH_PADDING-5},0)")
            .call(yAxis)

        @svg.append('g')
            .attr('class', 'x axis')
            .attr('transform', "translate(0,#{@h-GRAPH_PADDING+10})")
            .call(xAxis)

        # Draw y grid lines

        @svg.append('g')
            .attr('class', 'grid')
            .call(yAxis.tickFormat('').tickSize(-@w+1.5*GRAPH_PADDING, 0, 0))
            .attr('transform', "translate(#{GRAPH_PADDING},0)")

        @svg.append('g')
            .attr('class', 'grid')
            .call(xAxis.tickFormat('').tickSize(10, 0, 0))
            .attr('transform', "translate(0,#{@h-GRAPH_PADDING})")

    renderLine: ({options, values}) ->
        options ||= {color: "#fcc"}
        console.log options
        console.log values

        line = d3.svg.line()
            .x (d) => @x d.t
            .y (d) => @y d.value
            .interpolate(options.interpolation || 'cardinal')

        path = @svg.append('path')
            .datum(values)
            .attr('class', 'line')
            .attr('d', line)
            .attr('stroke', options.color || default_blue)

        if values.length > 0
            # End marker

            endmarker = @svg.append('g')
                .attr('class', 'end-marker')

            endmarker.append('circle')
                .attr('r', 5)
                .attr('stroke', options.color || default_blue)

            d = values[values.length-1]
            endmarker.attr('transform', "translate(#{@x d.t}, #{@y d.value})")

    renderHistogram: ({options, values}) ->
        self = @

        # Bin by t into hour chunks
        bins = []
        n_values = values.length
        vi = 0
        bi = 0
        last_date = values.slice(-1)[0].t
        _date = values[0].t
        time_chunk = 1000 * 60 * 60

        while _date - time_chunk < last_date
            bins[bi] = []
            bins[bi].t = new Date _date
            while vi < n_values
                v = values[vi]
                if v.t > _date
                    bi++
                    break
                else
                    bins[bi].push v
                    vi++
            _date += time_chunk

        # Set axes domains
        x_extent = d3.extent(bins, (b) -> b.t)
        @x.domain([x_extent[0], new Date()])
        y_extent = d3.extent(bins, (b) -> b.length)
        @y.domain([0, y_extent[1]])
        @drawAxes()

        # Calculate full range vs # of bars to get bar width
        w = @x.range()[1] - @x.range()[0]
        x_spread = x_extent[1].getTime()-x_extent[0].getTime()
        full_x_spread = new Date().getTime()-x_extent[0].getTime()
        bw = w / bins.length * (x_spread / full_x_spread) - 1

        # Create a <g> for each bar
        bar_gs = @svg.selectAll('.bar')
            .data(bins)
            .enter().append('g')
                .attr('class', 'bar')
                .attr('transform', (d) -> "translate(#{ self.x(d.t) })")

        bar_gs.each (d) ->

            # Nest by type
            nested = d3.nest()
                .key((u) -> u.data.repository.name)
                .sortKeys(d3.descending)
                .entries(d)
            return if !nested.length

            # Calculate y and h of each section
            [bottom, top] = self.y.range()
            _y = bottom
            for section in nested
                n = section.values.length
                h = bottom - self.y(n)
                _y -= h
                section.h = h
                section.y = _y

            # Draw colored rectangles within
            _bar = d3.select(@)
            _bar.selectAll('rect')
                .data(nested).enter()
                .append('rect')
                .attr('fill', (d) -> '#333')
                .attr('x', 0)
                .attr('width', bw)
                .attr('height', (d) -> d.h)
                .attr('y', (d) -> d.y)

    renderFollowers: (dvs) ->

        # Path follower

        followers_g = @svg.append('g')
            .attr('class', 'followers')

        followers = []
        dvs.map ({options, values}, di) =>
            options ||= {color: "#fcc"}
            follower = followers_g.append('g')
                .attr('class', 'follower')

            follower.append('circle')
                .attr('r', 5)
                .attr('fill', options.color || default_blue)
            follower_text = follower.append('g')
                .attr('class', 'text')
            follower_date = follower_text.append('text')
                .attr('class', 'date')
                .attr('dy', -12)
            follower_value = follower_text.append('text')
                .attr('class', 'value')
                .attr('dy', 4)

            follower.style('display', 'none')
            followers[di] = follower

        bisectDate = d3.bisector((d) -> d.t).left

        suffix = @props.suffix || ''
        {x, y} = @
        follow = ->
            [mx, my] = d3.mouse(@)
            x0 = x.invert mx
            yd = 100
            cdi = 0

            dvs.map ({options, values}, di) =>
                return if values.length == 0

                # Find closest point
                i = bisectDate(values, x0, 1)
                d0 = values[i - 1]
                d1 = values[i]
                if !d0?
                    d = d1
                else if !d1?
                    d = d0
                else if x0 - d0.t > d1.t - x0
                    d = d1
                else
                    d = d0

                tyd = Math.abs(y(d.value) - my)
                if tyd < yd
                    yd = tyd
                    cdi = di

                # Fill in follower details
                follower = followers[di]
                follower.style('display', 'none')
                follower_text = follower.select('.text')
                follower_value = follower.select('.value')
                follower_date = follower.select('.date')
                follower.attr('transform', "translate(#{x d.t}, #{y d.value})")
                follower_value.text(d.value.toFixed(2) + suffix)
                follower_date.text moment(d.t).format('ddd h:mm a')

                # Adjust left/right alignment based on edge distance
                at_end = i > values.length*2/3
                text_anchor = if at_end then 'end' else 'start'
                text_dx = if at_end then -10 else 10
                follower_text.attr('transform', "translate(#{text_dx}, 0)")
                follower_text.style('text-anchor', text_anchor)

            follower = followers[cdi]
            follower.style('display', 'block')

        hide_follow = ->
            followers.map (follower) ->
                follower.style('display', 'none')

        @svg.append('rect')
            .attr('class', 'overlay')
            .attr('width', @w)
            .attr('height', @h)
            .on('mousemove', follow)
            .on('mouseleave', hide_follow)

    render: ->
        <svg ref='main' className='card'></svg>

module.exports = {Graph}