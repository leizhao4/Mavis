var alignmentID   = urlParam("id");
var showText      = false;
var DataStatus    = { "Ready" : 1, "Pending" : 0, "Error" : 2 };
var alignmentData = { "id" : alignmentID, "status" : DataStatus.Pending, "sequences" : [], "colors" : [] };

$(document).ready(function() {
  getAlignmentData(alignmentID);
  drawAlignmentLayout();
  drawAlignmentTable();
  drawAlignmentList();
});

function apiUrl(alignmentID, action) {
  var URL = "api.pl?id=" + alignmentID;
  if (action) URL = URL + "&action=" + action;
  return URL;
}

function getAlignmentData(alignmentID) {
  $.getJSON(apiUrl(alignmentID), function(alignment) { alignmentData = alignment; refreshDisplay(); });
}

function refreshDisplay() {
  drawAlignmentLayout();
  drawAlignmentTable();
  drawAlignmentColors();
}

function drawAlignmentLayout(title) {
  if (!title || title.length < 1)
    title = "Multiple Sequence Alignment Visualization" + (alignmentID.length > 0 ? " (ID: " + alignmentID + ")" : "");
  $("#alignment_container").html("<div id='alignment_header'>" + title + "</div>");
  $("#alignment_container").append("<a href='#' class='button' onclick='toggleAlignmentText()'>Show/Hide Sequence Text</a>");
  $("#alignment_container").append("<table id='alignment_table' cellspacing='0'></table>");
  $("#alignment_container").append("<div id='alignment_footer'>" + localtime() + "</div>");
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
    setTimeout("getAlignmentData(alignmentID)", 3000);
  }
  else {
    $("#alignment_table").html("<tr><td>Error!</td></tr>");
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

function drawAlignmentList() {
  $("#alignment_list").html("Other Alignments: ");
  $.getJSON(apiUrl(alignmentID, "list"), function(list) {
    $.each(list, function(i, aID) {
      $("#alignment_list").append("<li><a href='?id=" + aID + "'>" + aID + "</a></li>");
    });
  });
}

function toggleAlignmentText() {
  showText = !showText;
  refreshDisplay();
}

function urlParam(name) {
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regex   = new RegExp("[\\?&]" + name + "=([^&#]*)");
  var results = regex.exec(window.location.href);
  return results ? results[1] : "";
}

function localtime() {
  return new Date().toLocaleString();
}