<template>
  <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
    <v-card-title class="v-card-title-uppercase">{{
      t("registration.titles.completeRegistration")
    }}</v-card-title>

    <Form @submit="onSubmit">
      <v-container>
        <v-tabs v-model="registrationProfile" right>
          <v-tab :value="profileType.CardHolder">{{
            t("registration.cardHolder")
          }}</v-tab>
          <v-tab :value="profileType.FundCreator">{{
            t("registration.fundCreator")
          }}</v-tab>
        </v-tabs>
        <v-window v-model="registrationProfile">
          <v-window-item :value="profileType.CardHolder">
            <v-row class="mt-3">
              <v-col class="col-12 col-lg-4">
                <text-field
                  name="fldFirstName"
                  :label="t('registration.columns.firstName')"
                  v-model="model.firstName"
                  validation="required"
                />
              </v-col>
              <v-col class="col-12 col-lg-4">
                <text-field
                  name="fldSurname"
                  :label="t('registration.columns.surname')"
                  v-model="model.surname"
                />
              </v-col>
              <v-col class="col-12 col-lg-4">
                <text-field
                  name="fldLastName"
                  :label="t('registration.columns.lastName')"
                  v-model="model.lastName"
                  validation="required"
                />
              </v-col>
            </v-row>
            <v-row>
              <v-col class="col-12">
                <text-field
                  name="fldLibraryCardNumber"
                  :label="t('registration.columns.libraryCardNumber')"
                  v-model="model.libraryCardNumber"
                  :validation="
                    registrationProfile == profileType.CardHolder
                      ? 'required'
                      : ''
                  "
                />
              </v-col>
            </v-row>
          </v-window-item>
          <v-window-item :value="profileType.FundCreator">
            <v-row class="mt-3">
              <v-col class="col-12">
                <v-radio-group v-model="model.profileEntityType" inline>
                  <v-radio
                    :label="t('registration.individual')"
                    :value="profileEntityType.Individual"
                  ></v-radio>
                  <v-radio
                    :label="t('registration.legalEntity')"
                    :value="profileEntityType.LegalEntity"
                  ></v-radio>
                </v-radio-group>
              </v-col>
            </v-row>
            <v-row>
              <v-col class="col-12 col-lg-4">
                <text-field
                  name="fldFirstName"
                  :label="t('registration.columns.firstName')"
                  v-model="model.firstName"
                  validation="required"
                />
              </v-col>
              <v-col class="col-12 col-lg-4">
                <text-field
                  name="fldSurname"
                  :label="t('registration.columns.surname')"
                  v-model="model.surname"
                />
              </v-col>
              <v-col class="col-12 col-lg-4">
                <text-field
                  name="fldLastName"
                  :label="t('registration.columns.lastName')"
                  v-model="model.lastName"
                  validation="required"
                />
              </v-col>
            </v-row>
            <v-row>
              <v-col class="col-12">
                <text-field
                  v-if="
                    model.profileEntityType == profileEntityType.LegalEntity
                  "
                  name="fldOrganization"
                  :label="t('registration.columns.organization')"
                  v-model="model.organization"
                  validation="required"
                />
              </v-col>
            </v-row>
            <v-row>
              <v-col class="col-12 col-lg-6">
                <text-field
                  v-if="
                    model.profileEntityType == profileEntityType.LegalEntity
                  "
                  name="fldDepartment"
                  :label="t('registration.columns.department')"
                  v-model="model.department"
                  validation="required"
                />
              </v-col>
              <v-col class="col-12 col-lg-6">
                <text-field
                  v-if="
                    model.profileEntityType == profileEntityType.LegalEntity
                  "
                  name="fldJobTitle"
                  :label="t('registration.columns.jobTitle')"
                  v-model="model.jobTitle"
                  validation="required"
                />
              </v-col>
            </v-row>
            <v-row>
              <v-col class="col-12">
                <text-field
                  name="fldAddress"
                  :label="t('registration.columns.address')"
                  v-model="model.address"
                  validation="required"
                />
              </v-col>
            </v-row>
          </v-window-item>
        </v-window>
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
import { computed, defineComponent, inject, onMounted, ref, Ref } from "vue";
import { useI18n } from "vue-i18n";
import { useRouter } from "vue-router";
import { useRedirect } from "@/helpers/router.helper";
import { useStore } from "@/store/user";
import { UserProfileModel } from "@/models/profile";
import { ProfileType, ProfileEntityType } from "@/enums/profile";
import { Message } from "@/models/notification";
import { ResponseResult } from "../../models/responseResult";
import TextField from "@/components/field/text.field.vue";
import { Form } from "vee-validate";
import authenticationService from "@/services/authentication.service";
import { IMessage } from "../../interfaces/notification";

export default defineComponent({
  name: "CompleteRegistration",
  components: {
    Form,
    TextField,
  },
  setup() {
    const { t } = useI18n();

    const router = useRouter();

    const registrationProfile = ref(null);
    const model = ref(new UserProfileModel());
    const profileType = computed(() => ProfileType);
    const profileEntityType = computed(() => ProfileEntityType);

    const message = inject("notificationMessage") as Ref<IMessage>;

    const userStore = useStore();
    const fillExistingData = () => {
      model.value.userId = userStore.getters.userId;
      const names = userStore.getters.fullName.split(" ");
      model.value.firstName = names[0];
      model.value.surname = names.length === 3 ? names[1] : "";
      model.value.lastName = names.length === 3 ? names[2] : names[1];
    };

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const onSubmit = async (values: any, formActions: any) => {
      console.log("values", values);
      console.log("resetForm", formActions);

      try {
        if (registrationProfile.value) {
          model.value.profileType = registrationProfile.value;
        }

        await authenticationService.setProfile(model.value);

        message.value = new Message({
          text: t("registration.buttons.successCompleteResultMessage"),
          type: "success",
          display: true,
        });

        useRedirect(router, "Home");
      } catch (error: unknown) {
        const errorResult = error as ResponseResult;
        console.log(error);
        message.value = new Message({
          text: t("registration.errors." + errorResult.message),
          display: true,
        });
      }
    };

    onMounted(fillExistingData);

    return {
      t,
      registrationProfile,
      model,
      profileType,
      profileEntityType,
      message,
      onSubmit,
    };
  },
});
</script>

<style lang="scss" scoped>

@import "@/assets/styles/display-create-edit.scss";

.v-slide-group {
    height: 80px;
}

.v-tab {
    background-color: var(--ISDA-main-color2-1);
    color: var(--ISDA-main-color-1) !important;
    box-shadow: none;
}

</style>