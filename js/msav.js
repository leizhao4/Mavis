$(document).ready(function() {
  createAlignmentLayout("Multiple Sequence Alignment Visualization")
  createAlignmentTable("api.pl?query=alignment");
  createAlignmentColors("api.pl?query=colors");
});

function createAlignmentLayout(title) {
  $("#alignment_container").html("<div id='alignment_header'>" + title + "</div>");
  $("#alignment_container").append("<table id='alignment_table' cellspacing='0'></table>");
  $("#alignment_container").append("<div id='alignment_footer'>" + new Date().toLocaleString() + "</div>");
}

function createAlignmentTable(apiUrl) {
  $.getJSON(apiUrl, function(alignment) {
    $.each(alignment, function(i, sequence) {
      var rowHtml = "<tr><td id='seq_hue_" + sequence.row + "'>&nbsp;</td>" +
                    "<td class='seq_name'>" + sequence.name + "</td>";
      $.each(sequence.seq.split(''), function(j, character) {
        var column = j + 1;
        rowHtml += "<td id='cell_" + sequence.row + "_" + column + "'>" + character + "</td>";
      });
      rowHtml += "</tr>";
      $("#alignment_table").append(rowHtml);
    });
  });
}

function createAlignmentColors(apiUrl) {
  $.getJSON(apiUrl, function(colors) {
    $.each(colors, function(column, columnColors) {
      if (columnColors != null) {
        $.each(columnColors, function(row, cellColor) {
          $("#cell_" + row + "_" + column).css("background-color", cellColor);
        });
      }
    });
  });
}