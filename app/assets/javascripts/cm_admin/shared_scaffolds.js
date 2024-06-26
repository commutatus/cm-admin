// This file is shared between rails 6 and 7 version

$(document).on(
  "keypress keyup blur",
  "[data-behaviour='decimal-only'], [data-behaviour='filter'][data-filter-type='range']",
  function (e) {
    var charCode = e.which ? e.which : e.keyCode;
    if (charCode > 31 && charCode != 46 && (charCode < 48 || charCode > 57))
      return false;
    return true;
  }
);

$(document).on(
  "keypress keyup blur",
  "[data-behaviour='integer-only']",
  function (event) {
    $(this).val(
      $(this)
        .val()
        .replace(/[^\d].+/, "")
    );
    if (event.which < 48 || event.which > 57) {
      event.preventDefault();
    }
  }
);

$(document).on("click", ".row-action-cell", function (e) {
  e.stopPropagation();
  if ($(this).find(".table-export-popup").hasClass("hidden")) {
    return $(this).find(".table-export-popup").removeClass("hidden");
  } else {
    return $(this).find(".table-export-popup").addClass("hidden");
  }
});

$(document).on("mouseleave", ".row-action-cell", function () {
  $(this).find(".table-export-popup").addClass("hidden");
});

$(document).on("click", ".drawer-btn", function (e) {
  e.stopPropagation();
  var drawer_el = $(this).parent().closest(".drawer").find(".cm-drawer");
  if (drawer_el.hasClass("hidden")) {
    drawer_el.removeClass("hidden");
    drawer_container = drawer_el.find(".drawer-container");
    if (drawer_container.hasClass("drawer-slide-out")) {
      drawer_container.removeClass("drawer-slide-out");
    }
    drawer_container.addClass("drawer-slide-in");
  } else {
    return drawer_el.addClass("hidden");
  }
});

$(document).on("click", ".drawer-close", function (e) {
  e.stopPropagation();
  $(".drawer-container").removeClass("drawer-slide-in");
  $(".drawer-container").addClass("drawer-slide-out");
  setTimeout(() => {
    $(".cm-drawer").addClass("hidden");
  }, 300);
});

$(document).on("change", '[data-field-type="linked-field"]', function (e) {
  e.stopPropagation();
  var params = {};
  params[$(this).data("field-name")] = $(this).val();
  var request_url = $(this).data("target-url") + "?" + $.param(params);
  console.log(request_url);
  $.ajax(request_url, {
    type: "GET",
    success: function (data) {
      apply_response_to_field(data);
    },
    error: function (jqxhr, textStatus, errorThrown) {
      alert("Something went wrong. Please try again later.\n" + errorThrown);
    },
  });
});

function apply_response_to_field(response) {
  $.each(response["fields"], function (key, value) {
    switch (value["target_type"]) {
      case "select":
        update_options_in_select(value["target_value"]);
        break;
      case "input":
        update_options_input_value(value["target_value"]);
        break;
      case "toggle_visibility":
        toggle_field_visibility(value["target_value"]);
    }
  });
}

function update_options_input_value(field_obj) {
  var input_tag = $("#" + field_obj["table"] + "_" + field_obj["field_name"]);
  input_tag.val(field_obj["field_value"]);
}

function update_options_in_select(field_obj) {
  var select_tag = $("#" + field_obj["table"] + "_" + field_obj["field_name"]);
  select_tag.empty();
  $.each(field_obj["field_value"], function (key, value) {
    select_tag.append(
      $("<option></option>").attr("value", value[1]).text(value[0])
    );
  });
}

function toggle_field_visibility(field_obj) {
  var element = $("#" + field_obj["table"] + "_" + field_obj["field_name"]);
  element.closest(".form-field").toggleClass("hidden");
}

$(document).on("cocoon:after-insert", ".nested-field-wrapper", function (e) {
  e.stopPropagation();
  replaceAccordionTitle($(this));
});

$(document).on("cocoon:after-remove", ".nested-field-wrapper", function (e) {
  e.stopPropagation();
  replaceAccordionTitle($(this));
});

$(document).ready(function () {
  $(".nested-field-wrapper").each(function () {
    replaceAccordionTitle($(this));
  });
});

var replaceAccordionTitle = function (element) {
  var i = 0;
  var table_name = $(element).data("table-name");
  var model_name = $(element).data("model-name");
  $(element)
    .find("[data-card-name='" + table_name + "']")
    .each(function () {
      i++;
      var accordion_title = model_name + " " + i;
      var accordion_id = table_name + "-" + i;
      $(this).find(".card-title").text(accordion_title);
      $(this)
        .find(".card-title")
        .attr("data-bs-target", "#" + accordion_id);
      $(this).find(".accordion-collapse").attr("id", accordion_id);
    });
};
