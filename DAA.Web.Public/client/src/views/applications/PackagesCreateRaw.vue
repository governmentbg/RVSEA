<template>
<v-card class="col-12 col-md-9 col-lg-9 ma-auto">
	<div>
		<h3 class="text-center">{{$t('packages.createTitle')}}</h3>
	</div>
	<div>
		<CreatePackageA :applicationId="applicationId"></CreatePackageA>
	</div>
</v-card>
</template>

<script lang="ts">
	import { defineComponent } from 'vue';
	import CreatePackageA from '@/components/packageA/createPackagesForRawDocs.vue';

	export default defineComponent({
		name: 'PackagesCreate',
		components: {
			CreatePackageA
		},
		props: {
			applicationId: {
				type: Number,
				required: true,
			},
		}
	});
</script>

<style lang="scss" scoped>

@import "@/assets/styles/display-create-edit.scss"

</style>