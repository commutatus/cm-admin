import * as bootstrap from "bootstrap";
window.bootstrap = bootstrap;

document.addEventListener("turbo:load", function () {
  $('[data-action="fetch-modal"]').on("click", function (e) {
    const actionName = $(this).attr("data-action_name");
    const modelName = $(this).attr("data-model_name");
    const recordId = $(this).attr("data-record_id");
    const modalContainer = $(
      "[data-behaviour='custom-action-modal-container']"
    );
    const routeMount = document.location.href.split("/")[3];

    if (!actionName || !modelName || !recordId || !modalContainer) return;
    $.ajax({
      url: `/${routeMount}/${modelName}/${recordId}/custom_action_modal/${actionName}`,
      method: "GET",
      success: function (response) {
        modalContainer.html(response);
        const actionModal = new bootstrap.Modal(
          modalContainer.children().first()
        );
        actionModal.show();
      },
      error: function (error) {
        console.error("Error:", error);
      },
    });
  });
});
