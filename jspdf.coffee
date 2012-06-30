### @preserve
 * ====================================================================
 * jsPDF
 * Copyright (c) 2010 James Hall, https://github.com/MrRio/jsPDF
 * Copyright (c) 2012 Willow Systems Corporation, willow-systems.com
 * Copyright (c) 2012 Jason Siefken https://github.com/siefkenj/jsPDF
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * ====================================================================
###

###
# Some utility functions
###
getISODate = ->
    padd2 = (num) ->
        ret = num.toFixed(0)
        if ret.length >= 2
            return ret
        else
            return '0' + ret

    today = new Date
    return "#{today.getFullYear()}#{padd2(today.getMonth()+1)}#{padd2(today.getDate())}#{padd2(today.getHours())}#{padd2(today.getMinutes())}#{padd2(today.getSeconds())}"

base64encode = btoa or (data) ->
    ### @preserve
    ====================================================================
    base64 encoder
    MIT, GPL

    version: 1109.2015
    discuss at: http://phpjs.org/functions/base64_encode
    +   original by: Tyler Akins (http://rumkin.com)
    +   improved by: Bayron Guevara
    +   improved by: Thunder.m
    +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    +   bugfixed by: Pellentesque Malesuada
    +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    +   improved by: Rafal Kukawski (http://kukawski.pl)
    ====================================================================
    ###
    b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
    b64a = b64.split("")
    o1 = undefined
    o2 = undefined
    o3 = undefined
    h1 = undefined
    h2 = undefined
    h3 = undefined
    h4 = undefined
    bits = undefined
    i = 0
    ac = 0
    enc = ""
    tmp_arr = []
    loop
        o1 = data.charCodeAt(i++)
        o2 = data.charCodeAt(i++)
        o3 = data.charCodeAt(i++)
        bits = o1 << 16 | o2 << 8 | o3
        h1 = bits >> 18 & 0x3f
        h2 = bits >> 12 & 0x3f
        h3 = bits >> 6 & 0x3f
        h4 = bits & 0x3f
        tmp_arr[ac++] = b64a[h1] + b64a[h2] + b64a[h3] + b64a[h4]
        break unless i < data.length
    enc = tmp_arr.join("")
    r = data.length % 3
    return (if r then enc.slice(0, r - 3) else enc) + "===".slice(r or 3)
    ###
    end of base64 encoder MIT, GPL
    ###

# takes a string imgData containing the raw bytes of
# a jpeg image and returns [width, height]
# Algorithm from: http://www.64lines.com/jpeg-width-height
getJpegSize = (imgData) ->
    # Verify we have a valid jpeg header 0xff,0xd8,0xff,0xe0,?,?,'J','F','I','F',0x00
    if not imgData.charCodeAt(0) is 0xff or not imgData.charCodeAt(1) is 0xd8 or not imgData.charCodeAt(2) is 0xff or not imgData.charCodeAt(3) is 0xe0 or not imgData.charCodeAt(6) is "J".charCodeAt(0) or not imgData.charCodeAt(7) is "F".charCodeAt(0) or not imgData.charCodeAt(8) is "I".charCodeAt(0) or not imgData.charCodeAt(9) is "F".charCodeAt(0) or not imgData.charCodeAt(10) is 0x00
        throw new Error("getJpegSize requires a binary jpeg file")
    blockLength = imgData.charCodeAt(4) * 256 + imgData.charCodeAt(5)
    i = 4
    len = imgData.length
    while i < len
        i += blockLength
        if imgData.charCodeAt(i) isnt 0xff
            throw new Error("getJpegSize could not find the size of the image")
        if imgData.charCodeAt(i + 1) is 0xc0
            height = imgData.charCodeAt(i + 5) * 256 + imgData.charCodeAt(i + 6)
            width = imgData.charCodeAt(i + 7) * 256 + imgData.charCodeAt(i + 8)
            return [ width, height ]
        else
            i += 2
            blockLength = imgData.charCodeAt(i) * 256 + imgData.charCodeAt(i + 1)


pdfEscape = (str) ->
    return str.replace(/\\/g, '\\\\').replace(/\(/g, '\\(').replace(/\)/g, '\\)')

round3 = (number) ->
    if typeOf(number) != 'number'
        number = Number(number)
    return number.toFixed(3)


round2 = (number) ->
    if typeOf(number) != 'number'
        number = Number(number)
    return number.toFixed(2)

# parses a color in all the various color formats:
#   fill = "orange"          # color by name
#   fill = "#FFA500"         # color by hex
#   fill = "#FA0"            # color by hex (short)
#   fill = "rgb(255,165,0)"  # color by rgb
#   fill = "rgba(255,165,0,1)" # color by rgba
#   fill = [255, 45, 90]     # color by rgb array
#   fill = [.2, .4, .7]      # color by floating point array
# returns a floating point array
# TODO impliment support for alpha
# TODO impliment support for color by name
parseColor = (color) ->
    ret = [0, 0, 0]
    switch typeOf color
        when 'string'
            # hex format
            if color.charAt(0) is '#'
                if color.length is 4
                    # short hex format means repeate the hex char to form a byte
                    c = parseInt(color.charAt(1), 16)
                    ret[0] = (c*16 + c)/255
                    c = parseInt(color.charAt(2), 16)
                    ret[1] = (c*16 + c)/255
                    c = parseInt(color.charAt(3), 16)
                    ret[2] = (c*16 + c)/255
                if color.length is 7
                    ret[0] = parseInt(color.slice(1,3), 16)/255
                    ret[1] = parseInt(color.slice(3,5), 16)/255
                    ret[2] = parseInt(color.slice(5,7), 16)/255
            # rgb format
            m = color.match(/\((.*)\)/)
            if m?
                colorStrings = m[1].split(',')
                ret[0] = parseInt(colorStrings[0], 10)/255
                ret[1] = parseInt(colorStrings[1], 10)/255
                ret[2] = parseInt(colorStrings[2], 10)/255
        when 'array'
            # if we are all integers and we aren't [1,1,1] assume we're a color
            # specified in bytes (i.e., we need to be divided by 255)
            if Math.floor(color[0]) is color[0] and Math.floor(color[1]) is color[1] and Math.floor(color[2]) is color[2] and (color[0] != 1 or color[1] != 1 or color[2] != 1)
                ret[0] = color[0]/255
                ret[1] = color[1]/255
                ret[2] = color[2]/255
            else
                ret[0] = color[0]
                ret[1] = color[1]
                ret[2] = color[2]
        when 'undefined', 'null'
            ret = [0, 0, 0]
    return ret

parseFont = (fontStr='') ->
    style = 'regular'
    size = 16
    face = 'Helvetica'
    for item in fontStr.split(/\s+/g)
        if item in ['regular', 'normal']
            style = 'regular'
            continue
        if item in ['italic', 'oblique']
            style = 'italic'
            continue
        if item in ['bold']
            style = 'bold'
            continue
        # see if we match a font size
        m = item.match(/^(\d*\.*\d+)(..)$/)
        if m?
            size = parseInt(m[1], 10)
            unit = m[2]
            switch unit
                when 'pt', 'px'
                    break
                when 'em', 'en'     # This is wrong, but I'm not sure how to do it right atm.
                    size *= 16
                when 'mm'
                    size *= 72/25.4
                when 'cm'
                    size *= 72/2.54
                when 'in'
                    size *= 72
                else throw new Error("Invalid font unit: #{@unit} for font string #{fontStr}")
            continue
        # if we made it this far, we aren't a style or size, so we must be a name!
        face = item
    # serif and sans-serif will be replaced with their defaults Helvetica and Times
    if face in ['sans', 'sans-serif', 'sansserif']
        face = 'Helvetica'
    if face in ['serif']
        face = 'Times'

    return [size, face, style]

getStyle = (style) ->
    # turn a style string into a pdf drawing operation
    # see Path-Painting Operators of PDF spec
    switch style
        when 'F'
            return 'f' #fill
        when 'FD', 'DF'
            return 'B' #both
        else
            return 'S' #stroke

###
# Smart typeof function that will recognize builtin types as well as objects
# that are instances of those types.
###
typeOf = (obj) ->
    guess = typeof obj
    if guess != 'object'
        return guess
    if obj == null
        return 'null'

    # if we got 'object', we have some more work to do
    objectTypes =
        'array': Array
        'boolean': Boolean
        'number': Number
        'string': String
    for type, constructor of objectTypes
        if obj instanceof constructor
            return type

    # if we are not one of the builtin types, check to see if we have a named constructor
    constructorName = obj.constructor.name
    # If we truely are a plain-old object type, handle this now
    if constructorName == 'Object'
        return 'object'
    return constructorName


###
# Creates a new Reference with a unique
# index.  The lowest index created will be startCount
###
class ReferenceFactory
    constructor: (startCount=10) ->
        @currIndex = startCount
        @references = []

    create: ->
        ref = new Reference(@currIndex, 0)
        @currIndex += 1
        @references.push(ref)

        return ref

###
# Pdf reference
###
class Reference
    constructor: (@value=0, @revision=0) ->

    toString: ->
        return "#{@value} #{@revision} R"

###
# Pdf dictionary
###
class Dictionary
    constructor: (values={}) ->
        @values = {}
        @indent = ''    #amount to indent by when turing into a string
        # duplicate all the key-value pairs
        for k of values
            @values[k] = values[k]
    set: (key, value) ->
        @values[key] = value
    get: (key) ->
        return @values[key]
    toString: ->
        indent = @indent
        keysIndent = indent + '\t'

        ret = indent + '<<\n'
        for key of @values
            ret += "#{keysIndent}#{key} #{@values[key]}\n"
        ret += indent + '>>'

        return ret

###
# Pdf array.  This class is useful if you want to give an array as value
# of the dictionary, but you want to change the contents of the array later
# on.
###
class PdfArray
    constructor: (values=[]) ->
        @values = values.slice()
        @length = values.length

    push: (value) ->
        @values.push value
        @length = @values.length

    get: (key) ->
        return @values[key]

    toString: ->
        return "[#{@values.join(' ')}]"

###
# Pdf graphics context.  This class has all the basic pdf drawing operations built
# in.  The API is modeled after the canvas API
###
class PdfContex
    ##
    # Some default values
    ##
    lineWidth: 0.200025     # 2mm

    _capAndJoinStyles:
        0: 0
        miter: 0
        butt: 0
        1: 1
        round: 1
        2: 2
        bevel: 2
        projecting: 2
        square: 2

    constructor: (@width=-1, @height=-1, @fontList={}) ->
        @stream = ''
        @propHistory = {}
    toString: ->
        return '' + @stream
    # Identifies whether a property has changed.
    # This is useful for things like: only setting the stroke
    # color if it has changed
    _hasChanged: (prop) ->
        if @[prop]? and not @propHistory[prop]?
            return true
        # TODO use a better comparison method here that also works on arrays!
        if @[prop] != @propHistory[prop]
            return true
        else
            return false
    # Records prop in @propHistory so a change will be detected
    _recordProp: (prop) ->
        # copy the object if it has a slice method
        if @[prop].slice?
            @propHistory[prop] = @[prop].slice()
        else
            @propHistory[prop] = @[prop]
    # Returns the value of prop if it has changed and records
    # the current value of prop in @propHistory
    # If prop hasn't changed, null is returned
    _getIfUpdatedAndTouch: (prop) ->
        ret = null
        if @_hasChanged(prop)
            ret = @[prop]
            @_recordProp(prop)
        return ret

    # returns the coordinates for a bezier curve making an arc
    # anticlockwise from startAngle to endAngle
    # This function is only good if |endAngle - startAngle| < pi/2
    _arcCoords: (x, y, r, startAngle, endAngle) ->
        # get the coordinates for an arc of the correct angle
        # opening to the right (bisected by the x-axis)
        theta = endAngle - startAngle
        x0 = Math.cos(theta/2)
        y0 = Math.sin(theta/2)
        x3 = x0
        y3 = -y0
        x1 = (4-x0)/3
        y1 = (1-x0)*(3-x0)/(3*y0)
        x2 = x1
        y2 = -y1

        # rotate to the startAngle
        s = Math.sin(-(startAngle + theta/2))
        c = Math.cos(-(startAngle + theta/2))
        [x0, y0] = [c*x0-s*y0, s*x0+c*y0]
        [x1, y1] = [c*x1-s*y1, s*x1+c*y1]
        [x2, y2] = [c*x2-s*y2, s*x2+c*y2]
        [x3, y3] = [c*x3-s*y3, s*x3+c*y3]
        # scale to be the right radius
        [x0,x1,x2,x3,y0,y1,y2,y3] = (p*r for p in [x0,x1,x2,x3,y0,y1,y2,y3])
        # translate to the right position
        [x0,x1,x2,x3] = (p+x for p in [x0,x1,x2,x3])
        [y0,y1,y2,y3] = (p+y for p in [y0,y1,y2,y3])

        return [x0, y0, x1, y1, x2, y2, x3, y3]

    ###
    # State modifiers
    ###
    save: ->
        @stream += '\n' + 'q'
    restore: ->
        @stream += '\n' + 'Q'

    ###
    # Transformations
    ###

    #setTransform: (a, b, c, d, e, f) ->  #setTransform needs to reset the transform to the identity before pushing the transform...
    transform: (a, b, c, d, e, f) ->
        points = (round2(p) for p in [a, b, c, d, e, f])
        @stream += '\n' + "#{points.join(' ')} cm"
    scale: (x, y) ->
        @transform(x, 0, 0, y, 0, 0)
    translate: (x, y) ->
        @transform(0, 0, 0, 0, x, y)
    rotate: (theta) ->
        @transform(Math.cos(theta), Math.sin(theta), -Math.sin(theta), Math.cos(theta), 0, 0)


    ###
    # Path operations
    ###
    moveTo: (x, y) ->
        # make our drawing operations start from the upper-left like canvas
        y = @height - y if @height > 1
        @stream += '\n' + "#{round2(x)} #{round2(y)} m"
    lineTo: (x, y) ->
        # make our drawing operations start from the upper-left like canvas
        y = @height - y if @height > 1
        @stream += '\n' + "#{round2(x)} #{round2(y)} l"
    # cubic Bezier spline
    bezierCurveTo: (x1, y1, x2, y2, x3, y3) ->
        # make our drawing operations start from the upper-left like canvas
        y1 = @height - y1 if @height > 1
        y2 = @height - y2 if @height > 1
        y3 = @height - y3 if @height > 1

        points = (round2(p) for p in [x1, y1, x2, y2, x3, y3])
        @stream += '\n' + "#{points.join(' ')} c"
    closePath: ->
        @stream += '\n' + 'h'
    beginPath: ->
        #XXX this closes the current path.  Not sure if this is really what we want here...
        @stream += '\n' + 'n'

    ###
    # Stroking and Filling operations
    ###
    stroke: ->
        out = ''
        # Check to see if the current color has already been pushed or not.
        # If not, use it.
        color = @_getIfUpdatedAndTouch('strokeStyle')
        if color?
            color = parseColor(color)
            out += " #{round3(color[0])} #{round3(color[1])} #{round3(color[2])} RG"
        lineWidth = @_getIfUpdatedAndTouch('lineWidth')
        if lineWidth?
            out += " #{round3(lineWidth)} w"
        cap = @_getIfUpdatedAndTouch('lineCap')
        if cap?
            cap = @_capAndJoinStyles[cap]
            out += " #{cap} J"
        join = @_getIfUpdatedAndTouch('lineJoin')
        if join?
            join = @_capAndJoinStyles[join]
            out += " #{join} j"

        @stream += '\n' + out + ' S'
    fill: ->
        out = ''
        # Check to see if the current color has already been pushed or not.
        # If not, use it.
        color = @_getIfUpdatedAndTouch('fillStyle')
        if color?
            color = parseColor(color)
            out += " #{round3(color[0])} #{round3(color[1])} #{round3(color[2])} rg"

        @stream += '\n' + out + ' f'

    fillAndStroke: ->
        out = ''
        color = @_getIfUpdatedAndTouch('strokeStyle')
        if color?
            color = parseColor(color)
            out += " #{round3(color[0])} #{round3(color[1])} #{round3(color[2])} RG"
        color = @_getIfUpdatedAndTouch('fillStyle')
        if color?
            color = parseColor(color)
            out += " #{round3(color[0])} #{round3(color[1])} #{round3(color[2])} rg"
        lineWidth = @_getIfUpdatedAndTouch('lineWidth')
        if lineWidth?
            out += " #{round3(lineWidth)} w"
        cap = @_getIfUpdatedAndTouch('lineCap')
        if cap?
            cap = @_capAndJoinStyles[cap]
            out += " #{cap} J"
        join = @_getIfUpdatedAndTouch('lineJoin')
        if join?
            join = @_capAndJoinStyles[join]
            out += " #{join} j"

        @stream += '\n' + out + ' B'
    ###
    # Shapes
    ###
    rect: (x, y, w, h) ->
        # make our drawing operations start from the upper-left like canvas
        y = @height - y if @height > 1

        out = "#{round2(x)} #{round2(y)} #{round2(w)} #{round2(-h)} re"
        @stream += '\n' + out

    ellipse: (x, y, rx, ry) ->
        kappa = .5522848
        ox = (rx / 2) * kappa # // control point offset horizontal
        oy = (ry / 2) * kappa # // control point offset vertical
        xe = x + rx  #          // x-end
        ye = y + ry #           // y-end
        xm = x + rx / 2 #       // x-middle
        ym = y + ry / 2 #       // y-middle

        @moveTo(x, ym)
        @bezierCurveTo(x, ym - oy, xm - ox, y, xm, y)
        @bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym)
        @bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye)
        @bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym)
    arc: (x, y, r, startAngle, endAngle, anticlockwise=true) ->
        coords = []
        while endAngle - startAngle > Math.PI/2
            coords.push @_arcCoords(x, y, r, startAngle, startAngle + Math.PI/2)
            startAngle += Math.PI/2
        coords.push @_arcCoords(x, y, r, startAngle, endAngle)

        # to do the curve backwards, just reverse all the points
        if anticlockwise is false
            # TODO fix this so it works. For now just throw an error
            throw new Error('clockwise arcs not implimented yet')
            coords = (c.reverse() for c in coords.reverse())


        # _arcCoords gives back [x0,y0, x1,y1, x2,y2, x3,y3]
        # we want to move to the first coord and then send the remaining
        # to bezierCurveTo
        @moveTo(coords[0][0], coords[0][1])
        for coord in coords
            @bezierCurveTo.apply(this, coord.slice(2))
    ###
    # Text
    ###
    fillText: (x, y, text) ->
        # make our drawing operations start from the upper-left like canvas
        y = @height - y if @height > 1

        ###
        # Inserts something like this into PDF
            BT
            /F1 16 Tf  % Font name + size
            16 TL % How many units down for next line in multiline text
            0 g % color
            28.35 813.54 Td % position
            (line one) Tj
            T* (line two) Tj
            T* (line three) Tj
            ET
        ###

        switch typeOf text
            when 'string'
                # if there are any newlines, split based on them 'cause we assume
                # the user wanted a new line
                text = text.split(/\r\n|\r|\n/g)
            when 'array'
                # an array is assumed to already be split into lines
            else
                throw new Error("Unknown text type for fillText #{text}")

        # make sure the text contains no pdf escape characters
        text = (pdfEscape(t) for t in text)

        # find out the details about the current font
        [size, face, style] = parseFont(@font)
        currentFont = @fontList[face]
        if not currentFont?
            throw new Error("Font face #{face} not in fontList")
        color = parseColor(@['fillStyle'])

        # construct the actual text command
        out =  "BT\n"
        out += "\t#{currentFont} #{round3(size)} Tf\n"
        out += "\t#{round3(size)} TL\n"
        out += "\t#{round3(color[0])} #{round3(color[1])} #{round3(color[2])} rg"
        out += "\t#{round2(x)} #{round2(y)} Td\n"
        out += "\t(#{text.join(') Tj\nT* (')}) Tj\n"
        out += "ET"

        # add the text command to our current stream
        @stream += '\n' + out
    ###
    # Images
    ###
    drawImage: (image, params...) ->
        # find out what version of drawImage we called
        switch params.length
            when 2
                [x, y] = params
                w = 1
                h = 1
            when 4
                [x, y, w, h] = params
            when 8
                [sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight] = params
                throw new Error("Image slicing not implimented yet")
            else
                throw new Error("Improper number of arguments to drawImage: #{image},#{params}")

        # make sure image is of the right type
        switch typeOf image
            when 'string'
                if image.charAt(0) != '/'
                    throw new Error("image must be an image reference starting with '/'")
            else
                throw new Error("image must be an image reference starting with '/', not #{image}")

        # draw the actual image
        y = @height - y if @height > 1
        @save()
        @transform(w, 0, 0, h, x, y - h)
        @stream += '\n' + "#{image} Do"
        @restore()


