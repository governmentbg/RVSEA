<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <div id="underBreadcrumbs">
        <v-card-title>{{ t('navigation.left.passportization') }}</v-card-title>
        <v-row class="ma-auto">
            <v-btn @click="getInfo(ProcessKind.Kmf)">{{ t('pasportization.kmfButton') }}</v-btn>
            <v-btn @click="getInfo(ProcessKind.Fund)">{{ t('pasportization.documentButton') }}</v-btn></v-row
        >
        <Loader :isLoading="isLoading" />
    </div>
    <v-card v-if="filesStatusInfo.items" class="ma-auto p-3">
        <v-card-title>{{ title }}</v-card-title>
        <v-card-text>
            <v-container>
                <v-row>
                    <v-col class="col-8">
                        <div>
                            <span class="text-decoration"
                                ><b>{{ t('filmDocuments.fileName') }}</b></span
                            >
                        </div>
                    </v-col>
                    <v-col class="col-4">
                        <div>
                            <span class="text-start"
                                ><b>{{ t('funds.columns.status') }}</b></span
                            >
                        </div>
                    </v-col>
                </v-row>
                <v-row v-for="(file, index) in filesStatusInfo.items" :key="index">
                    <v-col class="col-8">
                        <span class="text-start">{{ file.fileName }}</span>
                    </v-col>
                    <v-col v-if="file.success === false" class="col-4 conten-center">
                        <i class="fa fa-times-circle text-danger" aria-hidden="true"></i>
                    </v-col>
                    <v-col v-if="file.success === null" class="col-4 conten-center">
                        <i class="fa fa-times-circle text-main" aria-hidden="true"></i>
                    </v-col>
                    <v-col v-else-if="file.success === true" class="col-4 conten-center">
                        <span><i class="fa fa-check-circle text-success" aria-hidden="true"></i></span>
                    </v-col>
                </v-row>
                <v-row class="mt-3">
                    <v-col>
                        <div>
                            <b>
                                <span class="text-bold"> {{ filesStatusInfo.summary }}</span></b
                            >
                        </div>
                    </v-col>
                </v-row>
            </v-container>
        </v-card-text>
    </v-card>
</template>

<script lang="ts">
import { defineComponent, ref, inject, Ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { IMessage } from '@/interfaces/notification';
import { Message } from '@/models/notification';
import { ChecksumVerifyProcessModel } from '@/models/checksumsVerifyResultModel ';
import fileUploadAppService from '@/services/fileUploadApp.service';
import { ProcessKind } from '@/enums/processKind';
import { useStore } from '@/store/user';
import router from '@/router';
import { useRedirect } from '@/helpers/router.helper';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';
import Loader from '@/components/loader/loader.vue';

export default defineComponent({
    name: 'FilesInfoModal',
    components: { Breadcrumbs, Loader },
    setup() {
        const { t } = useI18n();
        const userStore = useStore();
        const message = inject('notificationMessage') as Ref<IMessage>;
        const filesStatusInfo = ref<ChecksumVerifyProcessModel>(new ChecksumVerifyProcessModel());
        const isLoading = ref(false);
        const title = ref('');
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },

            {
                title: t('navigation.left.passportization'),
                disabled: true,
            },
        ];
        const getInfo = async (aa: ProcessKind) => {
            isLoading.value = true;
            fileUploadAppService
                .verifyChecksums(aa)
                .then((resolve) => {
                    if (resolve.processes) filesStatusInfo.value = resolve.processes[0];
                    isLoading.value = false;
                    if (filesStatusInfo.value.processName == 'КМФ') {
                        title.value = t('pasportization.kmfButton');
                    } else {
                        title.value = t('pasportization.documentButton');
                    }
                })
                .catch((reject: Error) => {
                    const errorResult = reject as Error;
                    message.value = new Message({
                        text: errorResult.message ? errorResult.message : t('error.basic'),
                        display: true,
                    });
                });
        };
        function checkAdmin() {
            const isAdmin = userStore.getters.isAdmin;
            if (isAdmin == false) {
                useRedirect(router, 'AccessDenied');
            }
        }
        onMounted(() => {
            checkAdmin();
        });
        return {
            t,
            getInfo,
            filesStatusInfo,
            title,
            breadcrumbItems,
            isLoading,
            ProcessKind,
        };
    },
});
</script>

<style scoped lang="scss">
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/dialog.scss';
@import '@/assets/styles/breadcrumbs.scss';

:deep(.v-card-title),
:deep(h3) {
    box-shadow: none !important;
}

#underBreadcrumbs {
    margin-top: 50px !important;
}

</style>
