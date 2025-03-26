<template>
    <v-card v-if="protocol.isDraft">
        <v-card-title class="text-h5 text-center">
            {{ t('sessions.editProtocolTitle') }}
        </v-card-title>
        <v-card-text>
            <RichText v-model="protocol.content" />
        </v-card-text>
        <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn text @click="BtnClickHandler(true)"> {{ t('common.save') }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('common.saveTooltip')}}
                </v-tooltip>
            </v-btn>
            <v-btn class="cancel" text @click="BtnClickHandler(false)">{{ t('common.cancel') }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('inventories.buttons.cancelTooltip')}}
                </v-tooltip>
            </v-btn>
        </v-card-actions>
    </v-card>
    <v-card-title v-if="!protocol.isDraft" class="text-h5 text-center">
        {{ t('sessions.cantEditProtocol') }}
    </v-card-title>
</template>
<script lang="ts">
import { defineComponent, ref, onMounted, inject, Ref } from 'vue';
import RichText from '@/components/tinyMCE/tinyMCE.vue';
import commissionSessionService from '@/services/commissionSession.service';
import { useI18n } from 'vue-i18n';
import router from '@/router';
import { ResponseResult } from '@/models/responseResult';
import { Message } from '@/models/notification';
import { IMessage } from '@/interfaces/notification';
import { SessionProtocol } from '@/models/protocol';
export default defineComponent({
    name: 'EditProtocol',
    components: {
        RichText,
    },

    props: {
        id: {
            type: Number,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const protocol = ref<SessionProtocol>(new SessionProtocol());

        const getProtocolContent = async () => {
            const response = await commissionSessionService.getSessionProtocolContent(props.id!);
            protocol.value = response;
        };
        const editSessionProtocol = async () => {
            protocol.value.id = props.id;
            protocol.value.isDraft = true;
            protocol.value.content = await commissionSessionService.editSessionProtocol(protocol.value);
        };

        const BtnClickHandler = (confirmed: boolean) => {
            if (confirmed) {
                try {
                    editSessionProtocol();
                    message.value = new Message({
                        text: t('deduction.mess.succ'),
                        display: true,
                        type: 'success',
                        timeout: 5000,
                    });
                    router.go(-1);
                } catch (error: unknown) {
                    const errorResult = error as ResponseResult;
                    message.value = new Message({
                        text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                }
            } else {
                router.go(-1);
            }
        };

        onMounted(async () => {
            await getProtocolContent();
        });

        return {
            t,
            BtnClickHandler,
            protocol,
        };
    },
});
</script>

<style lang="scss" scoped>

//@import "@/assets/styles/display-create-edit.scss"
@use "@/assets/styles/common.scss" as *;


// :deep(button) {
//     @include button();
//     margin: 50px 15px 15px 15px;
// }

// :deep(button.cancel) {
//     @include button($background: var(--ISDA-main-color1))
// }

button {
    color: white !important;
    background-color: var(--ISDA-main-color4);
    border: none;
    border-radius: 6px;
    box-shadow: gray 0px 1px 3px 0px;
    height: 40px !important;    
}

.cancel {
    background-color: var(--ISDA-main-color1);
}

</style>