###
# Pdf object. If stream is left empty the object will be formatted as
#   @reference obj
#     @value
#   endobj
#
# If a stream is given, it is assume that @value is a Dictionary.  The
# '/Length' entry of @value will be set to the length of stream and the
# output will be
#   @reference obj
#     @value
#   stream
#   @stream
#   endstream
#   endobj
###
class PdfObject
    constructor: (@reference = new Reference, @value, @stream) ->
        if @stream?
            if typeOf(@value) != 'Dictionary'
                throw new Error("The value of an object with a stream must be a Dictionary type")
    toString: ->
        ret = "#{@reference.value} #{@reference.revision} obj\n"
        # make sure to set the Length property if we have a stream
        # Since our stream could be some object implimenting a toString method,
        # make sure we convert it to a string before we try to read its length
        streamContents = '' + @stream
        @value.set('/Length', streamContents.length) if @stream?
        ret += "#{@value}\n"
        if @stream?
            ret += "stream\n"
            ret += "#{streamContents}\n"
            ret += "endstream\n"
        ret += "endobj"

        return ret

class PdfImage
    constructor: (@imageData, @format, @width=-1, @height=-1) ->
        @format = @format.toUpperCase()
        switch @format
            when 'JPEG'
                if @width == -1 or @height == -1
                    [@width, @height] = getJpegSize(@imageData)
            else
                if @width == -1 or @height == -1
                    throw new Error("Image dimensions must be explicitly specified for format #{@format}")

    toString: ->
        return '' + @imageData

