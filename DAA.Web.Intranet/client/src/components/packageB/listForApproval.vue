<template>
	<div>

	</div>
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue';
import { IPackageBFile} from '@/models/packages';

export default defineComponent({
	name: 'PackageBApproval',
	setup () {
		const packageB = ref([] as Array<IPackageBFile>);

		return {}
	}
})
</script>

<style scoped>

</style>