<template>
	<v-app>
		<Layout>
			<router-view />
		</Layout>
		<NotificationMessage :options="message" />
	</v-app>
</template>

<script lang="ts">
	import { computed, defineComponent, onMounted, provide, ref, watch } from 'vue';
	import { useI18n } from 'vue-i18n';
	import { IMessage } from './interfaces/notification';
	import { useStore } from '@/store/app';
	import { setLocale } from '@vee-validate/i18n';

	import authorization from '@/helpers/authorization.helper';

	import NotificationMessage from '@/components/notification/message.vue';
	import Layout from '@/components/layouts/Layout.vue';

	export default defineComponent({
		name: 'App',
		components: {
			NotificationMessage,
			Layout,
		},
		setup() {
			const { t, locale } = useI18n();

			const isAuthenticated = computed(() => authorization.isAuthenticated());
			const language = computed(() => appStore.getters.language);

			const message = ref<IMessage>();
			provide('notificationMessage', message);

			const appStore = useStore();


			onMounted(async () => {
				locale.value = language.value;
				setLocale(language.value);
			});

			watch(
				() => language.value,
				(val) => {
					locale.value = val;
					setLocale(val);
				}
			);
			
			return {
				t,
				isAuthenticated,
				message,
			};
		},
	});
</script>

<style lang="scss">
	@import '~bootstrap/scss/bootstrap';
	@import '~@vueform/multiselect/themes/default';
	//@import '~vuetify/dist/vuetify.css';

	html,
	body {
		min-height: 100vh;
	}
	#app {
		min-height: 100vh;
	}
	.v-application {
		min-height: 100vh;
	}
	.v-footer {
		flex: 0;
	}
	.v-card-title-uppercase {
		text-transform: uppercase !important;
	}
	.required::after {
		content: '*';
		color: var(--bs-danger);
	}

	img.footer {
		margin: 0px 25px !important;
	}

	#footertext {
		margin: 20px 0px;
		text-align: center;
	}

	footer {
		position: absolute !important;
		bottom: 0 !important;
		padding: 0px !important;
	}

	:root {
		--v-disabled-opacity: 0.85;

		--popper-theme-background-color: #ffffff;
		--popper-theme-background-color-hover: #ffffff;
		--popper-theme-text-color: #333333;
		--popper-theme-border-width: 1px;
		--popper-theme-border-style: solid;
		--popper-theme-border-color: #dadada;
		--popper-theme-border-radius: 6px;
		--popper-theme-padding: 0.5rem;
		--popper-theme-box-shadow: 0 6px 30px -6px rgba(0, 0, 0, 0.25);

		--ms-spinner-color: rgb(var(--v-theme-primary));
    
		--ms-tag-bg: rgb(var(--v-theme-secondary));
		--ms-group-label-bg-selected: rgb(var(--v-theme-secondary));
		--ms-group-label-bg-selected-pointed: rgb(var(--v-theme-secondary));
		--ms-option-bg-selected: rgb(var(--v-theme-secondary));
		--ms-option-bg-selected-pointed: rgb(var(--v-theme-secondary));
		

		//--ISDA-main-color1: #c66310;
		--ISDA-main-color1: #423129;
		--ISDA-main-color2: #f6e8e0; //Преработен ISDA-main-color3
		--ISDA-main-color2-1: #fff9f6; //Преработен ISDA-main-color3
		--ISDA-main-color3: #bdada5;
		//--ISDA-main-color4: #423129;
		--ISDA-main-color4: #c66310;
		--ISDA-main-color4-loader: #ffb300;
		//--ISDA-main-color4-loader: #ffee00;
		//--ISDA-main-color4-loader: #0040ff;
		--ISDA-main-color4-rgb-op: rgb(198, 99, 16, 0.5);
		//--ISDA-main-fund-color: #0c740c;
		--ISDA-main-fund-color: #005600;
		--ISDA-main-fund-color-light: #e8fce8;
		--ISDA-main-fund-color-light2: #f6fff6;
		//--ISDA-main-inv-color: #691569;
		--ISDA-main-inv-color: #620062;
		--ISDA-main-inv-color-light: #fcebfc;
		--ISDA-main-inv-color-light2: #fff7ff;
		--ISDA-main-ae-color: #176396;
		--ISDA-main-ae-color-light: #e5f2fd;
		--ISDA-main-ae-color-light2: #f4faff;
		--ISDA-main-doc-color: #069385;
		--ISDA-main-doc-color-light: #e9ffff;
		--ISDA-main-doc-color-light2: #f6ffff;
		--input-background-color: #a4a4a411;
		--input-border-color: #b4a8a3;
	}

	footer.v-footer {
		background-color: var(--ISDA-main-color1) !important;
	}

	div.v-field:has(:disabled),
	div.v-field:has(:disabled) label,
	div.form-check:has(:disabled) label {
		opacity: 0.7 !important;
	}

	.pointer {
		cursor: pointer !important;
	}

	.upload-input {
		.v-field__input {
			overflow-wrap: anywhere !important;
		}
	}
</style>
