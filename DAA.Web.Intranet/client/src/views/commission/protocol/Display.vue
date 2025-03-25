<template>
    <v-container>
        <v-row class="col-12 d-print-none">
            <v-col cols="6">
                <v-menu class="d-print-none">
                    <template v-slot:activator="{ props }">
                        <v-btn v-bind="props">{{ t('common.exportTo') }}</v-btn>
                    </template>
                    <v-list>
                        <v-list-item class="col-12 cursor">
                            <v-list-item-title class="d-print-none button" @click="exportHTMLtoWord"
                                >{{ t('common.exportToWord') }}
                            </v-list-item-title>
                        </v-list-item>
                        <v-list-item class="col-12 cursor">
                            <v-list-item-title class="d-print-none button" @click="printButton"
                                >{{ t('common.exportToPdf') }}
                            </v-list-item-title></v-list-item
                        >
                    </v-list>
                </v-menu>
            </v-col>
            <v-col>
                <v-btn class="d-print-none cancel" style="float: right" @click="goBack"
                    >{{ t('common.back') }}
                    <v-tooltip activator="parent" location="bottom">
                        {{ t('common.back') }}
                    </v-tooltip>
                </v-btn>
            </v-col>
        </v-row>
        <div v-html="protocol.content"></div>
    </v-container>
</template>
<script lang="ts">
import { defineComponent, ref, onBeforeMount } from 'vue';
import commissionSessionService from '@/services/commissionSession.service';
import { useI18n } from 'vue-i18n';
import { SessionProtocol } from '@/models/protocol';
import router from '@/router';
import { returnWordFromHtml } from '@/helpers/word.helper';
export default defineComponent({
    name: 'ViewProtocol',
    props: {
        id: {
            type: Number,
        },
    },
    setup(props) {
        const { t } = useI18n();
        const protocol = ref<SessionProtocol>(new SessionProtocol());

        const getProtocolContent = async () => {
            protocol.value = await commissionSessionService.getSessionProtocolContent(props.id as number);
            console.log(protocol.value);
        };
        const goBack = () => {
            router.go(-1);
        };
        const printButton = () => {
            window.print();
        };
        const exportHTMLtoWord = () => {
            returnWordFromHtml(protocol.value.content as string);
        };

        onBeforeMount(() => {
            getProtocolContent();
        });

        return {
            t,
            printButton,
            exportHTMLtoWord,
            goBack,
            protocol,
        };
    },
});
</script>

<style lang="scss" scoped>
@use '@/assets/styles/common.scss' as *;

// .v-btn {
//     @include button;
//     margin: 5px 50px;
// }

// .v-btn.cancel {
//     @include button(var(--ISDA-main-color4), var(--ISDA-main-color1));
// }

.html-content {
    padding: 5px 30px;
    margin: 5px 50px;
    background-color: rgb(255, 249, 237);
}

.cursor {
    cursor: pointer;
}
</style>