class jsPDF
    jsPDFVersion: '20120623'

    pdfVersion: '1.4'
    pageFormats:
        'a3': [841.89, 1190.55]
        'a4': [595.28, 841.89]
        'a5': [420.94, 595.28]
        'letter': [612, 792]
        'legal': [612, 1008]
    # This object should be extended with whatever additional api
    # methods you want.  It is only read on initialization, and
    # so the only way to have it set is to set it in the prototype of jsPDF
    API: {}

    constructor: (orientation='portrait', @unit='mm', @format='letter') ->
        # extend the API if there is one
        if @API
            @_extendAPI(@API)
        @pdfcontents = []
        @referenceFactory = new ReferenceFactory(10) # All references less than 10 we reserve for special things

        # set up the scale
        switch @unit
            when 'pt' then @scale = 1
            when 'mm' then @scale = 72/25.4
            when 'cm' then @scale = 72/2.54
            when 'in' then @scale = 72
            else throw new Error("Invalid unit: #{@unit}")

        # set up the orientation
        switch orientation.toLowerCase()
            when 'portrait', 'p' then @orientation = 'portriat'
            when 'landscape', 'l' then @orientation = 'landscape'
            else throw new Error("Unknown orientation: #{orientation}")

        # set up the page dimensions
        switch typeOf @format
            when 'array'
                @pageWidth = format[0] * @scale
                @pageHeight = format[1] * @scale
                @orientation = 'custom'
            when 'string'
                if not (@format of @pageFormats)
                    throw new Error("Unknown page format: #{@format}")
                [@pageWidth, @pageHeight] = @pageFormats[@format]
            else throw new Error("Unknown page format: #{@format}")

        ###
        # set up other instance-level variables
        ###

        # It is suggested to append a few non-ascii caracters
        # right after the start of the pdf file so programs don't think
        # it is an ascii file
        @pdfPrefix = "%PDF-#{@pdfVersion}\n%" + String.fromCharCode(200) + String.fromCharCode(201) + String.fromCharCode(202) + String.fromCharCode(203)
        @pdfSuffix = "%%EOF"

        # a list of all objects that need to be output when creating the pdf
        @objectList = []

        # local hash of all the fonts we have added
        @fontList = {}

        # list of all image resources we have added
        @imageList = []

        @pageReferences = new PdfArray
        @pageList = []
        pagesdict =
            '/Type': '/Pages'
            '/Kids': @pageReferences
            '/Count': 0
            '/MediaBox': "[0 0 #{@pageWidth} #{@pageHeight}]"

        @pagesObject = new PdfObject(new Reference(1,0), new Dictionary(pagesdict))

        @fontDict = new Dictionary()
        @xobjectDict = new Dictionary()

        resourcesdict =
            '/ProcSet': '[/PDF /Text /ImageB /ImageC /ImageI]'
            '/Font': @fontDict
            '/XObject': @xobjectDict
        @resourcesObject = new PdfObject(new Reference(2,0), new Dictionary(resourcesdict))

        catalogdict =
            '/Type': '/Catalog'
            '/Pages': @pagesObject.reference
            '/PageLayout': '/OneColumn'
        @catalogObject = new PdfObject(@referenceFactory.create(), new Dictionary(catalogdict))

        infodict =
            '/Producer': "(jsPDF #{@jsPDFVersion})"
            '/CreationDate': "(D:#{getISODate()})"
        @infoObject = new PdfObject(@referenceFactory.create(), new Dictionary(infodict))

        ###
        # update the objectList to have all the objects we just created
        ###
        @objectList.push @pagesObject
        @objectList.push @resourcesObject
        @objectList.push @catalogObject
        @objectList.push @infoObject

        ###
        # Initialize our current pdf document with fonts and a page
        ###
        for fontName in ['Helvetica', 'Helvetica-Bold', 'Helvetica-Oblique', 'Helvetica-BoldOblique', 'Courier', 'Courier-Bold', 'Courier-Oblique', 'Courier-BoldOblique', 'Times-Roman', 'Times-Bold', 'Times-Italic', 'Times-BoldItalic' ]
            @addFont(fontName)
        @addPage()

    _extendAPI: (newAPI) ->
        for methodName, method of newAPI
            if newAPI.hasOwnProperty(methodName)
                @[methodName] = method

    addPage: ->
        # A page has two parts, the page object which
        # defines the resources, etc. and the page contents,
        # which is just a stream object with all the operations
        # for the page
        pageref = @referenceFactory.create()
        pagecontentref = @referenceFactory.create()

        # make a PdfContex for the new page and scale it so:
        #    * y decends from the top of the page like the rest of the CS world
        #    * the page is scaled according to our choice of units
        context = new PdfContex(@pageWidth, @pageHeight, @fontList)

        # create an object for the page content
        newpagecontent = new PdfObject(pagecontentref, new Dictionary, context)

        # create the pages object
        pagedict =
            '/Type': '/Page'
            '/Parent': @pagesObject.reference
            '/Resources': @resourcesObject.reference
            '/Contents': newpagecontent.reference
        newpage = new PdfObject(pageref, new Dictionary(pagedict))
        @pageList.push(newpage)

        # make sure @pagesObject is updated with the info needed
        # for the new page
        @pageReferences.push(pageref)
        @pagesObject.value.set('/Count', @pageReferences.length)

        # we are going to want to edit the current page's contents,
        # so make sure to keep a way to access it
        @currentPageContents = newpagecontent

        # update the master object list with the objects we just created
        @objectList.push newpage
        @objectList.push newpagecontent
        return this

    addFont: (fontName) ->
        # Check to see if it is one of the default pdf fonts
        if !(fontName in ['Helvetica', 'Helvetica-Bold', 'Helvetica-Oblique', 'Helvetica-BoldOblique', 'Courier', 'Courier-Bold', 'Courier-Oblique', 'Courier-BoldOblique', 'Times-Roman', 'Times-Bold', 'Times-Italic', 'Times-BoldItalic' ])
            throw new Error("Unknown font #{fontName}.  External fonts not supported yet.")

        if @fontList[fontName]?
            return

        # If we made it this far, we need to add the font
        fontdict =
            '/Type': '/Font'
            '/BaseFont': "/#{fontName}"
            '/Subtype': '/Type1'
            '/Encoding': '/WinAnsiEncoding'
        font = new PdfObject(@referenceFactory.create(), new Dictionary(fontdict))

        # Quick and dirty way to get a unique font id
        fontId = '/F' + (Object.keys(@fontList).length + 1)
        # @fontDict will tell the pdf what references to look at for each font
        @fontDict.set(fontId, font.reference)
        @fontList[fontName] = fontId

        # update the master object list with the objects we just created
        @objectList.push font
        return this
    addImageResource: (imageData, format) ->
        if format.toUpperCase() != 'JPEG'
            throw new Error('currently only JPEG format is supported for images')

        image = new PdfImage(imageData, format)
        # give the image a unique pdf-formatted name and add it to the imageList
        image.name = "/I#{@imageList.length+1}"
        @imageList.push image

        imagedict =
            '/Type': '/XObject'
            '/Subtype': '/Image'
            '/Width': image.width
            '/Height': image.height
            '/ColorSpace': '/DeviceRGB'
            '/BitsPerComponent': '8'
            '/Filter': '/DCTDecode'
            #'/DecodeParams': '[]' # DecodeParams not used in DCTDecode objects...
            #'/Mask': '[]' # Not supported yet
            #'/SMask': '[]' # Not supported yet
        imageReferece = @referenceFactory.create()
        imageObj = new PdfObject(imageReferece, new Dictionary(imagedict), image)

        # add the image to our object list and create an entry in our XObject-container for it
        @objectList.push imageObj
        @xobjectDict.set(image.name, imageReferece)

        return image

    setProperties: (props) ->
        keys =
            'title': '/Title'
            'subject': '/Subject'
            'author': '/Author'
            'keywords': '/Keywords'
            'creator': '/Creator'
        for p of props
            if p of keys
                @infoObject.value.set(keys[p], "(#{pdfEscape(props[p])})")
        return this

    _buildOutput: ->
        # Put the pdf header
        out = @pdfPrefix + '\n'

        # Put all the objects into the body of the pdf
        xrefLocations = []
        for obj in @objectList
            xrefLocations.push out.length
            out += obj + '\n'

        ###
        # Put in the xref table
        ###
        # Make sure a newline preceeds the xref table
        out += '\n'
        xrefStart = out.length
        out += @_buildXref(xrefLocations)

        # Build the trailer
        trailerdict =
            '/Size': xrefLocations.length + 1  # +1 since xref adds a dummy line
            '/Root': @catalogObject.reference  # the catalogObject is the root
            '/Info': @infoObject.reference
        out += '\ntrailer\n'
        out += new Dictionary(trailerdict)
        out += '\nstartxref\n'
        out += xrefStart + '\n'

        # Put the pdf footer
        out += @pdfSuffix

    _buildXref: (xrefLocations) ->
        padd10 = (num) ->
            ret = num.toFixed(0)
            return ret if ret.length >= 10
            return Array(11 - ret.length).join('0') + ret

        ret = 'xref\n'
        ret += "0 #{xrefLocations.length+1}\n"
        ret += '0000000000 65535 f '

        for n in xrefLocations
            ret += '\n'
            ret += "#{padd10(n)} 00000 n "

        return ret

    output: (type='string', options) ->
        switch type
            when 'string'
                return @_buildOutput()
            when 'datauristring', 'dataurlstring'
                return 'data:application/pdf;base64,' + base64encode(@_buildOutput())
            when 'datauri','dataurl'
                data = 'data:application/pdf;base64,' + base64encode(@_buildOutput())
                document.location.href = data
            else
                throw new Error("Output type #{type} not supported.")
        return this

