/* Original synthesized crowd reactions; tab audio capture includes these. */
(() => {
  let audio = null, finish = null, volume = 1;
  let context = null, source = null, gain = null, serial = 0;
  const buffers = new Map();
  async function unlock() {
    const Context = window.AudioContext || window.webkitAudioContext;
    if (!Context) return;
    context ||= new Context();
    await context.resume();
  }
  function stop() {
    serial++;
    if (source) { try { source.stop(); } catch (_) {} source = null; }
    if (audio) { audio.pause(); audio.src = ''; audio = null; }
    if (finish) { const done = finish; finish = null; done(); }
  }
  window.orqubeEffects = {
    stop, unlock,
    setVolume(v) { volume = Math.min(1, Math.max(0, Number(v) || 0)); if (audio) audio.volume = volume; if (gain) gain.gain.value = volume; },
    async play(stage) {
      const name = /웃음/.test(stage) ? 'laugh' : /박수/.test(stage) ? 'applause' : /반전/.test(stage) ? 'twist' : '';
      if (!name || !volume) return;
      stop();
      if (context) {
        const ticket = serial;
        try {
          await context.resume();
          if (!buffers.has(name)) {
            const response = await fetch(new URL('debate_sfx/' + name + '.wav', document.baseURI));
            if (!response.ok) throw new Error('Effect HTTP ' + response.status);
            buffers.set(name, await context.decodeAudioData(await response.arrayBuffer()));
          }
          if (ticket !== serial) return;
          await new Promise(resolve => {
            const current = source = context.createBufferSource();
            current.buffer = buffers.get(name);
            gain = context.createGain(); gain.gain.value = volume;
            current.connect(gain); gain.connect(context.destination);
            const done = () => { if (source === current) { source = null; finish = null; } resolve(); };
            finish = done; current.onended = done; current.start();
          });
          return;
        } catch (error) { console.warn('ORQUBE effect playback failed', error); }
      }
      const current = audio = new Audio(new URL('debate_sfx/' + name + '.wav', document.baseURI).href);
      current.volume = volume;
      await new Promise(resolve => {
        let timer;
        const done = () => { clearTimeout(timer); if (audio === current) { audio = null; finish = null; } resolve(); };
        finish = done;
        current.onended = done;
        current.onerror = done;
        timer = setTimeout(() => { current.pause(); done(); }, 15000);
        current.play().catch(done);
      });
    }
  };
})();
