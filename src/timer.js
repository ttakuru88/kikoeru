var tid;

onmessage = function(e) {
  if(tid) {
    clearInterval(tid);
    tid = null;
  }

  if(e.data > 0){
    tid = setInterval(function(){
      postMessage(null);
    }, e.data);
  }
}
