
NickleSlots = Object.new ({
:editable => function (q) {
  var e = $(q)
  e.wrapInner("<span class='ns_edit_value'>")
  e.append("&nbsp;<a href='#' class='ns_edit_link' onclick='NickleSlots.editable_start(\"" + q + "\")' >edit</a>")
},

:editable_start => function (q) {
  var e = $(q)
  var t = e.children(".ns_edit_value").text()
  e.html("<input name='" + q + "' class='ns_edit_field' type='text' value='" + t + "' onblur='NickleSlots.editable_finish(\"" + q + "\")' />")
  e.children(".ns_edit_field").focus()
},

:editable_finish => function(q) {
  var e = $(q)
  var t = e.children(".ns_edit_field").val()
  var uri = e.attr("ref")

  // Replace our span with the input field value.
  e.text(t)

  // Create a status field.
  e.append("<span class='ms_edit_status'> saving ... (" + JSON.stringify(uri) + ")</span>")
  var status = e.children(".ns_edit_status")

  // Pretend to send it via AJAX.
  status.fadeOut(3000, function () { 
    e.remove(".ns_edit_status")
    // After complete, make field editable again.
    self.editable(q)
  })
  }
})