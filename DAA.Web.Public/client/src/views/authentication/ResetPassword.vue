<template>
  <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
    <v-card-title class="v-card-title-uppercase">{{
      t("password.resetPassword")
    }}</v-card-title>

    <Form @submit="onSubmit">
      <v-container>
        <v-row>
          <v-col class="col-12">
            <text-field
              name="fldEmail"
              :label="t('password.columns.email')"
              type="email"
              v-model="email"
              validation="required|email"
            />
          </v-col>
        </v-row>
        <v-row>
          <v-col class="col-12 d-flex justify-content-center">
            <v-btn class="btn" type="submit">{{ t("common.send") }}</v-btn>
          </v-col>
        </v-row>
      </v-container>
    </Form>
  </v-card>
</template>
<script lang="ts">
import { defineComponent, inject, ref, Ref } from "vue";
import { useI18n } from "vue-i18n";
import { Message } from "@/models/notification";
import authenticationService from "@/services/authentication.service";
import { Form } from "vee-validate";
import TextField from "@/components/field/text.field.vue";
import { IMessage } from "../../interfaces/notification";
import { ResponseResult } from "../../models/responseResult";

export default defineComponent({
  name: "ResetPassword",
  components: {
    Form,
    TextField,
  },
  setup() {
    const { t } = useI18n();

    const message = inject("notificationMessage") as Ref<IMessage>;

    const email = ref("");

    const onSubmit = async () => {
      try {
        await authenticationService.resetPassword(email.value);

        message.value = new Message({
          title: t('registration.buttons.successResultTitle'),
          text: t('registration.buttons.successResultMessage'),
          type: 'success',
          display: true,
          timeout: 5000,
        });

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

    return {
      t,
      email,
      onSubmit,
    };
  },
});
</script>

<style lang="scss" scoped>

@import "@/assets/styles/display-create-edit.scss";


.v-card {
  margin-top: 50px !important;
  border-radius: 6px;
  box-shadow: gray 0px 0px 3px 0px;
  background-color: var(--ISDA-main-color2-1);
}

</style>
