var alignmentID = "MyAlignment";
var showText = false;

$(document).ready(function() {
  drawAlignmentLayout("Multiple Sequence Alignment Visualization (" + alignmentID + ")")
  drawAlignmentTable();
  drawAlignmentColors();
});

function apiUrl(alignmentID, action) {
  return "api.pl?id=" + alignmentID + "&action=" + action;
}

function drawAlignmentLayout(title) {
  $("#alignment_container").html("<div id='alignment_header'>" + title + "</div>");
  $("#alignment_container").append("<table id='alignment_table' cellspacing='0'></table>");
  $("#alignment_container").append("<div id='alignment_footer'>" + new Date().toLocaleString() + "</div>");
}

function drawAlignmentTable() {
  $.getJSON(apiUrl(alignmentID, "alignment"), function(alignment) {
    $("#alignment_table").empty();
    $.each(alignment, function(i, sequence) {
      var rowHtml = "<tr><td id='seq_hue_" + sequence.row + "'>&nbsp;</td><td class='seq_name'>" + sequence.name + "</td>";
      $.each(sequence.seq.split(''), function(j, character) {
        var column = j + 1;
        if (!showText) character = "&nbsp;";
        rowHtml += "<td id='cell_" + sequence.row + "_" + column + "'>" + character + "</td>";
      });
      rowHtml += "</tr>";
      $("#alignment_table").append(rowHtml);
    });
  });
}

function drawAlignmentColors() {
  $.getJSON(apiUrl(alignmentID, "colors"), function(colors) {
    $.each(colors, function(column, columnColors) {
      if (columnColors != null) {
        $.each(columnColors, function(row, cellColor) {
          $("#cell_" + row + "_" + column).css("background-color", cellColor);
        });
      }
    });
  });
}

function toggleAlignmentText() {
  showText = !showText;
  drawAlignmentTable();
  drawAlignmentColors();
}
