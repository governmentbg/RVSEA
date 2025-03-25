<template>
  <span></span>
</template>
<script lang="ts">
import { defineComponent, inject, onMounted, Ref } from "vue";
import { useI18n } from "vue-i18n";
import { useRouter } from "vue-router";
import { Message } from "@/models/notification";
import { ConfirmationModel } from "@/models/authentication";
import authenticationService from "@/services/authentication.service";
import { useRedirect } from "@/helpers/router.helper";
import { IMessage } from "../../interfaces/notification";
import { ResponseResult } from "../../models/responseResult";

export default defineComponent({
  name: "AccountConfirmation",
  props: {
    userId: {
      type: String,
    },
    confirmationToken: {
      type: String,
    },
  },
  setup(props) {
    const { t } = useI18n();

    const message = inject("notificationMessage") as Ref<IMessage>;

    const router = useRouter();

    const submitConfirmation = async () => {
      try {
        await authenticationService.confirm(
          new ConfirmationModel({
            userId: props.userId,
            confirmationToken: props.confirmationToken,
          })
        );

        message.value = new Message({
          type: "success",
          text: t("registration.accountConfirmationSuccess"),
          display: true,
        });

        useRedirect(router, "Login");
      } catch (error: unknown) {
        const errorResult = error as ResponseResult;
        const text = t("registration.errors." + errorResult.message);
        // Проверка дали е някакъв код, който го няма в текстовете
        if (text.indexOf("registration.errors.") >= 0) {
          message.value = new Message({
            text: t('error.basic'),
            display: true,
          });
        } else {
          message.value = new Message({
            text: errorResult.showMessage ? t("registration.errors." + errorResult.message) : t('error.basic'),
            display: true,
          });
        }
      }
    };

    onMounted(submitConfirmation);

    return {
      t,
    };
  },
});
</script>

<style lang="scss" scoped>

@import "@/assets/styles/display-create-edit.scss"

</style>