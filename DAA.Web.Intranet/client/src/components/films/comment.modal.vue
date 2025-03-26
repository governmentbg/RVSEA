<template>
  <div
    ref="commentElement"
    class="modal fade"
    data-bs-backdrop="false"
    data-bs-keyboard="false"
  >
    <div class="modal-dialog modal-dialog-centered modal-lg">
      <div class="modal-content">
        <VForm ref="commentForm" @submit="submitModal">
          <div class="modal-header">
            <h3>{{ t("films.columns.comment") }}</h3>
            <button
              type="button"
              class="btn-close"
              @click="closeModal"
            ></button>
          </div>
          <div class="modal-body">
            <v-row>
              <v-col class="col-12">
                <text-area-field
                  name="fldComment"
                  :label="t('films.columns.comment')"
                  v-model="model"
                  validation="required"
                  class="form-control"
                />
              </v-col>
            </v-row>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-main" @click="submitModal">
              {{ t("common.save") }}
            </button>
            <button type="button" class="btn btn-outline-main cancel" @click="closeModal">
              {{ t("common.cancel") }}
            </button>
          </div>
        </VForm>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, watch } from "vue";
import { useI18n } from "vue-i18n";
import { Form as VForm } from "vee-validate";
import { Modal } from "bootstrap";
import TextAreaField from "@/components/field/textarea.field.vue";

export default defineComponent({
  name: "CommentModal",
  components: {
    VForm,
    TextAreaField,
  },
  props: {
    visible: {
      type: Boolean,
      default: false,
    },
    isForCard: {
      type: Boolean,
      default: false,
    },
    isForAll: {
      type: Boolean,
      default: false,
    },
  },
  setup(props, context) {
    const { t } = useI18n();

    const model = ref("");
    const commentElement = ref();
    const commentModal = ref<Modal>();

    const commentForm = ref();
    const showModal = () => {
      (commentForm.value! as typeof VForm).reset();
      commentModal.value?.show();
      context.emit("showModal");
    };
    const closeModal = () => {
      context.emit("closeModal");
      commentModal.value?.hide();
    };

    const submitModal = async () => {
      if (!model.value) {
        return;
      }

      if (props.isForCard == true) {
        context.emit("submitCardModal", model.value);
      }
      else if (props.isForAll == true) {
        context.emit("submitAllModal", model.value);
      }
      else {
        context.emit("submitModal", model.value);
      }
      commentModal.value?.hide();
    };

    onMounted(() => {
      commentModal.value = new Modal((commentElement.value as Element)!, {
        keyboard: false,
        backdrop: false,
      });
    });

    watch(
      () => props.visible,
      (value: boolean) => {
        if (value) {
          showModal();
        } else {
          closeModal();
        }
      }
    );

    return {
      t,
      commentElement,
      commentModal,
      model,
      closeModal,
      submitModal,
      commentForm,
    };
  },
});
</script>
