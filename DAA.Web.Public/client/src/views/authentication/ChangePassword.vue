<template>
  <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
    <v-card-title class="v-card-title-uppercase">{{
      t("registration.title")
    }}</v-card-title>

    <Form @submit="onSubmit">
      <v-container>
        <v-row>
          <v-col class="col-12 col-lg-6">
            <text-field
              name="fldPassword"
              :label="t('registration.password')"
              v-model="model.password"
              type="password"
              :validation="'required'"
            />
          </v-col>
          <v-col class="col-12 col-lg-6">
            <text-field
              name="fldPasswordConfirmation"
              :label="t('registration.passwordConfirmation')"
              v-model="model.passwordConfirmation"
              type="password"
              :validation="'required|confirmed:@fldPassword'"
            />
          </v-col>
        </v-row>
        <v-row>
          <v-col class="col-12 d-flex justify-content-center">
            <v-btn class="btn" type="submit">{{
              t("registration.buttons.submit")
            }}</v-btn>
          </v-col>
        </v-row>
      </v-container>
    </Form>
  </v-card>
</template>
<script lang="ts">
import { defineComponent, inject, Ref } from "vue";
import { useI18n } from "vue-i18n";
import { useRouter } from "vue-router";
import { useRedirect } from "@/helpers/router.helper";
import { ResponseResult } from "../../models/responseResult";
import { Message } from "@/models/notification";
import { PasswordModel } from "@/models/authentication";
import authenticationService from "@/services/authentication.service";
import { IMessage } from "../../interfaces/notification";

export default defineComponent({
  name: "ChangePassword",
  props: {
    userId: {
      type: String,
    },
  },
  setup() {
    const { t } = useI18n();

    const message = inject("notificationMessage") as Ref<IMessage>;

    const router = useRouter();

    const submitConfirmation = async () => {
      try {
        await authenticationService.changePassword(new PasswordModel());

        message.value = new Message({
          type: "success",
          text: t("registration.accountConfirmationSuccess"),
          display: true,
        });

        useRedirect(router, "Login");
      } catch (error: unknown) {
        const errorResult  = error as ResponseResult;
        message.value = new Message({
          text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
          display: true,
        });
      }
    };
    return { t, submitConfirmation };
  },
});
</script>

<style lang="scss" scoped>

@import "@/assets/styles/display-create-edit.scss"

</style>