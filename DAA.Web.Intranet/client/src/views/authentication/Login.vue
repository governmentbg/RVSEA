<template>
    <v-card title="Login" class="col-12 col-md-9 col-lg-6 ma-auto">
        <Form @submit="onSubmit">
            <v-container>
                <v-row>
                    <v-col>
                        <text-field
                            name="fldEmail"
                            :label="t('login.email')"
                            v-model="model.email"
                            validation="required|email"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col>
                        <text-field
                            name="fldPassword"
                            :label="t('login.password')"
                            v-model="model.password"
                            type="password"
                            :validation="'required'"
                        />
                    </v-col>
                </v-row>
                <v-row>
                    <v-col>
                        <v-btn type="submit">{{ t('login.submit') }}</v-btn>
                    </v-col>
                </v-row>
            </v-container>
        </Form>
    </v-card>
</template>
<script lang="ts">
import { LoginModel } from '@/models/authentication'
import authenticationService from '@/services/authentication.service'
import { defineComponent, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute, useRouter } from 'vue-router'

import TextField from '@/components/field/text.field.vue'
import { Form } from 'vee-validate'
// import { NotificationsHubModel } from '@/models/notification'
import { useStore } from '@/store/user'

export default defineComponent({
    name: 'Login',
    components: {
        Form,
        TextField,
    },
    setup() {
        const { t } = useI18n()
        // const notificationsHub = inject('notificationsHub') as NotificationsHubModel
        const userStore = useStore()

        const router = useRouter()
        const route = useRoute()

        const model = ref(new LoginModel())

        const onSubmit = async () => {
            try {
                await authenticationService.login(model.value)

                // try {
                //     notificationsHub.establishConnection(userStore.getters.token)
                // } catch (e) {
                //     console.log(e)
                // }

                const redirect = route.query.redirect?.toString()

                router.push(redirect || { name: 'Home' })
            } catch (error: unknown) {
                console.error(error)
            }
        }

        return {
            t,
            model,
            onSubmit,
            // notificationsHub,
            userStore,
        }
    },
})
</script>

<style lang="scss" scoped>

@import "@/assets/styles/display-create-edit.scss";

.v-card {
    box-shadow: gray 0px 0px 20px 0px;
}

:deep(.v-field__overlay) {
    background-color: var(--ISDA-main-color4) !important;
    opacity: 10% !important;
}

</style>