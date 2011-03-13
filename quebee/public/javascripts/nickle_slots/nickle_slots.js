// -*- javascript-mode -*-

NickleSlots = {

  editable : function (data) {
    var q = '#' + data.dom_id
    var e = $(q);
    e.ns_data = data
    e.
    wrapInner("<a href='#' title=\"Click to Edit\" class='ns_edit_link' onclick='NickleSlots.editable_start(\"" + q + "\")' >").
    wrapInner("<span class='ns_edit_value'>");
    // e.prepend("&nbsp;<a href='#' title=\"Click to Edit\" class='ns_edit_link' onclick='NickleSlots.editable_start(\"" + q + "\")' ><img src=\"/images/edit.png\" alt=\"Edit\" /></a>");
  },

  editable_start : function (q) {
    var e = $(q);
    var t = e.children(".ns_edit_value").text();
    e.html("<input name='" + q + "' class='ns_edit_field' type='text' value='" + t + "' onblur='NickleSlots.editable_finish(\"" + q + "\")' />");
    e.children(".ns_edit_field").focus();
  },

  editable_finish : function (q) {
    var e = $(q);
    var data = e.ns_data;
    var t = e.children(".ns_edit_field").val();
    var uri = e.attr("ref");

    // Replace our span with the input field value.
    e.text(t);

    // Create a status field.
    e.append("<span class='ns_edit_status'> saving ... (" + JSON.stringify(uri) + ")</span>");
    var status = e.children(".ns_edit_status");

    // Pretend to send it via AJAX.
    status.fadeOut(3000, function () { 
      e.remove(".ns_edit_status");
      // After complete, make field editable again.
      NickleSlots.editable(q);
    })
  }

};

