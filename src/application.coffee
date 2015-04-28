window.onload = ->
  source = null
  animationId = null
  audioContext = new (window.AudioContext || window.webkitAudioContext)
  fileReader   = new FileReader

  gainNode = audioContext.createGain()
  gainNode.connect(audioContext.destination)

  analyser = audioContext.createAnalyser()
  analyser.fftSize = 32

  canvas        = document.getElementById('visualizer')
  canvasContext = canvas.getContext('2d')
  canvas.setAttribute('width', analyser.frequencyBinCount * 10)

  fileReader.onload = ->
    audioContext.decodeAudioData fileReader.result, (buffer) ->
      if source
        source.stop()
        cancelAnimationFrame(animationId)

      source = audioContext.createBufferSource()

      source.buffer = buffer
      source.connect(gainNode)
      source.connect(analyser)
      source.start(0)

      animationId = requestAnimationFrame(render)

  document.getElementById('file').addEventListener 'change', (e) ->
    fileReader.readAsArrayBuffer(e.target.files[0])

  render = ->
    spectrums = new Uint8Array(analyser.frequencyBinCount)
    analyser.getByteFrequencyData(spectrums)

    canvasContext.clearRect(0, 0, canvas.width, canvas.height)

    spectrumSum = 0
    for spectrum, i in spectrums
      canvasContext.fillRect(i*10, 0, 5, spectrum)
      spectrumSum += spectrum

    if spectrumSum > 0
      ratio = 1500.0 / spectrumSum
      gainNode.gain.value = Math.pow(ratio, 1.4)

    animationId = requestAnimationFrame(render)
