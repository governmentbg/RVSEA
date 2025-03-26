<template>
	<v-row>
		<v-col>
			<text-field v-model="model.title" :label="'Title'" :validation="'required'" variant="underlined"></text-field>
		</v-col>
	</v-row>
</template>

<script lang="ts">
import { PackageATemplateCreateModel } from '@/models/packageATemplates';
import { defineComponent, ref } from 'vue';
import TextField from '@/components/field/text.field.vue';

export default defineComponent({
	components: {
		TextField
	},
	props: {
		procedureId: {
			type: Number,
			required: true
		}
	},
	
	setup () {
		const model = ref(new PackageATemplateCreateModel());
		return {model}
	}
})
</script>

<style scoped>

</style>