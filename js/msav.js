$(document).ready(function() {
  create_alignment_layout("Multiple Sequence Alignment Visualization")
});

function create_alignment_layout(title) {
  $("#alignment_container").html("<div id='alignment_header'>" + title + "</div>");
  $("#alignment_container").append("<table id='alignment_table' cellspacing='0'></table>");
  $("#alignment_container").append("<div id='alignment_footer'>" + new Date().toLocaleString() + "</div>");
  create_alignment_table();
}

function create_alignment_table() {
  //$("#alignment_table").html();
}