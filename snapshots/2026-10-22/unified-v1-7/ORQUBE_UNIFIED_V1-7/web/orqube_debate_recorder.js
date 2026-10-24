/* Records only the screen/tab selected explicitly by the user. No microphone. */
(() => {
  let recorder = null, stream = null, chunks = [], filename = '', finishing = null;
  const release = () => { if (stream) stream.getTracks().forEach(t => t.stop()); stream = null; };
  window.orqubeRecorder = {
    get recording() { return !!recorder && recorder.state !== 'inactive'; },
    async start() {
      if (this.recording) throw new Error('이미 녹화 중입니다.');
      if (!navigator.mediaDevices?.getDisplayMedia || !window.MediaRecorder) throw new Error('이 브라우저는 탭 녹화를 지원하지 않습니다. PC Chrome 또는 Edge에서 실행해 주세요.');
      stream = await navigator.mediaDevices.getDisplayMedia({video: {displaySurface: 'browser'}, audio: true, preferCurrentTab: true, selfBrowserSurface: 'include', systemAudio: 'exclude', monitorTypeSurfaces: 'exclude', surfaceSwitching: 'exclude'});
      if (stream.getVideoTracks()[0]?.getSettings().displaySurface !== 'browser') { release(); throw new Error('토론 음성만 녹화하려면 전체 화면이나 창 대신 현재 토론 브라우저 탭을 선택해 주세요.'); }
      const types = ['video/webm;codecs=vp9,opus','video/webm;codecs=vp8,opus','video/webm','video/mp4'];
      const mimeType = types.find(t => MediaRecorder.isTypeSupported(t));
      if (!mimeType) { release(); throw new Error('지원되는 영상 저장 형식이 없습니다.'); }
      try { recorder = new MediaRecorder(stream, {mimeType}); } catch(e) { release(); throw e; }
      chunks = [];
      filename = `ORQUBE_DEBATE_${new Date().toISOString().replace(/[:.]/g,'-')}.${mimeType.startsWith('video/mp4') ? 'mp4' : 'webm'}`;
      recorder.ondataavailable = e => { if (e.data.size) chunks.push(e.data); };
      finishing = new Promise((resolve,reject) => {
        recorder.onerror = () => { release(); chunks=[]; reject(new Error('녹화 중 오류가 발생했습니다.')); };
        recorder.onstop = () => {
          try {
            const blob = new Blob(chunks,{type:mimeType}); chunks=[]; release();
            if (!blob.size) { reject(new Error('저장할 녹화가 없습니다.')); return; }
            const url = URL.createObjectURL(blob), a=document.createElement('a');
            a.href=url;a.download=filename;document.body.appendChild(a);a.click();a.remove();
            setTimeout(()=>URL.revokeObjectURL(url),60000); resolve(filename);
          } catch(e) {release();reject(e);}
        };
      });
      // Avoid an unhandled rejection if the browser stops sharing independently.
      finishing.catch(()=>{});
      stream.getVideoTracks()[0].onended = () => { if (this.recording) recorder.stop(); };
      try { recorder.start(1000); } catch(e) { release(); recorder=null; throw e; }
      return stream.getAudioTracks().length ? '탭 소리를 포함하여 녹화를 시작했습니다.' : '녹화를 시작했습니다. 소리가 선택되지 않아 영상만 저장됩니다. 소리도 필요하면 저장 후 다시 시작하고 탭 오디오 공유를 선택하세요.';
    },
    async stop() { if (this.recording) recorder.stop(); return finishing ? await finishing : ''; },
  };
})();
