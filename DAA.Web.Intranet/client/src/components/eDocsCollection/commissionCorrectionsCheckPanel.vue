<template>
	<v-expansion-panel>
		<v-expansion-panel-title>{{ 'Одобрение на промените по решенията на комисията' }}</v-expansion-panel-title>
		<!-- <div v-if="loading" class="d-flex justify-content-center">
			<v-progress-circular :size="50" color="green-lighten-2" indeterminate></v-progress-circular>
		</div> -->
		<v-expansion-panel-text>
			<v-row>
				<v-col class="d-flex gap-2 justify-content-start">
					<v-btn @click="onAccept"
						>Приемане
						<v-tooltip activator="parent" location="bottom"> Приемане на промените </v-tooltip>
					</v-btn>
					<confirm-dialog
						:commentInputEnabled="true"
						:activatorButtonCssClass="'cancel'"
						:confirmationText="$t('processes.buttons.reportChangesStepConfirmation')"
						:activatorButtonText="$t('processes.buttons.reportChangesStep')"
						:confirmButtonText="$t('common.yes')"
						:cancelButtonText="$t('common.cancel')"
						@confirm="onReject"
					></confirm-dialog>
				</v-col>
			</v-row>
		</v-expansion-panel-text>
	</v-expansion-panel>
</template>

<script lang="ts">
	import { computed, defineComponent, inject, PropType, Ref, ref } from 'vue';
	import { IProcess, IProcessStep } from '@/interfaces/process';
	import { ProcessStep } from '@/enums/process';
	import { IMessage } from '@/interfaces/notification';
	import service from '@/services/eDocsCollecting.service';
	import { ResponseResult } from '@/models/responseResult';
	import { Message } from '@/models/notification';
	// import AssignModal from '@/components/films/assign.modal.vue';
	import { AssignModel } from '@/models/task';
	import { RoleNames } from '@/enums/roles';
	import ConfirmDialog from '@/components/confirm/confirmDialog.vue';

	export default defineComponent({
		components: {
			// AssignModal,
			ConfirmDialog,
		},
		props: {
			process: {
				type: Object as PropType<IProcess>,
				required: true,
			},
		},
		setup(props) {
			const step = ref({
				processId: props.process.id!,
				id: props.process.activeProcessStepId,
				stepTypeId: props.process.activeProcessStepTypeId,
			} as IProcessStep);
			const message = inject('notificationMessage') as Ref<IMessage>;
			const approvalRoles = computed(() => [RoleNames.GroupA]);
			const isExternalProcedure = ref(false);

			service.isExternalProcess(props.process.id!).then((data) => (isExternalProcedure.value = data));

			return {
				approvalRoles,
				step,
				isExternalProcedure,
				message,
				processStep: ProcessStep,
			};
		},
		methods: {
			onAccept() {
				this.send();
			},
			onAssign(model: AssignModel) {
				this.step.assignedToUserId = model.assignToUserId;
				this.step.assignedToRoleId = model.assignToRoleId;
				service
					.sendForRegistration(this.step)
					.then(() => {
						//TODO
						window.location.reload();
					})
					.catch((err) => {
						const errorResult = err as ResponseResult;
						this.message = new Message({
							text: errorResult.showMessage ? errorResult.message : this.$t('error.basic'),
							display: true,
						});
					});
			},
			onReject(comment?: string) {
				this.step.comment = comment;
				service
					.returnCommissionChanges(this.step)
					.then(() => {
						//TODO
						window.location.reload();
					})
					.catch((err) => {
						const errorResult = err as ResponseResult;
						this.message = new Message({
							text: errorResult.showMessage ? errorResult.message : this.$t('error.basic'),
							display: true,
						});
					});
			},
			send() {
				service
					.moveToNextStep(this.step)
					.then(() => {
						//TODO
						window.location.reload();
					})
					.catch((err) => {
						const errorResult = err as ResponseResult;
						this.message = new Message({
							text: errorResult.showMessage ? errorResult.message : this.$t('error.basic'),
							display: true,
						});
					});
			},
		},
	});
</script>

<style scoped>
</style>