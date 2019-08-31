// send message on pressing enter
jQuery(document).ready(function(){
  jQuery('#entry').keypress(function(evt){
    if (evt.keyCode == 13){
      // Enter, simulate clicking send
      jQuery('#send').click();
    }
  });
})

// autoscroll for new content
var oldContent = null;
window.setInterval(function() {
  var elem = document.getElementById('chat');
  if (oldContent != elem.innerHTML){
    scrollToBottom();
  }
  oldContent = elem.innerHTML;  
}, 300);

function scrollToBottom(){
  var elem = document.getElementById('chat');
  elem.scrollTop = elem.scrollHeight;
}