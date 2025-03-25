<template>
	<div>
		<div class="d-flex w-100">
			<div
				v-for="(step, index) in steps"
				:key="'step' + index"
				class="d-flex justify-content-between"
				:class="{
					'flex-grow-1': index < steps.length - 1,
				}"
			>
				<div
					class="stepTitle"
					:class="{
						passed: index < currentIndex,
						current: index == currentIndex,
					}"
				>
					<div class="stepIconWrapper">
						<span v-if="index >= currentIndex">{{
							index + 1
						}}</span>
						<v-icon v-if="index < currentIndex" large color="white">
							mdi-check
						</v-icon>
					</div>
					<span class="titleText d-none d-md-block">
						{{ step }}
					</span>
				</div>
				<v-divider
					v-if="index != steps.length - 1"
					thickness="3"
				></v-divider>
			</div>
		</div>
		<div></div>
	</div>
</template>

<script lang="ts">
	import { defineComponent, PropType } from "vue";

	export default defineComponent({
		props: {
			steps: {
				type: Array as PropType<Array<string>>,
				required: false,
			},
			currentIndex: {
				type: Number,
				default: 0,
			},
		},
	});
</script>

<style lang="scss" scoped>
	.stepTitle {
		width: fit-content;
		white-space: nowrap;
		.stepIconWrapper {
			width: 2em;
			height: 2em;
			border: 1px solid lightgrey;
			border-radius: 50%;
			display: flex;
			justify-content: center;
			align-items: center;
			background: var(--bs-secondary);
			color: white;
			margin: auto;
		}
		&.current {
			font-weight: bold;
			.stepIconWrapper {
				background: var(--bs-primary);
			}
		}
		&.passed {
			.stepIconWrapper {
				background: var(--bs-success);
			}
		}
	}
</style>