###
# Set up an implimentation of the original jsPDF API.  This is the default
# api for jsPDF, but it can easily be swapped out or extened to suit one's tastes
###
jsPDFOriginalAPI =
    _applyStyle: (style) ->
        switch style
            when 'F'
                #fill
                @currentPageContents.stream.fill()
            when 'FD', 'DF'
                #both
                @currentPageContents.stream.fillAndStroke()
            else
                #stroke
                @currentPageContents.stream.stroke()

    _fontLookup:
        'helvetica':
            'normal': 'Helvetica'
            'bold': 'Helvetica-Bold'
            'italic': 'Helvetica-Oblique'
            'bolditalic': 'Helvetica-BoldOblique'
        'courier':
            'normal': 'Courier'
            'bold': 'Courier-Bold'
            'italic': 'Courier-Oblique'
            'bolditalic': 'Courier-BoldOblique'
        'times':
            'normal': 'Times-Roman'
            'bold': 'Times-Bold'
            'italic': 'Times-Italic'
            'bolditalic': 'Times-BoldItalic'
    defaultFont: 'Helvetica'
    defaultFontColor: [0, 0, 0]
    defaultFontSize: 16
    setFont: (fontName) ->
        if fontName of @fontList
            @currentFont = fontName
            @currentFontFamilyName = null
        else if fontName.toLowerCase() of @_fontLookup
            @currentFontFamilyName = fontName.toLowerCase()
        else
            throw new Error("Unknown font: #{fontName}; It must first be added with addFont")
        return this

    setFontSize: (size) ->
        @currentFontSize = size
        return this

    setFontType: (type) ->
        if type in ['normal', 'italic', 'bold', 'bolditalic']
            @currentFontType = type
        else
            throw new Error("Unknown font type: #{type}")
        return this

    setTextColor: (r=0, g, b) ->
        if g?
            @currentFontColor = [r, g, b]
        else
            @currentFontColor = [r, r, r]
        return this

    setDrawColor: (r, g, b) ->
        if g?
            @currentPageContents.stream.strokeStyle = [r, g, b]
        else
            @currentPageContents.stream.strokeStyle = [r, r, r]
        return this

    setFillColor: (r, g, b) ->
        if g?
            @currentPageContents.stream.fillStyle = [r, g, b]
        else
            @currentPageContents.stream.fillStyle = [r, r, r]
        return this

    setLineWidth: (width) ->
        @currentPageContents.stream.lineWidth = width*@scale
        return this

    setLineCap: (style) ->
        @currentPageContents.stream.lineCap = style
        return this

    setLineJoin: (style) ->
        @currentPageContents.stream.lineJoin = style
        return this
    ###*
     * Adds text to page. Supports adding multiline text when 'text' argument is an Array of Strings.
     * @param {Number} x Coordinate (in units declared at inception of PDF document) against left edge of the page
     * @param {Number} y Coordinate (in units declared at inception of PDF document) against upper edge of the page
     * @param {String|Array} text String or array of strings to be added to the page. Each line is shifted one line down per font, spacing settings declared before this call.
     * @function
     * @returns {jsPDF}
     * @name jsPDF.text
    ###
    text: (x, y, text) ->
        # scale our x and y appropriately
        x = x * @scale
        y = y * @scale

        # set up any defaults if they aren't currently set
        if not @currentFontSize?
            @setFontSize(@defaultFontSize)
        if not @currentFont? and not @currentFontFamilyName?
            @setFont(@defaultFont)
        if not @currentFontColor?
            @setTextColor.apply(this, @defaultFontColor)

        # if a family name is set, retrieve the corresponding font
        fontType = if @currentFontType? then @currentFontType else 'normal'
        if @currentFontFamilyName?
            @currentFont = @_fontLookup[@currentFontFamilyName][fontType]

        # set the font style and color
        @currentPageContents.stream.font = "#{@currentFontSize}pt #{@currentFont}"
        @currentPageContents.stream.fillStyle = @currentFontColor

        # add the text command to our current stream
        @currentPageContents.stream.fillText(x, y, text)
        return this

    line: (x1, y1, x2, y2) ->
        # scale our x and y appropriately
        x1 = x1 * @scale
        y1 = y1 * @scale
        x2 = x2 * @scale
        y2 = y2 * @scale

        @currentPageContents.stream.moveTo(x1, y1)
        @currentPageContents.stream.lineTo(x2, y2)
        @currentPageContents.stream.stroke()
        return this
    ###*
     * Adds series of curves (straight lines or cubic bezier curves) to canvas,
     * starting at `x`, `y` coordinates.
     * All data points in `lines` are relative to last line origin.
     * `x`, `y` become x1,y1 for first line / curve in the set.
     * For lines you only need to specify [x2, y2] - (ending point) vector
     * against x1, y1 starting point.
     * For bezier curves you need to specify [x2,y2,x3,y3,x4,y4] - vectors to control
     * points 1, 2, ending point. All vectors are against the start of the curve - x1,y1.
     *
     * @example .lines(212,110,[[2,2],[-2,2],[1,1,2,2,3,3],[2,1]], 10) // line, line, bezier curve, line
     * @param {Number} x Coordinate (in units declared at inception of PDF document) against left edge of the page
     * @param {Number} y Coordinate (in units declared at inception of PDF document) against upper edge of the page
     * @param {Array} lines Array of *vector* shifts as pairs (lines) or sextets (cubic bezier curves).
     * @param {Number} scale (Defaults to [1.0,1.0]) x,y Scaling factor for all vectors. Elements can be any floating number Sub-one makes drawing smaller. Over-one grows the drawing. Negative flips the direction.
     * @function
     * @returns {jsPDF}
     * @name jsPDF.text
    ###
    lines: (x, y, lines, scale, style) ->
        # Set up the scaling parameters
        scalex = @scale
        scaley = @scale
        switch typeOf scale
            when 'number'
                scalex *= scale
                scaley *= scale
            when 'array'
                scalex *= scale[0]
                scaley *= scale[1]

        # Do the actual drawing
        basex = x*scalex
        basey = y*scaley
        @currentPageContents.stream.moveTo(basex, basey)
        for p in lines
            switch p.length
                when 2
                    basex += p[0]*scalex
                    basey += p[1]*scaley
                    @currentPageContents.stream.lineTo(basex, basey)
                when 6
                    x2 = p[0]*scalex + basex
                    y2 = p[1]*scaley + basey
                    x3 = p[2]*scalex + basex
                    y3 = p[3]*scaley + basey
                    basex = p[4]*scalex + basex
                    basey = p[5]*scaley + basey
                    @currentPageContents.stream.bezierCurveTo(x2, y2, x3, y3, basex, basey)
                else
                    throw new Error("Unknown type of line #{p}; Should specify 2 or 6 coordinates.")
        @_applyStyle(style)
        return this

    rect: (x, y, w, h, style) ->
        # scale our x and y appropriately
        x = x * @scale
        y = y * @scale
        w = w * @scale
        h = h * @scale

        @currentPageContents.stream.rect(x, y, w, h)
        @_applyStyle(style)
        return this

    triangle: (x1, y1, x2, y2, x3, y3, style) ->
        [x1, y1, x2, y2, x3, y3] = (c * @scale for c in [x1, y1, x2, y2, x3, y3])

        @currentPageContents.stream.moveTo(x1, y1)
        @currentPageContents.stream.lineTo(x2, y2)
        @currentPageContents.stream.lineTo(x3, y3)
        @currentPageContents.stream.closePath()
        @_applyStyle(style)
        return this

    ellipse: (x, y, rx, ry, style) ->
        # scale our x and y appropriately
        x = x * @scale
        y = y * @scale
        rx = rx * @scale
        ry = ry * @scale

        @currentPageContents.stream.ellipse(x, y, rx, ry)
        @_applyStyle(style)
        return this

    circle: (x, y, r, style) ->
        @ellipse(x, y, r, r, style)
        return this

    addImage: (image, format, x, y, w=72, h=72) ->
        x = x * @scale
        y = y * @scale
        w = w * @scale
        h = h * @scale
        image = @addImageResource(image, format)
        @currentPageContents.stream.drawImage(image.name, x, y, w, h)


###
# Set the jsPDF API
#
# This must be done to the prototype!
###
jsPDF.prototype.API = jsPDFOriginalAPI

###
# Attach jsPDF to the global scope manually, in case it is wrapped in a closure.
# We do this in a way compatible with both the browser and node.js
###
try
    root = exports ? this
    root.jsPDF = jsPDF
catch e

