<template>
	<v-dialog v-model="dialogIsVisible" persistent>
		<template v-slot:activator="{ props }">
			<v-btn v-bind="props">
				{{ btnTitle }}
			</v-btn>
		</template>
		<v-card class="vw-50 p-3 assign-modal">
			<v-card-title class="text-h5 text-center">
				{{ dialogTitle }}
			</v-card-title>
			<v-card-text>
				<v-container>
					<v-row>
						<v-col class="col-12">
							<label class="required" for="fldArchiveId">{{ t('common.archive') }}</label>
							<Dropdown
								v-model="archiveId"
								name="fldArchiveId"
								labelProp="label"
								valueProp="id"
								:items="archives"
							/>
						</v-col>
					</v-row>
				</v-container>
			</v-card-text>
			<v-card-actions>
				<v-spacer></v-spacer>
				<submit-btn  @click="onSubmit">
					{{ t('common.choose') }}
				</submit-btn>
				<cancel-btn @click="onClose">
					{{ t('common.cancel') }}
				</cancel-btn>
			</v-card-actions>
		</v-card>
	</v-dialog>
</template>

<script lang="ts">
	import { defineComponent, ref, onMounted, watch, inject, Ref } from 'vue';
	import { useI18n } from 'vue-i18n';
	import { IMessage } from '@/interfaces/notification';
	import { Message } from '@/models/notification';
	import Dropdown from '@/components/dropdown/dropdown.vue';
	import { IDropdownOption } from '@/interfaces/dropdown';
	import dropdownService from '@/services/dropdown.service';

	export default defineComponent({
		name: 'ChooseArchiveModal',
		components: {
			Dropdown,
		},
		emits: ['chosen'],
		props: {
			excludeArchiveId: {
				type: Number || undefined,
				required: false,
			},
			dialogTitle: {
				type: String,
				required: true,
			},
			btnTitle: {
				type: String,
				required: true,
			},
		},
		setup(props, context) {
			const { t } = useI18n();
			const message = inject('notificationMessage') as Ref<IMessage>;
			const dialogIsVisible = ref(false);
			const archiveId = ref(undefined);

			const archives = ref<IDropdownOption[]>([]);
			const getArchives = async () => {
				archives.value = (await dropdownService.getArchives()) || [];
				if(props.excludeArchiveId){
					archives.value = archives.value.filter(x => x.id != props.excludeArchiveId);
				}
			};

			const onClose = () => {
				dialogIsVisible.value = false;
			};

			const onSubmit = () => {
				if (!archiveId.value) {
					message.value = new Message({
						text: t('tasks.missingAssignTo'),
						display: true,
					});
					return;
				}

				context.emit('chosen', archiveId.value);
				dialogIsVisible.value = false;
			};


			onMounted(() => {
				getArchives();
			});

			watch(
				() => dialogIsVisible.value,
				(val) => {
					if (val) {
						archiveId.value = undefined;
					}
				}
			);

			return {
				t,
				dialogIsVisible,
				archives,
				archiveId,
				onClose,
				onSubmit,
			};
		},
	});
</script>

<style scoped lang="scss">
@import '@/assets/styles/display-create-edit.scss';
@import '@/assets/styles/dialog.scss';

	.vw-50 {
		width: 50vw;
		min-height: 70vh;
	}

</style>