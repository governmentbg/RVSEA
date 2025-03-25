<template>
    <Breadcrumbs :items="breadcrumbItems" />
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <FundCreateForm @created="goBack" @cancel="goBack" :type="type"></FundCreateForm>
    </v-card>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import { useRouter } from 'vue-router';
import { useRedirect } from '@/helpers/router.helper';
import FundCreateForm from '@/components/fund/create.vue';
import { useI18n } from 'vue-i18n';
import Breadcrumbs from '@/components/breadcrumbs/breadcrumbs.vue';

export default defineComponent({
    name: 'CreateFund',
    components: {
        FundCreateForm,
        Breadcrumbs,
    },
    props: {
        type: String,
    },
    setup() {
        const router = useRouter();
        const goBack = (val: string) => {
            if (val) useRedirect(router, 'DisplayFund', { id: val });
            else router.go(-1);
        };
        const { t } = useI18n();
        const breadcrumbItems = [
            {
                title: t('common.start'),
                disabled: false,
                to: { name: 'Home' },
            },
            {
                title: t('funds.title'),
                disabled: false,
                to: { name: 'Funds' },
            },
            {
                title: t('funds.create'),
                disabled: true,
            },
        ];
        return {
            t,
            goBack,
            breadcrumbItems,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/breadcrumbs-fund.scss';
</style>
