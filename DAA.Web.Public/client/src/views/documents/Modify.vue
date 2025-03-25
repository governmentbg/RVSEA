<template>
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <div>
            <h3 class="text-center">{{ $t('packages.document') }} - {{ $t('packages.modifyTitle') }}</h3>
        </div>
        <div>
            <ModifyDocumentCard :sysId="sysId" @cancel="goBack" @modified="goBack"></ModifyDocumentCard>
        </div>
    </v-card>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import ModifyDocumentCard from '@/components/document/modifyDocument.vue';
import { useRouter } from 'vue-router';

export default defineComponent({
    name: 'ModifyDocument',
    components: {
        ModifyDocumentCard,
    },
    props: {
        sysId: {
            type: String,
            required: true,
        },
    },
    setup() {
        const router = useRouter();

        const goBack = () => {
            router.go(-1);
        };

		return {
			goBack
		};
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
</style>