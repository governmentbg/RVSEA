<template>
  <v-card class="col-12 col-md-6 col-lg-6 ma-auto">
    <v-card-title class="v-card-title-uppercase">{{
      t("password.resetPassword")
    }}</v-card-title>

    <Form @submit="submitConfirmation">
      <v-container>
        <v-row>
          <v-col class="col-12">
            <text-field
              name="fldPassword"
              :label="t('password.columns.password')"
              v-model="model.password"
              type="password"
              :validation="'required'"
            />
          </v-col>
        </v-row>
        <v-row>
          <v-col class="col-12">
            <text-field
              name="fldPasswordConfirmation"
              :label="t('password.columns.passwordConfirmation')"
              v-model="model.passwordConfirmation"
              type="password"
              :validation="'required|confirmed:@fldPassword'"
            />
          </v-col>
        </v-row>
        <v-row>
          <v-col class="col-12 d-flex justify-content-center">
            <v-btn class="btn" type="submit">{{ t("common.save") }}</v-btn>
          </v-col>
        </v-row>
      </v-container>
    </Form>
  </v-card>
</template>
<script lang="ts">
import { defineComponent, inject, ref, Ref } from "vue";
import { useI18n } from "vue-i18n";
import { useRouter } from "vue-router";
import { useRedirect } from "@/helpers/router.helper";
import { Message } from "@/models/notification";
import { PasswordModel } from "@/models/authentication";
import authenticationService from "@/services/authentication.service";
import { ResponseResult } from "../../models/responseResult";
import { Form } from "vee-validate";
import TextField from "@/components/field/text.field.vue";
import { IMessage } from "../../interfaces/notification";

export default defineComponent({
  name: "SetPassword",
  components: {
    Form,
    TextField,
  },
  props: {
    userId: {
      type: String,
    },
    passwordToken: {
      type: String,
    },
  },
  setup(props) {
    const { t } = useI18n();

    const message = inject("notificationMessage") as Ref<IMessage>;

    const model = ref(new PasswordModel());

    const router = useRouter();

    const submitConfirmation = async () => {
      try {
        model.value.userId = props.userId;
        model.value.passwordToken = props.passwordToken;
        await authenticationService.setPassword(model.value);

        message.value = new Message({
          type: "success",
          text: t("password.buttons.savePasswordSuccessResult"),
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

    return {
      t,
      model,
      submitConfirmation,
    };
  },
});
</script>

<style lang="scss" scoped>

@import "@/assets/styles/display-create-edit.scss"

</style>
