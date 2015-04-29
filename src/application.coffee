class SeekBar
  constructor: ->
    @$el = $('#seek-bar')
    @seekbar     = @$el.find('input')[0]
    @currentTime = @$el.find('.current-time')[0]
    @allTime     = @$el.find('.all-time')[0]

    @setMinSeconds(0)
    @setValue(0)
    @setMaxSeconds(0)

    @fixed = false
    @$el.on 'mousemove', =>
      @fixed = true
      @$el.addClass('hover')
    @$el.on 'mouseleave', =>
      @fixed = false
      @$el.removeClass('hover')

  setSource: (@source) ->
    @setMaxSeconds(@source.buffer.duration)
    @setValue(0)

  setValue: (value, silent = false) ->
    @seekbar.value = value
    @currentTime.innerText = @timeFormat(value)

    unless silent
      @startTimeAt = new Date
      @startValue = +value

  update: ->
    @setValue(@startValue + (new Date - @startTimeAt) / 1000, true)

  seconds: ->
    @seekbar.value

  setMaxSeconds: (max) ->
    @seekbar.setAttribute('max', max)
    @allTime.innerText = @timeFormat(max)

  setMinSeconds: (min) ->
    @seekbar.setAttribute('min', min)

  onChange: (func) ->
    $(@seekbar).off().on('change', func)

  timeFormat: (seconds) ->
    minutes = Math.floor(seconds / 60)
    seconds = Math.floor(seconds) % 60

    minutes = "0#{minutes}" if minutes < 10
    seconds = "0#{seconds}" if seconds < 10

    "#{minutes}:#{seconds}"

$ ->
  seekBar = new SeekBar
  source = null
  audioContext = new (window.AudioContext || window.webkitAudioContext)
  fileReader   = new FileReader
  worker = new Worker("timer.js")
  worker.onmessage = (e) ->
    render()

  gainNode = audioContext.createGain()
  gainNode.connect(audioContext.destination)

  analyser = audioContext.createAnalyser()
  analyser.fftSize = 32

  canvas        = document.getElementById('visualizer')
  canvasContext = canvas.getContext('2d')
  canvas.setAttribute('width', analyser.frequencyBinCount * 10)

  saveBuffer = null
  fileReader.onload = ->
    audioContext.decodeAudioData fileReader.result, (buffer) ->
      saveBuffer = buffer
      restart(0)

  seekBar.onChange ->
    if saveBuffer
      restart(seekBar.seconds())

  restart = (offsetSec) ->
    gainNode.gain.value = 0
    if source
      source.stop()
      worker.postMessage(null)

    source = audioContext.createBufferSource()

    source.buffer = saveBuffer
    source.connect(gainNode)
    source.connect(analyser)

    seekBar.setSource(source)
    seekBar.setValue(offsetSec)

    source.start(0, offsetSec)

    worker.postMessage(Math.floor(1000 / 30))

  document.getElementById('file').addEventListener 'change', (e) ->
    fileReader.readAsArrayBuffer(e.target.files[0])

  render = ->
    spectrums = new Uint8Array(analyser.frequencyBinCount)
    analyser.getByteFrequencyData(spectrums)

    canvasContext.clearRect(0, 0, canvas.width, canvas.height)

    spectrumSum = 0
    len = spectrums.length
    for spectrum, i in spectrums
      canvasContext.fillRect((len - i - 1)*10, canvas.height - spectrum, 5, spectrum)
      spectrumSum += spectrum

    if spectrumSum > 0
      ratio = 1500.0 / spectrumSum
      gainNode.gain.value = Math.pow(ratio, 1.4)

      canvasContext.fillText("x #{Math.round(ratio * 100) / 100}", 10, 10)

      unless seekBar.fixed
        seekBar.update()
