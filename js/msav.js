$(document).ready(function() {
  show_alignment_header("Test");
  show_alignment_footer();
});

function show_alignment_header(title) {
  $(".alignment_header").html(title);
}

function show_alignment_footer() {
  $(".alignment_footer").html(new Date().toLocaleString());
}