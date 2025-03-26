<template>
    <v-card class="col-12 col-md-9 col-lg-9 ma-auto">
        <div>
            <h3 class="text-center">{{ $t('packages.inventory') }} - {{ $t('packages.modifyTitle') }}</h3>
        </div>
        <div>
            <ModifyInventoryCard :sysId="sysId" @cancel="goBack" @modified="goBack"></ModifyInventoryCard>
        </div>
    </v-card>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import ModifyInventoryCard from '@/components/inventory/modifyInventory.vue';
import { useRouter } from 'vue-router';

export default defineComponent({
    name: 'ModifyInventory',
    components: {
        ModifyInventoryCard,
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