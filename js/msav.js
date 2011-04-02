$(document).ready(function() {
  createAlignmentLayout("Multiple Sequence Alignment Visualization")
  createAlignmentTable();
});

function createAlignmentLayout(title) {
  $("#alignment_container").html("<div id='alignment_header'>" + title + "</div>");
  $("#alignment_container").append("<table id='alignment_table' cellspacing='0'></table>");
  $("#alignment_container").append("<div id='alignment_footer'>" + new Date().toLocaleString() + "</div>");
}

function createAlignmentTable() {
  $.getJSON("api.pl", function(alignment) {
    $.each(alignment, function(i, sequence) {
      var rowHTML = "<tr><td id='seq_hue_" + sequence.row + "'>&nbsp;</td>" +
                    "<td class='seq_name'>" + sequence.name + "</td>";
      $.each(sequence.seq.split(''), function(j, character) {
        var column = j + 1;
        rowHTML += "<td id='cell_" + sequence.row + "_" + column + "'>" + character + "</td>";
      });
      rowHTML += "</tr>";
      $("#alignment_table").append(rowHTML);
    });
  });
}