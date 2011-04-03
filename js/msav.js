var alignmentID   = urlParam("id");
var showText      = false;
var DataStatus    = { "Ready" : 1, "Pending" : 0, "Error" : -1 };
var alignmentData = { "id" : alignmentID, "status" : DataStatus.Pending, "sequences" : [], "colors" : [] };

$(document).ready(function() {
  getAlignment(alignmentID);
  drawAlignmentLayout("Multiple Sequence Alignment Visualization (" + alignmentID + ")");
  refreshDisplay();
});

function apiUrl(alignmentID, action) {
  return "api.pl?id=" + alignmentID;
}

function getAlignment(alignmentID) {
  $.getJSON(apiUrl(alignmentID), function(alignment) { alignmentData = alignment; });
}

function refreshDisplay() {
  drawAlignmentTable();
  drawAlignmentColors();
}

function drawAlignmentLayout(title) {
  $("#alignment_container").html("<div id='alignment_header'>" + title + "</div>");
  $("#alignment_container").append("<a href='#' class='button' onclick='toggleAlignmentText()'>Show/Hide Sequence Text</a>");
  $("#alignment_container").append("<table id='alignment_table' cellspacing='0'></table>");
  $("#alignment_container").append("<div id='alignment_footer'>" + new Date().toLocaleString() + "</div>");
}

function drawAlignmentTable() {
  if (alignmentData.status == DataStatus.Ready) {
    $("#alignment_table").empty();
    $.each(alignmentData.sequences, function(i, sequence) {
      var rowHtml = "<tr><td id='seq_color_" + sequence.row + "'>&nbsp;</td><td class='seq_name'>" + sequence.name + "</td>";
      $.each(sequence.seq.split(''), function(j, character) {
        var column = j + 1;
        if (!showText) character = "&nbsp;";
        rowHtml += "<td id='cell_" + sequence.row + "_" + column + "'>" + character + "</td>";
      });
      rowHtml += "</tr>";
      $("#alignment_table").append(rowHtml);
    });
  }
  else if (alignmentData.status == DataStatus.Pending) {
    $("#alignment_table").html("<tr><td>Loading...</td></tr>");
    setTimeout("refreshDisplay()", 1000);
  }
  else {
    $("#alignment_table").html("<tr><td>Error</td></tr>");
  }
}

function drawAlignmentColors() {
  $.each(alignmentData.colors, function(column, columnColors) {
    if (columnColors != null) {
      $.each(columnColors, function(row, cellColor) {
        $("#cell_" + row + "_" + column).css("background-color", cellColor);
      });
    }
  });
  $.each(alignmentData.sequences, function(i, sequence) {
    $("#seq_color_" + sequence.row).css("background-color", sequence.color);
  });
}

function toggleAlignmentText() {
  showText = !showText;
  refreshDisplay();
}

function urlParam(name) {
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS  = "[\\?&]" + name + "=([^&#]*)";
  var regex   = new RegExp( regexS );
  var results = regex.exec( window.location.href );
  return results ? results[1] : "";
}