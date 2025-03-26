<template>
	<div>
		<div v-if="!templateArgs1.showAsDropdown">
			<span
				v-for="btn in templateArgs1.btns"
				@click.stop="btn.clickHandler(templateArgs, $event)"
				v-show="btn.show === true || ( typeof btn.show === 'function' && btn.show(templateArgs))"
				data-toggle="tooltip"
				class="pointer"
				:class="btn.class"
				:key="btn.id"
				v-tooltip="btn.tooltip"
			>
				<span
					v-if="
						btn.showBtn === undefined || btn.showBtn(templateArgs)
					"
				>
					<i v-if="btn.icon" :class="btn.icon"></i>
					{{ typeof btn.text == "function" ? btn.text() :  btn.text ? btn.text : "" }}
				</span>
			</span>
		</div>
		<div v-if="templateArgs1.showAsDropdown">
			<div class="btn-group">
				<i
					class="fa fa-ellipsis-v dropdown px-1"
					aria-expanded="false"
					data-bs-toggle="dropdown"
				>
				</i>
				<ul class="dropdown-menu">
					<li
						v-for="btn in templateArgs1.btns"
						@click.stop="btn.clickHandler(templateArgs, $event)"
						v-show="btn.show === true || ( typeof btn.show === 'function' && btn.show(templateArgs))"
						data-toggle="tooltip"
						class="pointer"
						:key="btn.id"
						v-tooltip="btn.tooltip"
					>
						<a
							class="dropdown-item"
							:class="btn.class"
							@click.stop="btn.clickHandler(templateArgs, $event)"
						>
							<span
								v-if="
									btn.showBtn === undefined ||
									btn.showBtn(templateArgs)
								"
							>
								<i v-if="btn.icon" :class="btn.icon"></i>
								{{ typeof btn.text == "function" ? btn.text() :  btn.text ? btn.text : "" }}
							</span>
						</a>
					</li>
				</ul>
			</div>
		</div>
	</div>
</template>

<script lang="ts">
	// templateArgs: 
	// {
	// 	showAsDropdown: boolean,
	// 	btns: [{
	// 		name: string,
	// 		text: string,
	// 		tooltip: string,
	// 		class: string (button classes),
	// 		icon: string (icon classes),
	// 		show: bool || () => boolean),
	// 		clickHandler: Function,
	// 	}]
	// }
	import { defineComponent } from "vue";
	import { Dropdown } from "bootstrap";
	export default defineComponent({
		name: "BtnsTemplate",
		props: {
			templateArgs: { type: Object, required: true },
		},
		watch: {
			templateArgs: {
				deep: true,
				immediate: true,
				handler(val: Record<string, unknown>) {
					if (val) {
						this.templateArgs1 = this.templateArgs;
					}
				},
			},
		},
		data() {
			return {
				templateArgs1: {} as Record<string, unknown>,
				dropdown: null as Dropdown | null,
			};
		},
		mounted() {
			this.templateArgs1 = this.templateArgs;
			if (this.templateArgs1.showAsDropdown) {
				const dropEl = (this.$el as HTMLElement).querySelector(
					".fa-ellipsis-v"
				);

				if (dropEl) {
					//Това е непбходимо поради фактам, че Popper.js ограничава 
					//dropdown-а до границите на най-близкия scrollable елемент
					//в случая .table-responsive
					const $table = dropEl?.closest(".table-responsive");
					this.dropdown = new Dropdown(dropEl);

					//при показване на dropdown-а премахваме scrollable елемента
					dropEl.addEventListener("show.bs.dropdown", () => {
						if ($table) {
							$table.classList.remove("table-responsive");
						}
					});

					//при скриване на dropdown-а връщаме scrollable елемента
					dropEl.addEventListener("hide.bs.dropdown", () => {
						if ($table) {
							$table.classList.add("table-responsive");
						}
					});
				}
			}
		},
	});
</script>

<style>
</style>
