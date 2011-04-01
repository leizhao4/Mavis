$(document).ready(function() {
  show_alignment_header("Multiple Sequence Alignment Visualization");
  show_alignment_footer();
});

function show_alignment_header(title) {
  $("#alignment_1 .alignment_header").html(title);
}

function show_alignment_footer() {
  $("#alignment_1 .alignment_footer").html(new Date().toLocaleString());
}