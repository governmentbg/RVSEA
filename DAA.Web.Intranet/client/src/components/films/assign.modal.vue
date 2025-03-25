<template>
	<v-dialog v-model="dialogIsVisible" persistent>
		<template v-slot:activator="{ props }">
			<v-btn v-bind="props">
				{{ btnTitle }}
			</v-btn>
		</template>
		<v-card class="vw-50 p-3" style="min-height: 400px">
			<v-card-title class="text-h5 text-center">
				{{ dialogTitle }}
			</v-card-title>
			<v-card-text>
				<v-container>
					<v-row v-if="showRoles && showSwitch">
						<v-col cols="6">
							<v-switch
								v-model="assignToRole"
								hide-details
								inset
								color="primary"
								:label="t('tasks.assignToRole')"
							></v-switch>
						</v-col>
					</v-row>
					<v-row v-if="showUsers">
						<v-col class="col-12">
							<label class="required" for="fldAssignToUserId">{{ t('tasks.user') }}</label>
							<Dropdown
								v-model="model.assignToUserId"
								name="fldAssignToUserId"
								labelProp="label"
								valueProp="code"
								:items="users"
								:disabled="assignToRole"
							/>
						</v-col>
						<v-col class="col-4" v-if="showDate">
							<label for="fldEndDate">{{ t('tasks.endDate') }}</label>
							<DatePicker name="fldEndDate" v-model:date="model.endDate" />
						</v-col>
					</v-row>
					<v-row v-if="showRoles" class="fldAssignToRoleId">
						<v-col class="col-12">
							<label class="required" for="fldAssignToRoleId">{{ t('tasks.role') }}</label>
							<Dropdown
								v-model="model.assignToRoleId"
								name="fldAssignToRoleId"
								labelProp="label"
								valueProp="code"
								:items="roles"
								:disabled="!assignToRole"
							/>
						</v-col>
					</v-row>
				</v-container>
			</v-card-text>
			<v-card-actions>
				<v-spacer></v-spacer>
				<submit-btn  @click="onSubmit">
					{{ t('tasks.send') }}
				</submit-btn>
				<cancel-btn @click="onClose">
					{{ t('common.cancel') }}
				</cancel-btn>
			</v-card-actions>
		</v-card>
	</v-dialog>
</template>

<script lang="ts">
	import { defineComponent, ref, onMounted, PropType, watch, inject, Ref } from 'vue';
	import { useI18n } from 'vue-i18n';
	import { IMessage } from '@/interfaces/notification';
	import { Message } from '@/models/notification';
	import Dropdown from '@/components/dropdown/dropdown.vue';
	import DatePicker from '@/components/datetime/datepPicker.vue';
	import { IDropdownOption } from '@/interfaces/dropdown';
	import dropdownService from '@/services/dropdown.service';
	import { RoleNames } from '@/enums/roles';
	import { AssignModel } from '@/models/task';

	export default defineComponent({
		name: 'AssignModal',
		components: {
			Dropdown,
			DatePicker,
		},
		emits: ['assign'],
		props: {
			archiveId: {
				type: Number,
				required: true,
			},
			roleNames: {
				type: Array as PropType<RoleNames[]>,
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
			showRoles: {
				type: Boolean,
				default: true,
			},
			showDate: {
				type: Boolean,
				default: true,
			},
			showUsers: {
				type: Boolean,
				default: true,
			},
		},
		setup(props, context) {
			const { t } = useI18n();
			const message = inject('notificationMessage') as Ref<IMessage>;
			const dialogIsVisible = ref(false);
			const assignToRole = ref(false);
			const showSwitch = ref(true);
			const model = ref(new AssignModel());

			const users = ref<IDropdownOption[]>([]);
			const getUsers = async () => {
				users.value = (await dropdownService.getUsersInRoles(props.archiveId, props.roleNames || [])) || [];
			};

            const roles = ref<IDropdownOption[]>([]);
            const getRoles = async () => {
                roles.value = await dropdownService.getRolesInArchive(props.archiveId, props.roleNames || []) || [];
            };

			const onClose = () => {
				dialogIsVisible.value = false;
			};

			const onSubmit = () => {
				if (!model.value.assignToUserId && !model.value.assignToRoleId) {
					message.value = new Message({
						text: t('tasks.missingAssignTo'),
						display: true,
					});
					return;
				}

				if (assignToRole.value == true) {
					model.value.assignToUserId = '';
				} else {
					model.value.assignToRoleId = '';
				}

				context.emit('assign', model.value);
				dialogIsVisible.value = false;
			};

			const setVisibility = () => {
				if(!props.showUsers && props.showRoles){
					assignToRole.value = true;
					showSwitch.value = false;

					if (roles.value && roles.value.length === 1){
						preselectSingleRole(true);
					}
				}
			};

			const preselectSingleRole = (preselect: boolean) => {
				model.value.assignToRoleId = preselect 
					? roles.value[0].code?.toString() 
					: '';
			}

			onMounted(() => {
				getUsers();
				getRoles();
				setVisibility();				
			});

			watch(
				() => dialogIsVisible.value,
				(val) => {
					if (val) {
						assignToRole.value = false;
						model.value.assignToUserId = '';
						model.value.assignToRoleId = '';
						model.value.endDate = undefined;
						showSwitch.value = true;
						setVisibility();
					}
				}
			);

			watch(
				() => assignToRole.value,
				(val) => {
					preselectSingleRole(false);
					if (val && roles.value && roles.value.length === 1) {
						preselectSingleRole(true);
					}
				}
			);

			watch(
				() => props.archiveId,
				async () => {
					await getUsers();
					await getRoles();
				}
			);

			watch(
				() => () => props.roleNames,
				async () => {
					await getUsers();
				}
			);

			return {
				t,
				dialogIsVisible,
				assignToRole,
				showSwitch,
				users,
				roles,
				model,
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

	.fldAssignToRoleId {
		margin-bottom: 100px !important;
	}

</style>