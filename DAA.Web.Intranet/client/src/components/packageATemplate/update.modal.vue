<template>
	<v-row justify="start">
		<v-dialog persistent v-model="showModal">
			<v-card class="vw-50 p-3">
				<v-card-title class="text-h5 text-center">
					{{ $t("packageATemplates.updateTitle") }}
				</v-card-title>
				<div class="d-flex justify-content-center w-100" v-if="loading">
					<v-progress-circular
						:size="50"
						:width="5"
						color="primary"
						indeterminate
					></v-progress-circular>
				</div>
				<VForm @submit.prevent="onSubmit" v-show="!loading">
					<v-card-text>
						<v-container>
							<v-row>
								<v-col cols="12">
									<text-field
										v-model="model.title"
										:label="$t('packageATemplates.title')"
										:validation="'required'"
									></text-field>
								</v-col>
								<v-col cols="12">
									<v-file-input
										:label="$t('packageATemplates.file')"
										prepend-icon="mdi mdi-paperclip"
										v-model="files"
										truncate-length="15"
										hide-details="auto"
									></v-file-input>
								</v-col>
								<v-col cols="12">
									<v-switch
										v-model="model.required"
										hide-details
										inset
										color="primary"
										:label="
											$t('packageATemplates.required')
										"
									></v-switch>
								</v-col>
								<v-col cols="12">
									<text-area-field
										v-model="model.description"
										:label="
											$t('packageATemplates.description')
										"
									></text-area-field>
								</v-col>
							</v-row>
						</v-container>
					</v-card-text>
					<v-card-actions>
						<v-spacer></v-spacer>
						<submit-btn
							type="submit"
							:disabled="loading"
						>
							{{ $t("common.edit") }}
						</submit-btn>
						<cancel-btn
							type="button"
							@click="onClose"
							:disabled="loading"
						>
							{{ $t("common.cancel") }}
						</cancel-btn>
					</v-card-actions>
				</VForm>
			</v-card>
		</v-dialog>
	</v-row>
</template>

<script lang="ts">
	import { defineComponent, ref } from "vue";
	import { Form as VForm } from "vee-validate";
	import { PackageATemplateUpdateModel } from "@/models/packageATemplate";
	import TextField from "@/components/field/text.field.vue";
	import TextAreaField from "@/components/field/textarea.field.vue";
	import packageAService from "@/services/packageATemplates.service";

	export default defineComponent({
		components: {
			TextField,
			TextAreaField,
			VForm,
		},
		emits: ["updated", "update:show"],
		props: {
			modelValue: {
				type: Number,
				required: true,
			},
			show: {
				type: Boolean,
				required: true,
			},
		},
		setup(props) {

			const model = ref(new PackageATemplateUpdateModel());
			const files = ref([] as File[]);
			const loading = ref(false);
			const showModal = ref(false);
			const loadData = () => {
				loading.value = true;
				packageAService
					.getTemplate(props.modelValue)
					.then((data) => {
						model.value = new PackageATemplateUpdateModel(data);
						files.value.push(new File([], data.fileName))
					})
					.catch((err) => console.log(err))
					.then(() => (loading.value = false));
			};

			return {
				files,
				loadData,
				loading,
				model,
				showModal,
			};
		},
		methods: {
			onClose() {
				this.model = new PackageATemplateUpdateModel();
				this.files = [];
				this.showModal = false;
			},
			onSubmit() {
				this.loading = true;
				packageAService
					.update(this.model)
					.then(() => {
						this.$emit("updated");
						this.onClose();
						//TODO show success message
					})
					.catch((err) => {
						console.error(err);
						//TODO show error message
					})
					.then(() => (this.loading = false));
			},
		},
		watch: {
			files: function (value: File[]) {
				this.model.file = value[0] || null;
			},
			show: function (val: boolean) {
				if (this.showModal !== val) {
					this.showModal = val;
				}

				if (this.show === true) {
					this.loadData();
				}
			},
			showModal: function () {
				this.$emit("update:show", this.showModal);
			},
		},
	});
</script>

<style scoped lang="scss">
	.vw-50 {
		width: 50vw;
		min-height: 30vh;
	}

	@import "@/assets/styles/dialog.scss";

</style>