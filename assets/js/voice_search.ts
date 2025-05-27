// VoiceSearch LiveView Hook for voice entry in address search
// TypeScript safe, with fallback for unsupported browsers

declare global {
  interface Window {
    webkitSpeechRecognition?: any;
  }
}

const VoiceSearch = {
  mounted() {
    const micBtn = this.el as HTMLButtonElement;
    const input = document.getElementById("address-search") as HTMLInputElement | null;
    let recognition: any;
    if (window.webkitSpeechRecognition && input) {
      recognition = new window.webkitSpeechRecognition();
      recognition.lang = 'en-US';
      recognition.onresult = function(event: any) {
        if (event.results.length > 0) {
          input.value = event.results[0][0].transcript;
          input.dispatchEvent(new Event('input', { bubbles: true }));
        }
      };
      micBtn.addEventListener('click', () => recognition.start());
    } else {
      micBtn.disabled = true;
      micBtn.title = "Voice search not supported";
    }
  }
};

export default VoiceSearch;
